import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/features/diary/add_food_sheet.dart';

import '../domain/voice_input/counting_speech_recognizer.dart';
import 'harness.dart';

/// Task 3.8 (change 012): izin mikrofon tidak diminta ketika pengguna hanya
/// membuka pilihan cara pencatatan.
void main() {
  testWidgets('membuka lembar 02 tidak menyentuh pengenal ucapan', (
    tester,
  ) async {
    await useDesignViewport(tester);
    final recognizer = CountingSpeechRecognizer();

    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showAddFoodSheet(context),
                child: const Text('buka'),
              ),
            ),
          ),
        ),
        overrides: [speechRecognizerProvider.overrideWithValue(recognizer)],
      ),
    );
    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();

    expect(find.text('Catat dengan suara'), findsOneWidget);
    expect(recognizer.prepareCalls, 0);
    expect(recognizer.listenCalls, 0);
  });
}
