import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/app.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';
import 'package:mealora/features/shell/app_shell.dart';
import 'package:mealora/features/splash/splash_screen.dart';
import 'package:mealora/features/today/today_screen.dart';

import '../support/fake_reminder_gateway.dart';
import 'harness.dart';

/// Uji integrasi alur penuh (task 7.5): pemasangan baru → onboarding →
/// aktivasi → ruang Hari ini → tutup aplikasi → buka kembali → program
/// masih aktif. Berjalan di atas basis data in-memory nyata lewat
/// [MealoraApp] utuh (bukan hanya `OnboardingFlow`), sehingga gerbang
/// peluncuran ikut teruji — setara dengan mode pesawat karena tidak ada
/// permintaan jaringan di mana pun pada alur ini.
void main() {
  testWidgets(
    'pemasangan baru sampai program aktif bertahan melewati penutupan '
    'aplikasi (scenario 6.1)',
    (tester) async {
      await useDesignViewport(tester);
      final database = createWidgetTestDatabase();
      addTearDown(database.close);

      List<Override> overrides() => <Override>[
        clockProvider.overrideWithValue(createWidgetTestClock()),
        reminderNotificationGatewayProvider.overrideWithValue(
          FakeReminderGateway(),
        ),
        idGeneratorProvider.overrideWithValue(SequentialIdGenerator()),
        databaseFactoryProvider.overrideWithValue(() => database),
        profileRepositoryAppOverride,
        programRepositoryAppOverride,
      ];

      final firstRun = ProviderContainer(overrides: overrides());
      addTearDown(firstRun.dispose);

      // Pemasangan baru: splash lalu onboarding (belum ada profil).
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: firstRun,
          child: const MealoraApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.text('Mulai perjalanan'), findsOneWidget);

      // Isian profil, aktivitas, dan pilihan program lewat notifier —
      // alur UI layar demi layar sudah diuji di onboarding_flow_test.dart;
      // di sini fokusnya adalah ketahanan status lintas penutupan aplikasi.
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
      expect(find.text('Tinjau targetmu'), findsOneWidget);

      await tester.tap(find.text('Setujui & mulai program'));
      await tester.pumpAndSettle();

      // Mendarat di ruang Hari ini dengan program aktif terbaca (task 5.5,
      // 7.1/7.2).
      expect(find.byType(TodayScreen), findsOneWidget);
      expect(find.text('Makan Sehat'), findsOneWidget);

      // Tutup aplikasi: buang seluruh container/pohon widget pertama. Basis
      // data tetap terbuka, sama seperti proses dihentikan sementara
      // berkasnya tetap ada di perangkat.
      await tester.pumpWidget(const SizedBox.shrink());

      final secondRun = ProviderContainer(overrides: overrides());
      addTearDown(secondRun.dispose);

      // Buka kembali dengan container baru (pemasangan ulang aplikasi).
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: secondRun,
          child: const MealoraApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Langsung ke AppShell — profil sudah lengkap (Design D2), program
      // masih aktif.
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byType(TodayScreen), findsOneWidget);
      expect(find.text('Makan Sehat'), findsOneWidget);
    },
  );
}
