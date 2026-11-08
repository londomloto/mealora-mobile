import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';

import 'harness.dart';

void main() {
  Widget gallery() => Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(MealoraSpacing.md),
      child: Column(
        children: <Widget>[
          MealoraPrimaryButton(label: 'Simpan catatan', onPressed: () {}),
          const SizedBox(height: MealoraSpacing.md),
          const MealoraChip(label: 'Program aktif', icon: Icons.eco_outlined),
          const SizedBox(height: MealoraSpacing.md),
          const MealoraCard(child: Text('Isi kartu')),
          const SizedBox(height: MealoraSpacing.md),
          const MealoraField(label: 'Berat saat ini', hint: '68,4'),
          const SizedBox(height: MealoraSpacing.md),
          const MealoraEmptyState(
            title: 'Belum ada catatan hari ini',
            body:
                'Di sini nanti muncul energi dan makronutrien yang kamu '
                'catat hari ini.',
          ),
          const SizedBox(height: MealoraSpacing.md),
          const MealoraErrorState(
            title: 'Penyimpanan belum siap',
            body: 'Catatanmu belum bisa dibaca atau ditulis.',
            detailLabel: 'Kode kegagalan',
            detail: 'storageUnavailable',
          ),
        ],
      ),
    ),
  );

  for (final scale in <double>[1, 2]) {
    testWidgets('komponen dasar tampil utuh pada skala teks ${scale}x', (
      tester,
    ) async {
      await useDesignViewport(tester);
      await tester.pumpWidget(wrapForTest(gallery(), textScale: scale));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      expect(find.text('Simpan catatan'), findsOneWidget);
      expect(find.text('Program aktif'), findsOneWidget);
      expect(find.text('Isi kartu'), findsOneWidget);
      expect(find.text('Berat saat ini'), findsOneWidget);
      expect(find.text('Belum ada catatan hari ini'), findsOneWidget);
      expect(find.text('Penyimpanan belum siap'), findsOneWidget);
    });
  }

  testWidgets('tombol primer memenuhi ambang target sentuh', (tester) async {
    await useDesignViewport(tester);
    await tester.pumpWidget(
      wrapForTest(
        Scaffold(
          body: Center(
            child: MealoraPrimaryButton(label: 'Lanjut', onPressed: () {}),
          ),
        ),
      ),
    );

    final size = tester.getSize(find.byType(FilledButton));
    expect(size.height, greaterThanOrEqualTo(MealoraTouch.minTarget));
  });

  testWidgets('tombol primer diumumkan pembaca layar sebagai tombol berlabel', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        Scaffold(
          body: Center(
            child: MealoraPrimaryButton(label: 'Lanjut', onPressed: () {}),
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Lanjut')),
      matchesSemantics(
        label: 'Lanjut',
        isButton: true,
        isEnabled: true,
        hasEnabledState: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
  });

  testWidgets('tombol nonaktif tetap diumumkan keadaannya', (tester) async {
    await tester.pumpWidget(
      wrapForTest(
        const Scaffold(
          body: Center(
            child: MealoraPrimaryButton(label: 'Lanjut', onPressed: null),
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Lanjut')),
      matchesSemantics(
        label: 'Lanjut',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
      ),
    );
  });

  testWidgets('keadaan kosong tidak menampilkan angka nol', (tester) async {
    await useDesignViewport(tester);
    await tester.pumpWidget(
      wrapForTest(
        const Scaffold(
          body: MealoraEmptyState(
            title: 'Belum ada riwayat',
            body: 'Di sini nanti muncul catatan harianmu.',
          ),
        ),
      ),
    );

    expect(find.text('Belum ada data'), findsOneWidget);
    expect(find.textContaining('0'), findsNothing);
  });
}
