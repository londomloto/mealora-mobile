import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/app.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/program/nutrition_policy.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';
import 'package:mealora/features/profile/edit_profile_screen.dart';
import 'package:mealora/features/program/change_program_flow.dart';
import 'package:mealora/features/program/complete_program_screen.dart';
import 'package:mealora/features/program/history_screens.dart';
import 'package:mealora/features/program/how_calculated_screen.dart';
import 'package:mealora/features/program/program_providers.dart';
import 'package:mealora/features/program/program_revision_review_screen.dart';
import 'package:mealora/features/program/program_screen.dart';
import 'package:mealora/features/shell/floating_navigation.dart';
import 'package:mealora/features/today/today_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

import 'harness.dart';

/// Uji integrasi siklus hidup program change 006 di atas basis data
/// in-memory nyata (pola yang sama dengan
/// `full_onboarding_integration_test.dart`, task 2.7/5.5/5.6/7.1-7.4):
/// aktif → jeda → lanjutkan → "Bagaimana dihitung" → riwayat → selesaikan.
void main() {
  Future<ProviderContainer> bootstrapWithActiveProgram(
    WidgetTester tester, {
    required AppDatabase database,
  }) async {
    final container = ProviderContainer(
      overrides: <Override>[
        clockProvider.overrideWithValue(createWidgetTestClock()),
        idGeneratorProvider.overrideWithValue(SequentialIdGenerator()),
        databaseFactoryProvider.overrideWithValue(() => database),
        profileRepositoryAppOverride,
        programRepositoryAppOverride,
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MealoraApp(),
      ),
    );
    await tester.pumpAndSettle();

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
    notifier.goToStep(OnboardingStep.review);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Setujui & mulai program'));
    await tester.pumpAndSettle();
    expect(find.byType(TodayScreen), findsOneWidget);

    return container;
  }

  Future<void> openProgramTab(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(FloatingNavigation),
        matching: find.text('Program'),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Men-tap [finder], menggulirkannya ke dalam tampilan dulu bila perlu —
  /// ruang Program bisa lebih tinggi dari viewport uji (390×844).
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'keadaan aktif menampilkan program, target, dan kendali (task 2.1/2.2)',
    (tester) async {
      await useDesignViewport(tester);
      final database = createWidgetTestDatabase();
      addTearDown(database.close);
      await bootstrapWithActiveProgram(tester, database: database);

      await openProgramTab(tester);

      expect(find.text('Makan Sehat'), findsOneWidget);
      expect(find.text('Berjalan'), findsOneWidget);
      expect(find.text('Jeda'), findsOneWidget);
      expect(find.text('Ganti'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ProgramScreen),
          matching: find.text('Riwayat'),
        ),
        findsOneWidget,
      );
      // Makan Sehat SHALL TIDAK menampilkan persentase kemajuan berat (task 2.3).
      expect(find.text('Kebiasaan minggu ini'), findsOneWidget);
      expect(find.text('Kemajuan belum diketahui'), findsNothing);
    },
  );

  testWidgets(
    'jeda lalu lanjutkan mengembalikan ke keadaan aktif (task 2.5/2.6/5.1)',
    (tester) async {
      await useDesignViewport(tester);
      final database = createWidgetTestDatabase();
      addTearDown(database.close);
      await bootstrapWithActiveProgram(tester, database: database);
      await openProgramTab(tester);

      await tapVisible(tester, find.text('Jeda'));

      expect(find.text('Dijeda'), findsOneWidget);
      expect(find.textContaining('Dijeda sejak'), findsOneWidget);
      expect(
        find.text('Hari jeda tidak dihitung sebagai hari aktif.'),
        findsOneWidget,
      );
      expect(find.text('Lanjutkan program'), findsOneWidget);
      expect(find.text('Selesaikan program'), findsOneWidget);

      await tapVisible(tester, find.text('Lanjutkan program'));

      expect(find.text('Berjalan'), findsOneWidget);
      expect(find.text('Jeda'), findsOneWidget);
    },
  );

  testWidgets(
    'Bagaimana dihitung membaca target tersimpan apa adanya (task 4.1-4.3)',
    (tester) async {
      await useDesignViewport(tester);
      final database = createWidgetTestDatabase();
      addTearDown(database.close);
      await bootstrapWithActiveProgram(tester, database: database);
      await openProgramTab(tester);

      await tapVisible(tester, find.text('Bagaimana dihitung'));

      expect(find.byType(HowCalculatedScreen), findsOneWidget);
      expect(find.text('Masukan yang dipakai'), findsOneWidget);
      expect(find.text('Asumsi'), findsOneWidget);
      // Profil uji ini tidak memicu peringatan apa pun — bagian Peringatan
      // SHALL tersembunyi seluruhnya, bukan kotak kosong (task 1.3).
      expect(find.text('Peringatan'), findsNothing);
    },
  );

  testWidgets(
    'riwayat menampilkan entri aktif dan detail apa adanya (task 7.1-7.4)',
    (tester) async {
      await useDesignViewport(tester);
      final database = createWidgetTestDatabase();
      addTearDown(database.close);
      await bootstrapWithActiveProgram(tester, database: database);
      await openProgramTab(tester);

      await tapVisible(
        tester,
        find.descendant(
          of: find.byType(ProgramScreen),
          matching: find.text('Riwayat'),
        ),
      );

      expect(find.byType(ProgramHistoryListScreen), findsOneWidget);
      expect(find.textContaining('Aktif · sejak'), findsOneWidget);

      await tapVisible(tester, find.text('Makan Sehat'));

      expect(find.byType(ProgramDetailHistoryScreen), findsOneWidget);
      expect(find.text('Rincian program'), findsOneWidget);
      expect(find.text('Belum ada data di hari terakhir'), findsOneWidget);
    },
  );

  testWidgets(
    'membatalkan penyelesaian tidak mengubah apa pun (task 5.3/5.6)',
    (tester) async {
      await useDesignViewport(tester);
      final database = createWidgetTestDatabase();
      addTearDown(database.close);
      await bootstrapWithActiveProgram(tester, database: database);
      await openProgramTab(tester);

      await tapVisible(tester, find.text('Jeda'));
      await tapVisible(tester, find.text('Selesaikan program'));

      expect(find.byType(CompleteProgramScreen), findsOneWidget);
      await tapVisible(tester, find.text('Batal, tetap di program ini'));

      // Kembali ke ruang Program: program masih dijeda, bukan selesai.
      expect(find.text('Dijeda'), findsOneWidget);
    },
  );

  testWidgets(
    'menyelesaikan program memindahkannya ke riwayat dengan alasan (task 5.2/5.4)',
    (tester) async {
      await useDesignViewport(tester);
      final database = createWidgetTestDatabase();
      addTearDown(database.close);
      final container = await bootstrapWithActiveProgram(
        tester,
        database: database,
      );
      await openProgramTab(tester);

      await tapVisible(tester, find.text('Jeda'));
      await tapVisible(tester, find.text('Selesaikan program'));

      await tapVisible(tester, find.text('Pilih alasan'));
      await tapVisible(tester, find.text('Saya sudah mencapai tujuan'));

      await tapVisible(tester, find.text('Ya, selesaikan program'));

      // Tidak ada program berjalan lagi — ruang Program kembali ke keadaan
      // "Belum ada program" (task 5.4).
      expect(find.text('Pilih programmu'), findsOneWidget);

      // Riwayat (dibaca langsung lewat repositori, bukan navigasi UI lagi)
      // menunjukkan program tadi berstatus selesai dengan alasannya.
      final profile = await container.read(profileRepositoryProvider).current();
      final history = await container
          .read(programRepositoryProvider)
          .history(profile!.id);
      expect(history, hasLength(1));
      expect(history.single.state.name, 'completed');
      expect(history.single.completionReason, 'goal_reached');
    },
  );

  testWidgets(
    'peringatan batas bawah energi tetap tampil di "Bagaimana dihitung" '
    'setelah aplikasi ditutup dan dibuka kembali (task 4.4)',
    (tester) async {
      await useDesignViewport(tester);
      final database = createWidgetTestDatabase();
      addTearDown(database.close);

      List<Override> overrides() => <Override>[
        clockProvider.overrideWithValue(createWidgetTestClock()),
        idGeneratorProvider.overrideWithValue(SequentialIdGenerator()),
        databaseFactoryProvider.overrideWithValue(() => database),
        profileRepositoryAppOverride,
        programRepositoryAppOverride,
      ];

      final firstRun = ProviderContainer(overrides: overrides());
      addTearDown(firstRun.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: firstRun,
          child: const MealoraApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Profil dan target ini SENGAJA memicu peringatan batas bawah energi
      // (`floorApplied`) — laki-laki bertubuh kecil, tidak banyak bergerak,
      // target turun berat: hasilnya TETAP disetujui (bukan ditolak), tapi
      // target dinaikkan ke batas bawah, 1500 kkal/hari.
      await firstRun.read(onboardingControllerProvider.future);
      final notifier = firstRun.read(onboardingControllerProvider.notifier);
      await notifier.saveProfileBasics(
        nickname: '',
        birthDate: const LocalDate(1996, 5, 20),
        heightCm: 155,
        currentWeightKg: 50,
        biologicalInput: BiologicalInput.male,
        today: const LocalDate(2026, 11, 9),
      );
      await notifier.saveActivityLevel(ActivityLevel.sedentary);
      notifier.selectProgram(ProgramCode.weightLoss);
      notifier.setEstimateAcknowledged(true);
      notifier.continueFromProgramDetail();
      notifier.saveTargetWeightDetails(
        targetWeightKg: 45,
        targetDate: const LocalDate(2027, 3, 1),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tinjau targetmu'), findsOneWidget);
      // Catatan: layar pratinjau onboarding (change 005, `review_screen.dart`)
      // TIDAK merender `ProgramWarning` sama sekali — temuan di luar lingkup
      // change 006 (lihat laporan akhir), jadi tidak diuji di sini. Fokus
      // task 4.4 adalah "Bagaimana dihitung" di bawah, yang memang dibangun
      // oleh change ini untuk menampilkan peringatan secara permanen.

      await tester.tap(find.text('Setujui & mulai program'));
      await tester.pumpAndSettle();
      expect(find.byType(TodayScreen), findsOneWidget);

      await openProgramTab(tester);
      await tapVisible(tester, find.text('Bagaimana dihitung'));
      expect(find.byType(HowCalculatedScreen), findsOneWidget);
      expect(find.text('Peringatan'), findsOneWidget);
      expect(find.textContaining('Batas bawah energi'), findsWidgets);

      // Tutup aplikasi sepenuhnya: buang container dan pohon widget
      // pertama. Basis data tetap terbuka (sama seperti change 005
      // scenario 6.1) — peringatan harus dibaca kembali dari penyimpanan,
      // bukan dari state sementara yang baru hilang.
      await tester.pumpWidget(const SizedBox.shrink());
      final secondRun = ProviderContainer(overrides: overrides());
      addTearDown(secondRun.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: secondRun,
          child: const MealoraApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Catatan: ruang yang tampil duluan setelah dibuka kembali bisa jadi
      // ruang Program (preferensi tab terakhir ikut tersimpan) — bukan
      // "Hari ini" seperti pemasangan baru. Itu bukan yang diuji di sini;
      // `openProgramTab` aman dipanggil baik dari "Hari ini" maupun saat
      // sudah berada di ruang Program.
      await openProgramTab(tester);
      await tapVisible(tester, find.text('Bagaimana dihitung'));

      expect(find.byType(HowCalculatedScreen), findsOneWidget);
      expect(
        find.text('Peringatan'),
        findsOneWidget,
        reason:
            'peringatan yang tersimpan bersama target SHALL tetap tampil '
            'setelah aplikasi ditutup-buka kembali (task 4.4)',
      );
      expect(find.textContaining('Batas bawah energi'), findsWidgets);
    },
  );

  testWidgets(
    'ruang Program tetap terbaca pada skala teks besar, aktif maupun dijeda (task 9.4)',
    (tester) async {
      await useDesignViewport(tester);
      final database = createWidgetTestDatabase();
      addTearDown(database.close);
      await bootstrapWithActiveProgram(tester, database: database);

      // Skala teks dinaikkan HANYA setelah bootstrap (yang melewati ruang
      // Hari ini) — cakupan skala teks besar task 9.4 adalah layar
      // program/riwayat/detail, bukan ruang Hari ini (change lain).
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openProgramTab(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Makan Sehat'), findsOneWidget);

      await tapVisible(tester, find.text('Jeda'));
      expect(tester.takeException(), isNull);
      expect(find.text('Dijeda'), findsOneWidget);
    },
  );

  testWidgets(
    'mengganti versi kebijakan di lingkungan uji tidak mengubah satu pun '
    'nilai pada entri riwayat (task 7.6)',
    (tester) async {
      await useDesignViewport(tester);
      final database = createWidgetTestDatabase();
      addTearDown(database.close);

      // Jalan pertama: kebijakan DISETUJUI (seperti produksi) — program
      // dibuat dan tersimpan dengan `policyVersion`/target yang berlaku
      // saat itu.
      final firstRun = ProviderContainer(
        overrides: <Override>[
          clockProvider.overrideWithValue(createWidgetTestClock()),
          idGeneratorProvider.overrideWithValue(SequentialIdGenerator()),
          databaseFactoryProvider.overrideWithValue(() => database),
          profileRepositoryAppOverride,
          programRepositoryAppOverride,
          nutritionPolicyProvider.overrideWithValue(
            NutritionPolicy.np100(status: PolicyApprovalStatus.approved),
          ),
        ],
      );
      addTearDown(firstRun.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: firstRun,
          child: const MealoraApp(),
        ),
      );
      await tester.pumpAndSettle();
      await firstRun.read(onboardingControllerProvider.future);
      final notifier = firstRun.read(onboardingControllerProvider.notifier);
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
      notifier.goToStep(OnboardingStep.review);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Setujui & mulai program'));
      await tester.pumpAndSettle();

      final beforeHistory = await firstRun.read(programHistoryProvider.future);
      expect(beforeHistory, hasLength(1));
      final beforeEntry = beforeHistory.single;

      // Jalan kedua: KONTAINER BARU di atas basis data yang sama, tapi
      // kebijakan sekarang DRAFT (seolah versi/status kebijakan diganti di
      // lingkungan uji). Bila riwayat menghitung ulang terhadap kebijakan
      // yang berlaku SEKARANG, ini akan mengubah atau menolak nilainya —
      // seharusnya tidak sama sekali (Design D6: riwayat dibaca apa adanya).
      final secondRun = ProviderContainer(
        overrides: <Override>[
          clockProvider.overrideWithValue(createWidgetTestClock()),
          idGeneratorProvider.overrideWithValue(SequentialIdGenerator()),
          databaseFactoryProvider.overrideWithValue(() => database),
          profileRepositoryAppOverride,
          programRepositoryAppOverride,
          nutritionPolicyProvider.overrideWithValue(
            NutritionPolicy.np100(status: PolicyApprovalStatus.draft),
          ),
        ],
      );
      addTearDown(secondRun.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: secondRun,
          child: const MealoraApp(),
        ),
      );
      await tester.pumpAndSettle();

      final afterHistory = await secondRun.read(programHistoryProvider.future);
      expect(afterHistory, hasLength(1));
      final afterEntry = afterHistory.single;

      expect(afterEntry.id, beforeEntry.id);
      expect(
        afterEntry.proposal.energyTarget?.kcal,
        beforeEntry.proposal.energyTarget?.kcal,
      );
      expect(
        afterEntry.proposal.policyVersion,
        beforeEntry.proposal.policyVersion,
      );
      expect(
        afterEntry.proposal.calculatorVersion,
        beforeEntry.proposal.calculatorVersion,
      );
      expect(afterEntry.proposal.warnings, beforeEntry.proposal.warnings);
      expect(afterEntry.state, beforeEntry.state);

      final afterById = await secondRun.read(
        programByIdProvider(beforeEntry.id).future,
      );
      expect(
        afterById?.proposal.energyTarget?.kcal,
        beforeEntry.proposal.energyTarget?.kcal,
      );
    },
  );

  group('Keadaan khusus (task 3.5)', () {
    testWidgets(
      'belum ada program mengajak memilih program dan menegaskan catatan '
      'lama tetap ada (task 3.1)',
      (tester) async {
        await useDesignViewport(tester);
        final database = createWidgetTestDatabase();
        addTearDown(database.close);
        await bootstrapWithActiveProgram(tester, database: database);
        await openProgramTab(tester);
        await tapVisible(tester, find.text('Jeda'));
        await tapVisible(tester, find.text('Selesaikan program'));
        await tapVisible(tester, find.text('Pilih alasan'));
        await tapVisible(tester, find.text('Saya sudah mencapai tujuan'));
        await tapVisible(tester, find.text('Ya, selesaikan program'));

        expect(find.text('Pilih programmu'), findsOneWidget);
        expect(
          find.text('Catatan lamamu tetap ada dan bisa dibuka.'),
          findsOneWidget,
        );
        expect(find.text('Belum ada program aktif'), findsOneWidget);
        expect(
          find.text(
            'Pilih satu dari empat program. Kamu akan meninjau input, '
            'asumsi, dan target sebelum menyetujui.',
          ),
          findsOneWidget,
        );
        expect(find.text('Data sebelumnya aman'), findsOneWidget);
        expect(
          find.text(
            'Catatan makanan dan berat lama tetap ada meski kamu belum '
            'memilih program.',
          ),
          findsOneWidget,
        );
        expect(find.text('Pilih program'), findsOneWidget);
      },
    );

    testWidgets(
      'profil belum lengkap mengajak melengkapi profil, bukan menampilkan '
      'target (task 3.2)',
      (tester) async {
        // Jaring pengaman: `_OnboardingGate` (app/bootstrap.dart) seharusnya
        // sudah menahan profil tidak lengkap sebelum `ProgramScreen` pernah
        // dirender di aplikasi nyata — keadaan ini diuji langsung terhadap
        // widget dengan provider yang di-override, bukan lewat navigasi
        // penuh (lihat catatan tasks.md group 3).
        final database = createWidgetTestDatabase();
        addTearDown(database.close);
        final container = ProviderContainer(
          overrides: <Override>[
            clockProvider.overrideWithValue(createWidgetTestClock()),
            idGeneratorProvider.overrideWithValue(SequentialIdGenerator()),
            databaseFactoryProvider.overrideWithValue(() => database),
            profileRepositoryAppOverride,
            programRepositoryAppOverride,
          ],
        );
        addTearDown(container.dispose);
        // `appDatabaseProvider` melempar sampai `storageProvider` pernah
        // diselesaikan — biasanya dipicu oleh gerbang peluncuran
        // (`_OnboardingGate`) saat widget tree dipompa; di sini `ProgramScreen`
        // dipompa langsung tanpa gerbang itu, jadi dipicu manual lebih dulu.
        await container.read(storageProvider.future);
        await container
            .read(profileRepositoryProvider)
            .upsert(const UserProfile(id: 'p1', isOnboardingComplete: false));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              localizationsDelegates: AppText.localizationsDelegates,
              supportedLocales: AppText.supportedLocales,
              locale: Locale('id'),
              home: ProgramScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Lengkapi profil dulu'), findsOneWidget);
        expect(
          find.text(
            'Beberapa data profil belum lengkap, jadi target program '
            'belum bisa dijelaskan di sini.',
          ),
          findsOneWidget,
        );
        expect(find.text('Lengkapi profil'), findsOneWidget);
        // Tidak boleh ada satu pun angka target pada keadaan ini.
        expect(find.textContaining('kkal'), findsNothing);
      },
    );

    testWidgets(
      'belum ada catatan berat dinyatakan apa adanya, bukan 0 kg (task 3.3)',
      (tester) async {
        await useDesignViewport(tester);
        final database = createWidgetTestDatabase();
        addTearDown(database.close);
        await bootstrapWithActiveProgram(tester, database: database);
        await openProgramTab(tester);

        expect(find.text('Berat terbaru'), findsOneWidget);
        expect(find.text('Belum ada catatan berat'), findsOneWidget);
        expect(find.textContaining('0 kg'), findsNothing);
      },
    );

    testWidgets(
      'kebijakan tidak tersedia pada jalur ganti program dijelaskan tanpa '
      'satu pun angka target, program lama tetap berjalan (task 3.4)',
      (tester) async {
        await useDesignViewport(tester);
        final database = createWidgetTestDatabase();
        addTearDown(database.close);

        List<Override> overrides() => <Override>[
          clockProvider.overrideWithValue(createWidgetTestClock()),
          idGeneratorProvider.overrideWithValue(SequentialIdGenerator()),
          databaseFactoryProvider.overrideWithValue(() => database),
          profileRepositoryAppOverride,
          programRepositoryAppOverride,
        ];

        // Jalan pertama: kebijakan DISETUJUI, program diaktifkan seperti
        // biasa.
        final firstRun = ProviderContainer(overrides: overrides());
        addTearDown(firstRun.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: firstRun,
            child: const MealoraApp(),
          ),
        );
        await tester.pumpAndSettle();
        await bootstrapWithActiveProgram(tester, database: database);

        // Jalan kedua: KONTAINER BARU di atas basis data yang sama, kali ini
        // kebijakan DRAFT (seolah ditarik/direvisi) — meniru pola uji 7.6.
        final secondRun = ProviderContainer(
          overrides: <Override>[
            ...overrides(),
            nutritionPolicyProvider.overrideWithValue(
              NutritionPolicy.np100(status: PolicyApprovalStatus.draft),
            ),
          ],
        );
        addTearDown(secondRun.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: secondRun,
            child: const MealoraApp(),
          ),
        );
        await tester.pumpAndSettle();

        await openProgramTab(tester);
        await tapVisible(tester, find.text('Ganti'));
        await tapVisible(tester, find.text('Tinjau target pengganti'));

        // Pilih program pengganti apa pun lalu lanjutkan.
        await tapVisible(tester, find.text('Pertahankan'));
        await tapVisible(tester, find.text('Tinjau target pengganti'));
        await tester.pumpAndSettle();

        expect(find.byType(ProgramRevisionReviewScreen), findsOneWidget);
        expect(find.text('Target tidak dibuat'), findsOneWidget);
        expect(find.text('Target otomatis tidak tersedia'), findsOneWidget);
        expect(
          find.text('Mealora tidak bisa menghitung target otomatis saat ini.'),
          findsOneWidget,
        );
        expect(
          find.text('Program dan target yang berjalan tidak berubah.'),
          findsOneWidget,
        );
        expect(find.textContaining('kkal'), findsNothing);

        // Program lama tetap berjalan tanpa perubahan.
        final profile = await secondRun
            .read(profileRepositoryProvider)
            .current();
        final running = await secondRun
            .read(programRepositoryProvider)
            .findRunning(profile!.id);
        expect(running, isNotNull);
        expect(running!.state.name, 'active');
        expect(running.programCode, ProgramCode.healthyEating);
      },
    );
  });

  group('Skala teks besar di luar ruang Program (task 9.4)', () {
    testWidgets(
      'riwayat, detail, Bagaimana dihitung, selesaikan, ganti, dan ubah '
      'profil tetap terbaca pada skala 2x',
      (tester) async {
        await useDesignViewport(tester);
        final database = createWidgetTestDatabase();
        addTearDown(database.close);
        await bootstrapWithActiveProgram(tester, database: database);

        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await openProgramTab(tester);
        expect(tester.takeException(), isNull);

        // Riwayat + detail.
        await tapVisible(
          tester,
          find.descendant(
            of: find.byType(ProgramScreen),
            matching: find.text('Riwayat'),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(ProgramHistoryListScreen), findsOneWidget);
        await tapVisible(tester, find.text('Makan Sehat'));
        expect(tester.takeException(), isNull);
        expect(find.byType(ProgramDetailHistoryScreen), findsOneWidget);
        await tapVisible(tester, find.byIcon(Icons.arrow_back).first);
        expect(find.byType(ProgramHistoryListScreen), findsOneWidget);
        await tapVisible(tester, find.byIcon(Icons.arrow_back).first);
        expect(find.byType(ProgramScreen), findsOneWidget);

        // Bagaimana dihitung.
        await tapVisible(tester, find.text('Bagaimana dihitung'));
        expect(tester.takeException(), isNull);
        expect(find.byType(HowCalculatedScreen), findsOneWidget);
        await tapVisible(tester, find.byIcon(Icons.arrow_back).first);

        // Jeda dulu — "Selesaikan program" hanya ada di daftar kendali
        // keadaan dijeda (task 2.6), bukan di baris tiga tombol aktif.
        await tapVisible(tester, find.text('Jeda'));
        expect(tester.takeException(), isNull);

        // Selesaikan program (sampai pemilihan alasan, dibatalkan).
        await tapVisible(tester, find.text('Selesaikan program'));
        expect(tester.takeException(), isNull);
        expect(find.byType(CompleteProgramScreen), findsOneWidget);
        await tapVisible(tester, find.text('Pilih alasan'));
        expect(tester.takeException(), isNull);
        await tapVisible(tester, find.text('Saya sudah mencapai tujuan'));
        expect(tester.takeException(), isNull);
        await tapVisible(tester, find.text('Batal, tetap di program ini'));

        // Ganti program (sampai pratinjau pengganti) — kendali keadaan
        // dijeda juga berlabel "Ganti" (`text.programChangeAction`), sama
        // dengan tombol keadaan aktif.
        await tapVisible(tester, find.text('Ganti'));
        expect(tester.takeException(), isNull);
        expect(find.byType(ProgramChangePreviewScreen), findsOneWidget);
        await tapVisible(tester, find.text('Tinjau target pengganti'));
        expect(tester.takeException(), isNull);
        await tapVisible(tester, find.text('Pertahankan'));
        expect(tester.takeException(), isNull);
        await tapVisible(tester, find.text('Tinjau target pengganti'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(ProgramRevisionReviewScreen), findsOneWidget);
      },
    );

    testWidgets('ubah profil tetap terbaca pada skala 2x', (tester) async {
      await useDesignViewport(tester);
      final database = createWidgetTestDatabase();
      addTearDown(database.close);
      await bootstrapWithActiveProgram(tester, database: database);

      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      // Ruang Profil berada di navigator akar (di atas `AppShell`) — beda
      // dari `ProgramChangePreviewScreen`/`ProgramRevisionReviewScreen` di
      // uji sebelumnya yang di-push di atasnya dan membuat
      // `FloatingNavigation` offstage; di sini masih onstage sejak awal.
      await tester.tap(
        find.descendant(
          of: find.byType(FloatingNavigation),
          matching: find.text('Profil'),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tapVisible(tester, find.text('Ubah profil'));
      expect(tester.takeException(), isNull);
      expect(find.byType(EditProfileScreen), findsOneWidget);
    });
  });

  group('Label pembaca layar (task 9.2)', () {
    testWidgets(
      'penanda keadaan program dan kendali inti punya label pembaca layar '
      'eksplisit',
      (tester) async {
        // Handle semantics dilepas di akhir badan uji (bukan `addTearDown`)
        // karena verifikasi flutter_test berjalan sebelum tear-down — lihat
        // pola yang sama di `app_shell_test.dart`.
        final semantics = tester.ensureSemantics();
        await useDesignViewport(tester);
        final database = createWidgetTestDatabase();
        addTearDown(database.close);
        await bootstrapWithActiveProgram(tester, database: database);
        await openProgramTab(tester);

        expect(find.bySemanticsLabel('Berjalan'), findsOneWidget);
        expect(find.bySemanticsLabel('Jeda'), findsOneWidget);
        expect(find.bySemanticsLabel('Ganti'), findsOneWidget);
        // "Riwayat" juga dipakai sebagai label tab navigasi bawah (ruang
        // lain, change 001/004) — dibatasi ke dalam `ProgramScreen` saja.
        expect(
          find.descendant(
            of: find.byType(ProgramScreen),
            matching: find.bySemanticsLabel('Riwayat'),
          ),
          findsOneWidget,
        );
        expect(find.bySemanticsLabel('Bagaimana dihitung'), findsOneWidget);

        // Entri riwayat (keadaan aktif masih punya kendali "Riwayat"
        // langsung — keadaan dijeda tidak, lihat task 2.6).
        await tapVisible(
          tester,
          find.descendant(
            of: find.byType(ProgramScreen),
            matching: find.text('Riwayat'),
          ),
        );
        expect(
          find.bySemanticsLabel(
            RegExp('Makan Sehat. Aktif.*Lihat target, input'),
          ),
          findsOneWidget,
        );
        await tapVisible(tester, find.byIcon(Icons.arrow_back).first);

        await tapVisible(tester, find.text('Jeda'));
        expect(find.bySemanticsLabel('Dijeda'), findsOneWidget);
        expect(find.bySemanticsLabel('Lanjutkan program'), findsOneWidget);
        expect(find.bySemanticsLabel('Ganti'), findsOneWidget);
        expect(find.bySemanticsLabel('Selesaikan program'), findsOneWidget);
        semantics.dispose();
      },
    );
  });
}
