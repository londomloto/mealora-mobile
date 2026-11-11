import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/voice_input/speech_recognizer.dart';
import 'package:mealora/features/diary/voice_record_screen.dart';
import 'package:mealora/features/diary/voice_transcript_screen.dart';
import 'package:mealora/features/diary/voice_type_screen.dart';

import '../domain/voice_input/counting_speech_recognizer.dart';
import 'harness.dart';

/// Change 012, task 8.1-8.3: kendali rekam, transkrip, dan ketik kalimat
/// berlabel untuk pembaca layar, berukuran sentuh layak, dan keadaan
/// merekam diumumkan beserta cara menghentikannya.
void main() {
  Future<void> expectGuidelines(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    // Ukuran sentuh minimal 48x48 untuk kendali milik change 012. Tombol
    // "Kembali" di `MealoraBackEyebrow` (komponen bersama, 32x32) dikecualikan
    // dan dicatat sebagai temuan terpisah, bukan diubah di sini.
    final small = <String>[];
    void visit(SemanticsNode node) {
      final data = node.getSemanticsData();
      if (data.hasAction(SemanticsAction.tap) && data.label != 'Kembali') {
        final size = node.rect.size;
        if (size.width < 47.9 || size.height < 47.9) {
          small.add('"${data.label}" ${size.width}x${size.height}');
        }
      }
      node.visitChildren((child) {
        visit(child);
        return true;
      });
    }

    visit(
      tester
          .binding
          .renderViews
          .first
          .owner!
          .semanticsOwner!
          .rootSemanticsNode!,
    );
    expect(small, isEmpty, reason: small.join('\n'));
  }

  for (final scale in <double>[1, 2]) {
    testWidgets('42 · Rekam suara memenuhi pedoman (skala $scale)', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await useDesignViewport(tester);
      await tester.pumpWidget(
        wrapForTest(
          const VoiceRecordScreen(),
          textScale: scale,
          overrides: [
            speechRecognizerProvider.overrideWithValue(
              CountingSpeechRecognizer(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await expectGuidelines(tester);
      handle.dispose();
    });

    testWidgets('43 · Sedang merekam diumumkan beserta cara berhenti '
        '(skala $scale)', (tester) async {
      final handle = tester.ensureSemantics();
      await useDesignViewport(tester);
      await tester.pumpWidget(
        wrapForTest(
          const VoiceRecordScreen(),
          textScale: scale,
          overrides: [
            speechRecognizerProvider.overrideWithValue(
              CountingSpeechRecognizer(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      final start = find.bySemanticsLabel('Mulai merekam');
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pump();
      await tester.pump();

      final badge = tester.getSemantics(
        find.bySemanticsLabel(
          'Sedang merekam, mikrofon aktif. Ketuk Selesai untuk berhenti.',
        ),
      );
      expect(badge.flagsCollection.isLiveRegion, isTrue);
      expect(find.bySemanticsLabel('Selesai'), findsOneWidget);
      await expectGuidelines(tester);
      handle.dispose();
    });

    testWidgets('44 · Tinjau transkrip memenuhi pedoman (skala $scale)', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await useDesignViewport(tester);
      await tester.pumpWidget(
        wrapForTest(
          const VoiceTranscriptScreen(transcript: 'nasi satu piring'),
          textScale: scale,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(RegExp('TEKS YANG TERDENGAR')),
        findsOneWidget,
      );
      await expectGuidelines(tester);
      handle.dispose();
    });

    testWidgets('45 · Ketik kalimat memenuhi pedoman (skala $scale)', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await useDesignViewport(tester);
      await tester.pumpWidget(
        wrapForTest(
          const VoiceTypeScreen(reason: SpeechUnavailableReason.notSupported),
          textScale: scale,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(RegExp('Ketik kalimatnya')), findsWidgets);
      await expectGuidelines(tester);
      expect(tester.takeException(), isNull);
      handle.dispose();
    });
  }

  testWidgets('tidak ada teks yang terpotong pada skala 2x di 43', (
    tester,
  ) async {
    await useDesignViewport(tester);
    await tester.pumpWidget(
      wrapForTest(
        const VoiceRecordScreen(),
        textScale: 2,
        overrides: [
          speechRecognizerProvider.overrideWithValue(
            CountingSpeechRecognizer(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    final start = find.bySemanticsLabel('Mulai merekam');
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsWidgets);
  });
}
