import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/features/onboarding/activity_screen.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';
import 'package:mealora/features/onboarding/profile_basics_screen.dart';
import 'package:mealora/features/onboarding/program_detail_screen.dart';
import 'package:mealora/features/onboarding/program_select_screen.dart';
import 'package:mealora/features/onboarding/review_screen.dart';
import 'package:mealora/features/onboarding/target_weight_screen.dart';
import 'package:mealora/features/onboarding/welcome_screen.dart';

/// Tuan rumah alur onboarding (change 005): menampilkan layar yang sesuai
/// dengan `OnboardingDraft.currentStep` (Design D9) — satu wadah state,
/// berpindah layar tanpa menumpuk rute navigasi, sehingga navigasi
/// maju-mundur (task 3.4) hanya mengubah `currentStep`.
class OnboardingFlow extends ConsumerWidget {
  const OnboardingFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);

    return draft.when(
      loading: () => const Scaffold(
        backgroundColor: MealoraColors.background,
        body: SizedBox.shrink(),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: MealoraColors.background,
        body: Center(child: Text('$error')),
      ),
      data: (value) => switch (value.currentStep) {
        OnboardingStep.welcome => const OnboardingWelcomeScreen(),
        OnboardingStep.profileBasics => const OnboardingProfileBasicsScreen(),
        OnboardingStep.activity => const OnboardingActivityScreen(),
        OnboardingStep.programSelect => const OnboardingProgramSelectScreen(),
        OnboardingStep.programDetail => const OnboardingProgramDetailScreen(),
        OnboardingStep.targetWeight => const OnboardingTargetWeightScreen(),
        OnboardingStep.review => const OnboardingReviewScreen(),
      },
    );
  }
}
