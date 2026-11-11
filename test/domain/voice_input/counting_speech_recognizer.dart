import 'dart:async';

import 'package:mealora/domain/voice_input/speech_recognizer.dart';

/// Tiruan [SpeechRecognizer] yang mencatat setiap panggilan, untuk memastikan
/// izin mikrofon tidak diminta di luar jalur suara (task 3.8).
///
/// Bila [events] kosong, sesi tetap terbuka sampai [emit] dipanggil — untuk
/// menguji keadaan `43 · Sedang merekam`.
final class CountingSpeechRecognizer implements SpeechRecognizer {
  CountingSpeechRecognizer({
    this.availability = const SpeechAvailable(),
    this.events = const <SpeechSessionEvent>[],
  });

  final SpeechAvailability availability;
  final List<SpeechSessionEvent> events;

  int prepareCalls = 0;
  int listenCalls = 0;
  int stopCalls = 0;
  int cancelCalls = 0;
  StreamController<SpeechSessionEvent>? _live;

  @override
  Future<SpeechAvailability> prepare() async {
    prepareCalls++;
    return availability;
  }

  @override
  Stream<SpeechSessionEvent> listen() {
    listenCalls++;
    if (events.isNotEmpty) {
      return Stream<SpeechSessionEvent>.fromIterable(events);
    }
    // Ditutup di cancel().
    // ignore: close_sinks
    final live = StreamController<SpeechSessionEvent>();
    _live = live;
    return live.stream;
  }

  /// Mengirim peristiwa ke sesi yang sedang terbuka.
  void emit(SpeechSessionEvent event) => _live?.add(event);

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  @override
  Future<void> cancel() async {
    cancelCalls++;
    await _live?.close();
  }
}
