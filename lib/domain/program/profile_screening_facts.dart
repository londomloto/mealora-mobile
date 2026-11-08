import 'package:mealora/domain/program/declared_condition.dart';

/// Perubahan berat tidak disengaja yang dilaporkan pengguna (B9).
final class UnintendedWeightChange {
  const UnintendedWeightChange({
    required this.percentOfBodyWeight,
    required this.windowDays,
  });

  final double percentOfBodyWeight;
  final int windowDays;
}

/// Jawaban skrining kelayakan yang sama untuk seluruh program (B1–B9).
final class ProfileScreeningFacts {
  const ProfileScreeningFacts({
    this.isPregnantOrLactating = false,
    this.declaredConditions = const <DeclaredCondition>{},
    this.unintendedWeightChange,
  });

  final bool isPregnantOrLactating;
  final Set<DeclaredCondition> declaredConditions;
  final UnintendedWeightChange? unintendedWeightChange;
}
