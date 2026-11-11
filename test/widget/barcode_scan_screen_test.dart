import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/features/diary/barcode_scan_screen.dart';
import 'package:mealora/features/diary/nutrition_label_photo_screen.dart';

import 'harness.dart';

/// `21 · Pindai barcode` — hanya bagian yang TIDAK menyentuh kamera
/// sungguhan (sebelum tombol "Gunakan kamera" ditekan): kartu "Foto Info
/// Gizi" (change 010) yang membuka layar foto label
/// langsung tanpa barcode apa pun.
void main() {
  testWidgets('kartu "Foto Info Gizi" membuka layar foto label tanpa barcode', (
    tester,
  ) async {
    await tester.pumpWidget(wrapForTest(const BarcodeScanScreen()));
    await tester.pumpAndSettle();

    final photoAction = find.text('Foto Info Gizi');
    await tester.scrollUntilVisible(photoAction, 240);
    await tester.tap(photoAction);
    await tester.pumpAndSettle();

    final screen = tester.widget<NutritionLabelPhotoScreen>(
      find.byType(NutritionLabelPhotoScreen),
    );
    expect(screen.barcode, isNull);
  });
}
