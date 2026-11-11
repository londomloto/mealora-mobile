import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/data/speech/device_speech_recognizer.dart';
import 'package:mealora/domain/voice_input/speech_recognizer.dart';

void main() {
  group('mapSpeechError (change 012)', () {
    test('tidak ada yang dikenali menjadi transkrip kosong, bukan kegagalan '
        '(task 3.6)', () {
      for (final code in <String>['error_no_match', 'error_speech_timeout']) {
        final event = mapSpeechError(code);
        expect(event, isA<SpeechFinalTranscript>(), reason: code);
        expect((event as SpeechFinalTranscript).isEmpty, isTrue);
      }
    });

    test('izin ditolak dikenali sebagai permissionDenied (task 3.2)', () {
      for (final code in <String>[
        'error_permission',
        'error_insufficient_permissions',
      ]) {
        final event = mapSpeechError(code);
        expect(
          (event as SpeechSessionFailed).reason,
          SpeechUnavailableReason.permissionDenied,
          reason: code,
        );
      }
    });

    test('bahasa tidak didukung di perangkat dikenali sebagai notSupported, '
        'tanpa jalur ke layanan luar (task 3.4, 3.5)', () {
      for (final code in <String>[
        'error_language_not_supported',
        'error_language_unavailable',
        'error_server_disconnected',
      ]) {
        final event = mapSpeechError(code);
        expect(
          (event as SpeechSessionFailed).reason,
          SpeechUnavailableReason.notSupported,
          reason: code,
        );
      }
    });

    test('galat lain menjadi failed', () {
      final event = mapSpeechError('error_network');
      expect(
        (event as SpeechSessionFailed).reason,
        SpeechUnavailableReason.failed,
      );
    });
  });
}
