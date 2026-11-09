import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/features/onboarding/onboarding_flow.dart';
import 'package:mealora/features/shell/app_shell.dart';
import 'package:mealora/features/splash/splash_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Gerbang peluncuran: splash selama penyimpanan disiapkan, keadaan kesalahan
/// yang dapat dibaca bila gagal, lalu ruang utama.
///
/// Splash tidak pernah menggantung tanpa akhir: kegagalan apa pun berakhir
/// pada keadaan kesalahan dengan tindakan lanjutan.
class MealoraBootstrap extends ConsumerWidget {
  const MealoraBootstrap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageProvider);

    return storage.when(
      loading: SplashScreen.new,
      error: (error, stackTrace) =>
          _StorageError(detail: '$error', onRetry: () => _retry(ref)),
      data: (result) => switch (result) {
        Ok<AppDatabase>() => const _OnboardingGate(),
        Err<AppDatabase>(:final failure) => _StorageError(
          detail: failure.code.name,
          onRetry: () => _retry(ref),
        ),
      },
    );
  }

  void _retry(WidgetRef ref) => ref.invalidate(storageProvider);
}

/// Gerbang antara onboarding dan ruang utama (Design D2, change 005) —
/// dibaca hanya setelah penyimpanan siap, sehingga `profileRepositoryProvider`
/// aman diakses.
class _OnboardingGate extends ConsumerWidget {
  const _OnboardingGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isComplete = ref.watch(isOnboardingCompleteProvider);

    return isComplete.when(
      loading: () => const SplashScreen(),
      error: (error, stackTrace) => const OnboardingFlow(),
      data: (complete) => complete ? const AppShell() : const OnboardingFlow(),
    );
  }
}

class _StorageError extends StatelessWidget {
  const _StorageError({required this.detail, required this.onRetry});

  final String detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MealoraSpacing.xl),
            child: MealoraErrorState(
              title: text.storageErrorTitle,
              body: text.storageErrorBody,
              detailLabel: text.storageErrorReasonLabel,
              detail: detail,
              action: MealoraPrimaryButton(
                label: text.retry,
                onPressed: onRetry,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
