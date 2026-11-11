import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/voice_input/food_sentence_parser.dart';
import 'package:mealora/domain/voice_input/mock_food_sentence_parser.dart';
import 'package:mealora/domain/voice_input/rule_based_food_sentence_parser.dart';
import 'package:mealora/domain/voice_input/speech_recognizer.dart';
import 'package:mealora/features/diary/voice_record_screen.dart';
import 'package:mealora/features/diary/voice_transcript_screen.dart';
import 'package:mealora/features/diary/voice_type_screen.dart';

import '../domain/voice_input/counting_speech_recognizer.dart';
import 'harness.dart';

/// Layar masukan suara `42`-`45` (change 012, grup 4).
void main() {
  Future<void> pumpRecord(
    WidgetTester tester,
    CountingSpeechRecognizer recognizer, {
    double textScale = 1,
  }) async {
    await useDesignViewport(tester);
    await tester.pumpWidget(
      wrapForTest(
        const VoiceRecordScreen(),
        textScale: textScale,
        overrides: [speechRecognizerProvider.overrideWithValue(recognizer)],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapStart(WidgetTester tester) async {
    final start = find.bySemanticsLabel('Mulai merekam');
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pump();
    await tester.pump();
  }

  group('42 · Rekam suara', () {
    for (final scale in <double>[1, 2]) {
      testWidgets('siap merekam tanpa meminta izin (skala $scale)', (
        tester,
      ) async {
        final recognizer = CountingSpeechRecognizer();
        await pumpRecord(tester, recognizer, textScale: scale);

        expect(find.text('Sebutkan makananmu'), findsOneWidget);
        expect(find.text('Suara hanya untuk mencatat makanan'), findsOneWidget);
        expect(recognizer.prepareCalls, 0);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('43 · Sedang merekam', () {
    for (final scale in <double>[1, 2]) {
      testWidgets('ditandai label dan ikon, dengan tombol Selesai '
          '(skala $scale)', (tester) async {
        final recognizer = CountingSpeechRecognizer();
        await pumpRecord(tester, recognizer, textScale: scale);
        await tapStart(tester);

        expect(recognizer.prepareCalls, 1);
        expect(find.text('Merekam · 0:00'), findsOneWidget);
        expect(find.byIcon(Icons.mic), findsOneWidget);
        expect(find.text('Selesai'), findsOneWidget);
        expect(
          find.bySemanticsLabel(RegExp('Sedang merekam, mikrofon aktif')),
          findsWidgets,
        );

        recognizer.emit(const SpeechPartialTranscript('nasi satu piring'));
        await tester.pump(const Duration(milliseconds: 10));
        expect(find.text('nasi satu piring'), findsOneWidget);

        await tester.tap(find.text('Selesai'));
        await tester.pump();
        expect(recognizer.stopCalls, 1);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('transkrip akhir membuka 44 dengan teks yang dapat disunting', (
      tester,
    ) async {
      final recognizer = CountingSpeechRecognizer(
        events: const <SpeechSessionEvent>[
          SpeechFinalTranscript('nasi satu piring, tempe dua'),
        ],
      );
      await pumpRecord(tester, recognizer);
      await tapStart(tester);
      await tester.pumpAndSettle();

      expect(find.byType(VoiceTranscriptScreen), findsOneWidget);
      expect(find.text('nasi satu piring, tempe dua'), findsOneWidget);
    });

    testWidgets('transkrip kosong menawarkan rekam ulang, tanpa catatan '
        '(task 3.6)', (tester) async {
      final recognizer = CountingSpeechRecognizer(
        events: const <SpeechSessionEvent>[SpeechFinalTranscript('  ')],
      );
      await pumpRecord(tester, recognizer);
      await tapStart(tester);
      await tester.pumpAndSettle();

      expect(find.text('Belum ada yang terdengar'), findsOneWidget);
      expect(find.text('Rekam ulang'), findsOneWidget);
      expect(find.byType(VoiceTranscriptScreen), findsNothing);
    });
  });

  group('45 · Suara tidak tersedia', () {
    testWidgets('izin ditolak mengarah ke ketik kalimat, bukan layar gagal '
        '(task 3.2)', (tester) async {
      final recognizer = CountingSpeechRecognizer(
        availability: const SpeechUnavailable(
          SpeechUnavailableReason.permissionDenied,
        ),
      );
      await pumpRecord(tester, recognizer);
      await tapStart(tester);
      await tester.pumpAndSettle();

      expect(find.byType(VoiceTypeScreen), findsOneWidget);
      expect(find.text('Izin mikrofon belum diberikan'), findsOneWidget);
      expect(find.text('Ketik kalimatnya'), findsOneWidget);
      expect(recognizer.listenCalls, 0);
    });

    testWidgets('perangkat tidak mendukung dinyatakan jelas (task 3.4)', (
      tester,
    ) async {
      final recognizer = CountingSpeechRecognizer(
        availability: const SpeechUnavailable(
          SpeechUnavailableReason.notSupported,
        ),
      );
      await pumpRecord(tester, recognizer);
      await tapStart(tester);
      await tester.pumpAndSettle();

      expect(find.text('Pengenalan suara belum didukung'), findsOneWidget);
    });

    for (final scale in <double>[1, 2]) {
      testWidgets('ketik kalimat bekerja tanpa pengenal ucapan '
          '(task 4.6, skala $scale)', (tester) async {
        await useDesignViewport(tester);
        final parser = MockFoodSentenceParser.failing(
          LabelServiceFailureReason.offline,
        );
        await tester.pumpWidget(
          wrapForTest(
            const VoiceTypeScreen(
              reason: SpeechUnavailableReason.permissionDenied,
            ),
            textScale: scale,
            overrides: [foodSentenceParserProvider.overrideWithValue(parser)],
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'tempe dua');
        await tester.pump();
        final parse = find.text('Urai kalimat ini');
        await tester.ensureVisible(parse);
        await tester.tap(parse);
        await tester.pumpAndSettle();

        // Teks diketik sampai ke pengurai tanpa menyentuh mikrofon.
        expect(parser.received, <String>['tempe dua']);
        expect(find.text('Kalimat belum bisa diurai'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('penguraian tidak tersedia: dinyatakan, teks tetap, katalog '
        'ditawarkan (task 5.6)', (tester) async {
      await useDesignViewport(tester);
      await tester.pumpWidget(
        wrapForTest(
          const VoiceTypeScreen(),
          overrides: [
            foodSentenceParserProvider.overrideWithValue(
              MockFoodSentenceParser.failing(
                LabelServiceFailureReason.quotaExceeded,
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'tempe dua');
      await tester.pump();
      final parse = find.text('Urai kalimat ini');
      await tester.ensureVisible(parse);
      await tester.tap(parse);
      await tester.pumpAndSettle();

      expect(find.text('Kalimat belum bisa diurai'), findsOneWidget);
      expect(find.textContaining('sedang penuh'), findsOneWidget);
      expect(find.text('tempe dua'), findsOneWidget);
      expect(find.text('Tanpa internet? Cari di katalog'), findsOneWidget);
    });
  });

  group('Batas cakupan (task 6.1, 6.2, 6.5)', () {
    Future<void> typeAndParse(
      WidgetTester tester,
      FoodSentenceParser parser,
      String sentence,
    ) async {
      await useDesignViewport(tester);
      await tester.pumpWidget(
        wrapForTest(
          const VoiceTypeScreen(),
          overrides: [foodSentenceParserProvider.overrideWithValue(parser)],
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), sentence);
      await tester.pump();
      final parse = find.text('Urai kalimat ini');
      await tester.ensureVisible(parse);
      await tester.tap(parse);
      await tester.pumpAndSettle();
    }

    testWidgets('kalimat di luar cakupan tidak dijalankan; batas dan '
        'tempatnya dinyatakan', (tester) async {
      await typeAndParse(
        tester,
        const RuleBasedFoodSentenceParser(),
        'catat berat badan aku enam puluh dua kilo',
      );

      expect(find.text('Suara hanya untuk mencatat makanan'), findsWidgets);
      expect(
        find.textContaining('Berat badan dicatat di ruang Program'),
        findsOneWidget,
      );
      expect(find.textContaining('makanan terurai'), findsNothing);
    });
  });
  group('44 · Tinjau transkrip', () {
    for (final scale in <double>[1, 2]) {
      testWidgets('menyatakan teks bisa keliru dan dapat disunting '
          '(task 4.3-4.5, skala $scale)', (tester) async {
        await useDesignViewport(tester);
        await tester.pumpWidget(
          wrapForTest(
            const VoiceTranscriptScreen(transcript: 'nasi satu piring'),
            textScale: scale,
            overrides: [
              speechRecognizerProvider.overrideWithValue(
                CountingSpeechRecognizer(),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Hasil pengenalan bisa keliru. Perbaiki dulu sebelum diurai.',
          ),
          findsOneWidget,
        );
        await tester.enterText(find.byType(TextField), 'nasi dua piring');
        await tester.pump();
        expect(find.text('nasi dua piring'), findsOneWidget);
        await tester.ensureVisible(find.text('Rekam ulang'));
        expect(find.text('Rekam ulang'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('teks kosong tidak dapat diurai', (tester) async {
      await useDesignViewport(tester);
      await tester.pumpWidget(
        wrapForTest(const VoiceTranscriptScreen(transcript: 'tempe')),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      final button = tester.widget<MealoraPrimaryButton>(
        find.byType(MealoraPrimaryButton),
      );
      expect(button.onPressed, isNull);
    });
  });
}
