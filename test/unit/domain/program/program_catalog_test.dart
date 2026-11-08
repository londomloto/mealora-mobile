import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/program/onboarding_field.dart';
import 'package:mealora/domain/program/program_catalog.dart';
import 'package:mealora/domain/program/program_code.dart';

void main() {
  group('ProgramCatalog.np1', () {
    test('berisi tepat empat program dengan kode dan nama yang benar', () {
      const catalog = ProgramCatalog.np1;
      expect(catalog.definitions, hasLength(4));

      final byCode = {for (final d in catalog.definitions) d.code: d};
      expect(byCode[ProgramCode.weightLoss]!.displayName, 'Turun Berat');
      expect(byCode[ProgramCode.weightGain]!.displayName, 'Naik Berat');
      expect(byCode[ProgramCode.maintenance]!.displayName, 'Pertahankan');
      expect(byCode[ProgramCode.healthyEating]!.displayName, 'Makan Sehat');
    });

    test('Makan Sehat tidak meminta berat tujuan', () {
      final healthyEating = ProgramCatalog.np1.definitionFor(
        ProgramCode.healthyEating,
      );
      expect(healthyEating.requiresTargetWeight, isFalse);
      expect(
        healthyEating.requiredInputs,
        isNot(contains(OnboardingField.targetWeight)),
      );
      expect(
        healthyEating.optionalInputs,
        isNot(contains(OnboardingField.targetWeight)),
      );
    });

    test(
      'Turun Berat dan Naik Berat mewajibkan berat tujuan, tanggal opsional',
      () {
        for (final code in [ProgramCode.weightLoss, ProgramCode.weightGain]) {
          final definition = ProgramCatalog.np1.definitionFor(code);
          expect(definition.requiresTargetWeight, isTrue);
          expect(
            definition.requiredInputs,
            contains(OnboardingField.targetWeight),
          );
          expect(
            definition.requiredInputs,
            isNot(contains(OnboardingField.targetDate)),
          );
          expect(
            definition.optionalInputs,
            contains(OnboardingField.targetDate),
          );
        }
      },
    );

    test('Pertahankan tidak mewajibkan berat tujuan', () {
      final maintenance = ProgramCatalog.np1.definitionFor(
        ProgramCode.maintenance,
      );
      expect(maintenance.requiresTargetWeight, isFalse);
    });
  });

  group('penarikan program', () {
    test(
      'program yang ditarik hilang dari pilihan tetapi definisinya tetap terbaca',
      () {
        final withdrawn = ProgramCatalog.np1.withdrawn(
          ProgramCode.healthyEating,
        );

        expect(
          withdrawn.availableForSelection().map((d) => d.code),
          isNot(contains(ProgramCode.healthyEating)),
        );
        expect(withdrawn.availableForSelection(), hasLength(3));

        final stillReadable = withdrawn.definitionFor(
          ProgramCode.healthyEating,
        );
        expect(stillReadable.displayName, 'Makan Sehat');
        expect(stillReadable.intent, isNotEmpty);
        expect(stillReadable.isAvailable, isFalse);
      },
    );

    test('program lain tetap tersedia setelah satu program ditarik', () {
      final withdrawn = ProgramCatalog.np1.withdrawn(ProgramCode.weightLoss);
      expect(withdrawn.availableForSelection(), hasLength(3));
      expect(
        withdrawn.definitionFor(ProgramCode.weightGain).isAvailable,
        isTrue,
      );
    });
  });
}
