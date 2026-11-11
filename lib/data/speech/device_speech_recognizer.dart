import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:mealora/domain/voice_input/speech_recognizer.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// [SpeechRecognizer] di atas pengenalan ucapan sistem Android lewat
/// `speech_to_text` (change 012, design D2).
///
/// `onDevice: false`: layanan pengenalan sistem boleh memakai server
/// penyedianya (mis. Google) bila model offline bahasa Indonesia belum
/// terpasang — mewajibkan unduhan model terlalu sulit bagi pengguna awam.
/// Plugin tidak menulis rekaman ke
/// berkas; audio hanya mengalir ke layanan pengenalan sistem dan yang
/// diterima aplikasi hanya teks, jadi tidak ada rekaman yang perlu dihapus
/// setelah transkrip jadi (task 3.7).
final class DeviceSpeechRecognizer implements SpeechRecognizer {
  DeviceSpeechRecognizer({SpeechToText? speech})
    : _speech = speech ?? SpeechToText();

  static const String _indonesianPrefix = 'id';
  static const Duration _listenFor = Duration(seconds: 60);
  static const Duration _pauseFor = Duration(seconds: 4);

  final SpeechToText _speech;
  String? _localeId;
  StreamController<SpeechSessionEvent>? _session;
  Timer? _doneTimer;
  String _lastPartial = '';
  static const Duration _doneGrace = Duration(milliseconds: 600);

  @override
  Future<SpeechAvailability> prepare() async {
    final bool initialized;
    try {
      initialized = await _speech.initialize(
        onError: _onError,
        onStatus: _onStatus,
      );
    } on Object {
      return const SpeechUnavailable(SpeechUnavailableReason.failed);
    }
    if (!initialized) {
      final granted = await _hasPermission();
      return SpeechUnavailable(
        granted
            ? SpeechUnavailableReason.notSupported
            : SpeechUnavailableReason.permissionDenied,
      );
    }
    final localeId = await _indonesianLocale();
    if (localeId == null) {
      return const SpeechUnavailable(SpeechUnavailableReason.notSupported);
    }
    _localeId = localeId;
    if (kDebugMode) debugPrint('Speech locale: $localeId');
    return const SpeechAvailable();
  }

  @override
  Stream<SpeechSessionEvent> listen() {
    final localeId = _localeId;
    final previous = _session;
    if (previous != null && !previous.isClosed) {
      unawaited(previous.close());
    }
    // Ditutup oleh _finish, cancel, atau listen berikutnya.
    // ignore: close_sinks
    final session = StreamController<SpeechSessionEvent>();
    _session = session;
    _lastPartial = '';
    if (localeId == null) {
      _finish(const SpeechSessionFailed(SpeechUnavailableReason.failed));
      return session.stream;
    }
    unawaited(_start(localeId));
    return session.stream;
  }

  Future<void> _start(String localeId) async {
    try {
      await _speech.listen(
        onResult: _onResult,
        listenOptions: SpeechListenOptions(
          localeId: localeId,
          onDevice: false,
          partialResults: true,
          listenMode: ListenMode.dictation,
          cancelOnError: true,
          listenFor: _listenFor,
          pauseFor: _pauseFor,
        ),
      );
    } on Object {
      _finish(const SpeechSessionFailed(SpeechUnavailableReason.failed));
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _speech.stop();
    } on Object {
      _finish(const SpeechSessionFailed(SpeechUnavailableReason.failed));
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await _speech.cancel();
    } on Object {
      // Pembatalan bersifat upaya terbaik; sesi tetap ditutup di bawah.
    }
    final session = _session;
    if (session != null && !session.isClosed) {
      await session.close();
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    final text = result.recognizedWords;
    if (result.finalResult) {
      _finish(SpeechFinalTranscript(text));
    } else {
      _lastPartial = text;
      _emit(SpeechPartialTranscript(text));
    }
  }

  void _onError(SpeechRecognitionError error) {
    // Hanya kode galat dan statusnya; tidak pernah isi ucapan.
    if (kDebugMode) {
      debugPrint(
        'Speech error: ${error.errorMsg} permanent=${error.permanent}',
      );
    }
    _finish(mapSpeechError(error.errorMsg));
  }

  void _onStatus(String status) {
    if (kDebugMode) debugPrint('Speech status: $status');
    // Status "done" bisa datang SEBELUM galatnya (teramati di emulator:
    // done lalu error_server_disconnected). Beri galat kesempatan lebih dulu;
    // Bila tidak ada galat maupun hasil akhir, pakai transkrip sementara
    // terakhir: pengenal online Google (onDevice: false) teramati di HP
    // Samsung mengirim "done" tanpa pernah mengirim hasil final.
    if (status == SpeechToText.doneStatus) {
      _doneTimer?.cancel();
      _doneTimer = Timer(_doneGrace, () {
        _finish(SpeechFinalTranscript(_lastPartial));
      });
    }
  }

  void _emit(SpeechSessionEvent event) {
    final session = _session;
    if (session != null && !session.isClosed) {
      session.add(event);
    }
  }

  void _finish(SpeechSessionEvent event) {
    _doneTimer?.cancel();
    final session = _session;
    if (session == null || session.isClosed) {
      return;
    }
    session.add(event);
    unawaited(session.close());
  }

  Future<bool> _hasPermission() async {
    try {
      return await _speech.hasPermission;
    } on Object {
      return false;
    }
  }

  Future<String?> _indonesianLocale() async {
    try {
      final locales = await _speech.locales();
      for (final locale in locales) {
        final id = locale.localeId.toLowerCase();
        if (id == _indonesianPrefix ||
            id.startsWith('${_indonesianPrefix}_') ||
            id.startsWith('$_indonesianPrefix-')) {
          return locale.localeId;
        }
      }
      return null;
    } on Object {
      return null;
    }
  }
}

/// Memetakan kode galat Android `SpeechRecognizer` ke peristiwa sesi.
///
/// "Tidak ada yang dikenali" dan "diam terlalu lama" bukan kegagalan,
/// melainkan transkrip kosong (task 3.6).
SpeechSessionEvent mapSpeechError(String errorMsg) {
  switch (errorMsg) {
    case 'error_no_match':
    case 'error_speech_timeout':
      return const SpeechFinalTranscript('');
    case 'error_permission':
    case 'error_insufficient_permissions':
      return const SpeechSessionFailed(
        SpeechUnavailableReason.permissionDenied,
      );
    case 'error_language_not_supported':
    case 'error_language_unavailable':
    // Layanan pengenalan sistem tidak mendukung id_ID sama sekali.
    case 'error_server_disconnected':
      return const SpeechSessionFailed(SpeechUnavailableReason.notSupported);
    default:
      return const SpeechSessionFailed(SpeechUnavailableReason.failed);
  }
}
