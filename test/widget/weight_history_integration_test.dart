import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/app.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/program/commands/activate_program_command.dart';
import 'package:mealora/domain/program/commands/activation_result.dart';
import 'package:mealora/domain/program/nutrition_policy.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_engine.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/program/program_specific_input.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/shell/floating_navigation.dart';
import 'package:mealora/features/weight/add_weight_screen.dart';
import 'package:mealora/features/weight/weight_monitor_screen.dart';

import 'harness.dart';

/// Alur lintas layar (change 008, task 6.6, bagian pencatatan berat):
/// ruang Program → Pantau berat → Tambah berat → simpan → kembali ke
/// Program, seluruhnya lewat navigasi sungguhan (bukan memompa satu layar
/// terisolasi) di atas penyimpanan in-memory nyata. Tidak ada kode di
/// aplikasi ini yang mengakses jaringan — persis kondisi mode pesawat.
///
/// Bagian riwayat harian (sunting catatan makan hari lampau → kemajuan
/// menyesuaikan) sudah dibuktikan terpisah: `history_calendar_test.dart`
/// (navigasi tanggal, ringkasan nyata) dan `drift_diary_repository_test.dart`
/// (penyuntingan memicu pembangunan ulang potret untuk tanggal catatan,
/// bukan hari ini — change 007, dipakai ulang apa adanya oleh ruang
/// Riwayat).
void main() {
  const profileId = 'profile-1';

  Future<void> bootstrap(
    WidgetTester tester, {
    required AppDatabase database,
  }) async {
    await DriftProfileRepository(
      database,
      clock: createWidgetTestClock(),
    ).upsert(
      const UserProfile(
        id: profileId,
        birthDate: LocalDate(1997, 5, 20),
        biologicalInput: BiologicalInput.female,
        activityLevel: ActivityLevel.moderatelyActive,
        isOnboardingComplete: true,
      ),
    );

    final programRepository = DriftProgramRepository(
      database,
      clock: createWidgetTestClock(),
      ids: SequentialIdGenerator(),
    );
    final engine = ProgramEngine(
      NutritionPolicy.np100(status: PolicyApprovalStatus.approved),
    );
    final inputs = ProgramProposalInputs(
      ageYears: 29,
      biologicalInput: BiologicalInput.female,
      height: Length.cmValue(165, field: 'h').valueOrNull!,
      currentWeight: Mass.kgValue(70, field: 'w').valueOrNull!,
      activity: ActivityLevel.moderatelyActive,
      specific: ProgramSpecificInput(
        targetWeight: Mass.kgValue(60, field: 'target').valueOrNull,
      ),
    );
    final activation =
        await ActivateProgramCommand(
          repository: programRepository,
          clock: createWidgetTestClock(),
          idGenerator: SequentialIdGenerator(),
          engine: engine,
        ).execute(
          profileId: profileId,
          program: ProgramCode.weightLoss,
          previewInputs: inputs,
          currentInputs: inputs,
          userConfirmed: true,
          programRequiresTargetWeight: true,
          programRequiresHabitFocus: false,
        );
    expect(activation, isA<ActivationSucceeded>());

    final container = ProviderContainer(
      overrides: <Override>[
        clockProvider.overrideWithValue(createWidgetTestClock()),
        idGeneratorProvider.overrideWithValue(SequentialIdGenerator()),
        databaseFactoryProvider.overrideWithValue(() => database),
        profileRepositoryAppOverride,
        programRepositoryAppOverride,
        foodRepositoryAppOverride,
        diaryRepositoryAppOverride,
        weightRepositoryAppOverride,
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
  }

  testWidgets(
    'mencatat berat dari ruang Program langsung terlihat di kartu berat '
    'terbaru tanpa memulai ulang layar',
    (tester) async {
      await useDesignViewport(tester);
      final database = createWidgetTestDatabase();
      addTearDown(database.close);
      await bootstrap(tester, database: database);

      await tester.tap(
        find.descendant(
          of: find.byType(FloatingNavigation),
          matching: find.text('Program'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Belum ada catatan berat'), findsOneWidget);

      await tester.ensureVisible(find.text('Belum ada catatan berat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Belum ada catatan berat'));
      await tester.pumpAndSettle();
      expect(find.byType(WeightMonitorScreen), findsOneWidget);
      expect(find.text('Belum ada catatan berat'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add_rounded).last);
      await tester.pumpAndSettle();
      expect(find.byType(AddWeightScreen), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '68,4');
      await tester.tap(find.text('Simpan berat'));
      await tester.pumpAndSettle();

      expect(find.byType(WeightMonitorScreen), findsOneWidget);
      expect(find.textContaining('68,4'), findsWidgets);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Belum ada catatan berat'), findsNothing);
      expect(find.textContaining('68,4'), findsWidgets);
    },
  );
}
