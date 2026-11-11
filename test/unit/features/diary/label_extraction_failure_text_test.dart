import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/features/diary/label_extraction_failure_text.dart';

import '../../../widget/harness.dart';

void main() {
  testWidgets(
    'setiap LabelServiceFailureReason punya teks bahasa awam, tanpa kode '
    'error (task 4.2)',
    (tester) async {
      final anchor = GlobalKey();
      await tester.pumpWidget(wrapForTest(SizedBox(key: anchor)));
      await tester.pumpAndSettle();

      final text = textOf(tester, find.byKey(anchor));

      for (final reason in LabelServiceFailureReason.values) {
        final headline = labelExtractionFailureHeadline(text, reason);
        expect(headline, isNotEmpty);
        expect(
          headline.toLowerCase(),
          isNot(contains(reason.name.toLowerCase())),
          reason: 'teks SHALL TIDAK menyebut nama enum teknis (${reason.name})',
        );
        expect(
          headline,
          isNot(contains(RegExp(r'[0-9]{3}'))),
          reason: 'teks SHALL TIDAK memuat kode status HTTP',
        );
      }
    },
  );
}
