import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/app_theme.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart';
import 'package:mealora/features/onboarding/onboarding_flow.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

import 'harness.dart';

/// Alur onboarding penuh sampai `review` (Tahap 2, tasks 4.1–4.10) —
/// `12 · Tinjau target` dan aktivasi datang Tahap 3, diuji terpisah.
void main() {
  late AppDatabase database;

  setUp(() => database = createWidgetTestDatabase());
  tearDown(() => database.close());

  List<Override> overrides() => <Override>[
    clockProvider.overrideWithValue(createWidgetTestClock()),
    idGeneratorProvider.overrideWithValue(SequentialIdGenerator()),
    appDatabaseProvider.overrideWithValue(database),
    profileRepositoryAppOverride,
    programRepositoryAppOverride,
  ];

  Widget wrapFlow(ProviderContainer container, {double textScale = 1}) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: MealoraTheme.light(),
        localizationsDelegates: AppText.localizationsDelegates,
        supportedLocales: AppText.supportedLocales,
        locale: const Locale('id'),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const OnboardingFlow(),
      ),
    );
  }

  testWidgets('sambutan menampilkan janji tanpa akun dan pindah ke profil', (
    tester,
  ) async {
    await useDesignViewport(tester);
    final container = ProviderContainer(overrides: overrides());
    addTearDown(container.dispose);

    await tester.pumpWidget(wrapFlow(container));
    await tester.pumpAndSettle();

    expect(
      find.text('Data pribadimu tersimpan di perangkat ini.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Mulai perjalanan'));
    await tester.pumpAndSettle();

    expect(find.text('Kenalan dulu, yuk'), findsOneWidget);
    expect(find.text('LANGKAH 1 / 5'), findsOneWidget);
  });

  testWidgets(
    'Makan Sehat tidak pernah meminta berat tujuan dan menahan langkah '
    'sampai pengakuan diberikan (task 4.10/4.8, scenario 6.6/6.7)',
    (tester) async {
      await useDesignViewport(tester);
      final container = ProviderContainer(overrides: overrides());
      addTearDown(container.dispose);

      await container.read(onboardingControllerProvider.future);
      final notifier = container.read(onboardingControllerProvider.notifier);
      await notifier.saveProfileBasics(
        nickname: '',
        birthDate: const LocalDate(1997, 5, 20),
        heightCm: 165,
        currentWeightKg: 68.4,
        biologicalInput: BiologicalInput.female,
        today: const LocalDate(2026, 11, 9),
      );
      await notifier.saveActivityLevel(ActivityLevel.moderatelyActive);
      notifier.selectProgram(ProgramCode.healthyEating);
      notifier.goToStep(OnboardingStep.programDetail);

      await tester.pumpWidget(wrapFlow(container));
      await tester.pumpAndSettle();

      expect(find.text('Fokus Makan Sehat'), findsOneWidget);
      expect(find.textContaining('Berat tujuan'), findsNothing);
      expect(find.text('Lihat perkiraan target'), findsOneWidget);

      // Pengakuan belum diberikan: menekan tombol tidak berpindah langkah.
      await tester.tap(find.text('Lihat perkiraan target'));
      await tester.pumpAndSettle();
      expect(find.text('Fokus Makan Sehat'), findsOneWidget);

      await tester.tap(
        find.text(
          'Saya paham bahwa target dan data makanan adalah perkiraan, '
          'bukan nasihat medis.',
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lihat perkiraan target'));
      await tester.pumpAndSettle();

      // Tidak melewati layar target berat (25) — langsung ke review.
      expect(find.text('Atur target berat'), findsNothing);
      expect(find.text('Fokus Makan Sehat'), findsNothing);
    },
  );

  testWidgets(
    'Turun Berat melewati layar target berat sebelum review (task 4.9)',
    (tester) async {
      await useDesignViewport(tester);
      final container = ProviderContainer(overrides: overrides());
      addTearDown(container.dispose);

      await container.read(onboardingControllerProvider.future);
      final notifier = container.read(onboardingControllerProvider.notifier);
      await notifier.saveProfileBasics(
        nickname: '',
        birthDate: const LocalDate(1997, 5, 20),
        heightCm: 165,
        currentWeightKg: 68.4,
        biologicalInput: BiologicalInput.female,
        today: const LocalDate(2026, 11, 9),
      );
      await notifier.saveActivityLevel(ActivityLevel.moderatelyActive);
      notifier.selectProgram(ProgramCode.weightLoss);
      notifier.goToStep(OnboardingStep.programDetail);
      notifier.setEstimateAcknowledged(true);

      await tester.pumpWidget(wrapFlow(container));
      await tester.pumpAndSettle();

      expect(find.text('Detail Turun Berat'), findsOneWidget);
      await tester.tap(find.text('Lanjutkan'));
      await tester.pumpAndSettle();

      expect(find.text('Atur target berat'), findsOneWidget);
      expect(find.text('PROGRAM · TURUN BERAT'), findsOneWidget);
    },
  );

  testWidgets('seluruh langkah onboarding tetap terbaca pada skala teks besar '
      '(task 4.11)', (tester) async {
    await useDesignViewport(tester);
    final container = ProviderContainer(overrides: overrides());
    addTearDown(container.dispose);

    await tester.pumpWidget(wrapFlow(container, textScale: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Mulai perjalanan'));
    await tester.tap(find.text('Mulai perjalanan'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final notifier = container.read(onboardingControllerProvider.notifier);
    await notifier.saveProfileBasics(
      nickname: '',
      birthDate: const LocalDate(1997, 5, 20),
      heightCm: 165,
      currentWeightKg: 68.4,
      biologicalInput: BiologicalInput.female,
      today: const LocalDate(2026, 11, 9),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    notifier.selectProgram(ProgramCode.weightLoss);
    notifier.goToStep(OnboardingStep.targetWeight);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  group('pratinjau, aktivasi, dan penolakan (Tahap 3)', () {
    Future<void> reachReviewForHealthyEating(
      WidgetTester tester,
      ProviderContainer container,
    ) async {
      await container.read(onboardingControllerProvider.future);
      final notifier = container.read(onboardingControllerProvider.notifier);
      await notifier.saveProfileBasics(
        nickname: '',
        birthDate: const LocalDate(1997, 5, 20),
        heightCm: 165,
        currentWeightKg: 68.4,
        biologicalInput: BiologicalInput.female,
        today: const LocalDate(2026, 11, 9),
      );
      await notifier.saveActivityLevel(ActivityLevel.moderatelyActive);
      notifier.selectProgram(ProgramCode.healthyEating);
      notifier.saveHabitFocus('consistent_logging');
      notifier.setEstimateAcknowledged(true);
      notifier.continueFromProgramDetail();

      await tester.pumpWidget(wrapFlow(container));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'pratinjau menampilkan target, dasar perkiraan, dan pernyataan belum '
      'ada program aktif, lalu menyetujui mengaktifkan program (FRS 4.3.1/'
      '4.3.2, task 5.1/5.3)',
      (tester) async {
        final container = ProviderContainer(overrides: overrides());
        addTearDown(container.dispose);
        await reachReviewForHealthyEating(tester, container);

        expect(find.text('Tinjau targetmu'), findsOneWidget);
        expect(
          find.text('Tidak ada program aktif sebelum kamu menyetujui.'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Kalkulator msj-1.0.0 · Kebijakan np-1.0.0'),
          findsOneWidget,
        );

        await tester.tap(find.text('Setujui & mulai program'));
        await tester.pumpAndSettle();

        final active = await container.read(activeProgramProvider.future);
        expect(active, isNotNull);
        expect(active!.programCode, ProgramCode.healthyEating);
      },
    );

    testWidgets(
      'profil di luar cakupan menampilkan layar penolakan tanpa angka '
      'apa pun (Design D7, scenario 6.11, task 6.6)',
      (tester) async {
        final container = ProviderContainer(overrides: overrides());
        addTearDown(container.dispose);

        await container.read(onboardingControllerProvider.future);
        final notifier = container.read(onboardingControllerProvider.notifier);
        await notifier.saveProfileBasics(
          nickname: '',
          birthDate: const LocalDate(2009, 5, 20),
          heightCm: 165,
          currentWeightKg: 55,
          biologicalInput: BiologicalInput.female,
          today: const LocalDate(2026, 11, 9),
        );
        await notifier.saveActivityLevel(ActivityLevel.moderatelyActive);
        notifier.selectProgram(ProgramCode.weightLoss);
        notifier.setEstimateAcknowledged(true);
        notifier.continueFromProgramDetail();
        notifier.saveTargetWeightDetails(targetWeightKg: 50);

        await tester.pumpWidget(wrapFlow(container));
        await tester.pumpAndSettle();

        expect(find.text('Target tidak dibuat'), findsOneWidget);
        expect(find.text('Belum bisa membuat target otomatis'), findsOneWidget);
        expect(
          find.text('Data dan program sebelumnya tidak berubah.'),
          findsOneWidget,
        );
        expect(find.textContaining('kkal'), findsNothing);
        expect(find.text('Lihat program lain'), findsOneWidget);
      },
    );

    testWidgets(
      'laju yang diminta terlalu cepat menawarkan saran dan atur sendiri, '
      'bukan program lain (task 6.3, scenario 6.12; change 019)',
      (tester) async {
        final container = ProviderContainer(overrides: overrides());
        addTearDown(container.dispose);

        await container.read(onboardingControllerProvider.future);
        final notifier = container.read(onboardingControllerProvider.notifier);
        await notifier.saveProfileBasics(
          nickname: '',
          birthDate: const LocalDate(1997, 5, 20),
          heightCm: 165,
          currentWeightKg: 68.4,
          biologicalInput: BiologicalInput.female,
          today: const LocalDate(2026, 11, 9),
        );
        await notifier.saveActivityLevel(ActivityLevel.moderatelyActive);
        notifier.selectProgram(ProgramCode.weightLoss);
        notifier.setEstimateAcknowledged(true);
        notifier.continueFromProgramDetail();
        notifier.saveTargetWeightDetails(
          targetWeightKg: 62.4,
          targetDate: const LocalDate(2026, 12, 7),
        );

        await tester.pumpWidget(wrapFlow(container));
        await tester.pumpAndSettle();

        expect(
          find.text('Tanggal ini butuh laju yang terlalu cepat'),
          findsOneWidget,
        );
        expect(find.text('PILIH PENYESUAIAN'), findsOneWidget);
        expect(find.textContaining('Tetap 62,4 kg, mulai'), findsOneWidget);
        expect(find.textContaining(', target 66,3 kg'), findsOneWidget);
        expect(find.text('Terapkan dan tinjau ulang'), findsOneWidget);
        expect(find.text('Lihat program lain'), findsNothing);
        expect(find.textContaining('kkal'), findsNothing);

        await tester.ensureVisible(find.text('Atur sendiri'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Atur sendiri'));
        await tester.pumpAndSettle();

        expect(find.text('Atur target berat'), findsOneWidget);
        expect(find.textContaining('Minimal aman untuk tinggimu'), findsOneWidget);
      },
    );

    testWidgets(
      'memilih saran menerapkannya lalu meninjau ulang (change 019)',
      (tester) async {
        final container = ProviderContainer(overrides: overrides());
        addTearDown(container.dispose);

        await container.read(onboardingControllerProvider.future);
        final notifier = container.read(onboardingControllerProvider.notifier);
        await notifier.saveProfileBasics(
          nickname: '',
          birthDate: const LocalDate(1997, 5, 20),
          heightCm: 165,
          currentWeightKg: 68.4,
          biologicalInput: BiologicalInput.female,
          today: const LocalDate(2026, 11, 9),
        );
        await notifier.saveActivityLevel(ActivityLevel.moderatelyActive);
        notifier.selectProgram(ProgramCode.weightLoss);
        notifier.setEstimateAcknowledged(true);
        notifier.continueFromProgramDetail();
        notifier.saveTargetWeightDetails(
          targetWeightKg: 62.4,
          targetDate: const LocalDate(2026, 12, 7),
        );

        await tester.pumpWidget(wrapFlow(container));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.textContaining(', target 66,3 kg'));
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining(', target 66,3 kg'));
        await tester.pump();
        await tester.tap(find.text('Terapkan dan tinjau ulang'));
        await tester.pumpAndSettle();

        final draft = container.read(onboardingControllerProvider).value!;
        expect(draft.targetWeight!.kg, 66.3);
        expect(draft.targetDate, const LocalDate(2026, 12, 7));
        expect(
          find.text('Tanggal ini butuh laju yang terlalu cepat'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'mengubah target manual setelah ditolak menghitung ulang pratinjau '
      '(change 019)',
      (tester) async {
        final container = ProviderContainer(overrides: overrides());
        addTearDown(container.dispose);

        await container.read(onboardingControllerProvider.future);
        final notifier = container.read(onboardingControllerProvider.notifier);
        await notifier.saveProfileBasics(
          nickname: '',
          birthDate: const LocalDate(1997, 5, 20),
          heightCm: 165,
          currentWeightKg: 68.4,
          biologicalInput: BiologicalInput.female,
          today: const LocalDate(2026, 11, 9),
        );
        await notifier.saveActivityLevel(ActivityLevel.moderatelyActive);
        notifier.selectProgram(ProgramCode.weightLoss);
        notifier.setEstimateAcknowledged(true);
        notifier.continueFromProgramDetail();
        notifier.saveTargetWeightDetails(
          targetWeightKg: 62.4,
          targetDate: const LocalDate(2026, 12, 7),
        );

        await tester.pumpWidget(wrapFlow(container));
        await tester.pumpAndSettle();
        expect(
          find.text('Tanggal ini butuh laju yang terlalu cepat'),
          findsOneWidget,
        );

        notifier.saveTargetWeightDetails(targetWeightKg: 62.4);
        await tester.pumpAndSettle();

        expect(
          find.text('Tanggal ini butuh laju yang terlalu cepat'),
          findsNothing,
        );
      },
    );
  });
}
