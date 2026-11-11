import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/image_ai_access/image_ai_settings.dart';
import 'package:mealora/features/profile/privacy_settings_screen.dart';

import 'harness.dart';

/// `true` bila ada `Semantics` bertanda `selected: true` yang labelnya
/// diawali judul pilihan — `OnboardingChoiceCard` menyusun label sebagai
/// `'$title. $detail'`.
bool _selectedChoiceLabel(WidgetTester tester, String title) {
  final matches = find.byWidgetPredicate(
    (widget) =>
        widget is Semantics &&
        widget.properties.selected == true &&
        (widget.properties.label ?? '').startsWith(title),
  );
  return matches.evaluate().isNotEmpty;
}

/// `35 · Privasi & data lokal` (task 3.5/3.6).
void main() {
  late AppDatabase database;

  setUp(() {
    database = createWidgetTestDatabase();
  });

  tearDown(() => database.close());

  testWidgets('bawaan: tanya setiap kali dan hapus setelah dicatat terpilih', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(const PrivacySettingsScreen(), database: database),
    );
    await tester.pumpAndSettle();

    expect(_selectedChoiceLabel(tester, 'Tanya setiap kali'), isTrue);
    expect(_selectedChoiceLabel(tester, 'Hapus setelah dicatat'), isTrue);
  });

  testWidgets('memilih "Selalu izinkan" mengubah dan menyimpan preferensi', (
    tester,
  ) async {
    late ProviderContainer container;
    await tester.pumpWidget(
      wrapForTest(
        Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return const PrivacySettingsScreen();
          },
        ),
        database: database,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Selalu izinkan'));
    await tester.pumpAndSettle();

    expect(
      container.read(imageUploadConsentPreferenceProvider).value,
      ImageUploadConsentPreference.alwaysAllow,
    );
  });

  testWidgets('memilih "Simpan di perangkat" mengubah dan menyimpan '
      'preferensi retensi', (tester) async {
    late ProviderContainer container;
    await tester.pumpWidget(
      wrapForTest(
        Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return const PrivacySettingsScreen();
          },
        ),
        database: database,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan di perangkat'));
    await tester.pumpAndSettle();

    expect(
      container.read(imageRetentionPreferenceProvider).value,
      ImageRetentionPreference.keepOnDevice,
    );
  });
}
