import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/program/program_command.dart';
import 'package:mealora/domain/program/program_lifecycle.dart';
import 'package:mealora/domain/program/program_state.dart';

/// Tabel perpindahan yang sah, dari program-lifecycle spec. Ini adalah
/// oracle independen yang dibandingkan terhadap `ProgramLifecycle` —
/// menuliskannya tangan di sini (bukan menyalin tabel implementasi) agar
/// lubang di implementasi ketahuan sebagai kegagalan uji.
const _allowed = <(ProgramState, ProgramCommand), ProgramState>{
  (ProgramState.draft, ProgramCommand.activate): ProgramState.active,
  (ProgramState.draft, ProgramCommand.cancel): ProgramState.cancelled,
  (ProgramState.active, ProgramCommand.pause): ProgramState.paused,
  (ProgramState.active, ProgramCommand.complete): ProgramState.completed,
  (ProgramState.active, ProgramCommand.change): ProgramState.changed,
  (ProgramState.active, ProgramCommand.cancel): ProgramState.cancelled,
  (ProgramState.paused, ProgramCommand.resume): ProgramState.active,
  (ProgramState.paused, ProgramCommand.complete): ProgramState.completed,
  (ProgramState.paused, ProgramCommand.change): ProgramState.changed,
  (ProgramState.paused, ProgramCommand.cancel): ProgramState.cancelled,
};

void main() {
  test(
    'uji matriks: seluruh pasangan (keadaan, perintah) punya hasil yang ditegaskan',
    () {
      for (final state in ProgramState.values) {
        for (final command in ProgramCommand.values) {
          final outcome = ProgramLifecycle.transition(state, command);
          final expectedNext = _allowed[(state, command)];

          if (expectedNext == null) {
            expect(
              outcome,
              isA<TransitionDenied>(),
              reason: '($state, $command) seharusnya ditolak',
            );
            final denied = outcome as TransitionDenied;
            expect(denied.error.currentState, state);
            expect(denied.error.command, command);
          } else {
            expect(
              outcome,
              isA<TransitionAllowed>(),
              reason: '($state, $command) seharusnya sah -> $expectedNext',
            );
            expect((outcome as TransitionAllowed).nextState, expectedNext);
          }
        }
      }
    },
  );

  test('keadaan akhir tidak dapat keluar sama sekali', () {
    for (final terminal in [
      ProgramState.completed,
      ProgramState.changed,
      ProgramState.cancelled,
    ]) {
      for (final command in ProgramCommand.values) {
        expect(
          ProgramLifecycle.transition(terminal, command),
          isA<TransitionDenied>(),
          reason: '$terminal + $command seharusnya ditolak',
        );
      }
    }
  });

  test(
    'melanjutkan program yang sudah selesai ditolak dan tidak mengubah keadaan',
    () {
      final outcome = ProgramLifecycle.transition(
        ProgramState.completed,
        ProgramCommand.resume,
      );
      expect(
        outcome,
        isA<TransitionDenied>().having(
          (o) => o.error,
          'error',
          const InvalidProgramTransition(
            currentState: ProgramState.completed,
            command: ProgramCommand.resume,
          ),
        ),
      );
    },
  );

  test('menjeda program draf ditolak', () {
    expect(
      ProgramLifecycle.transition(ProgramState.draft, ProgramCommand.pause),
      isA<TransitionDenied>(),
    );
  });

  group('invarian satu program berjalan', () {
    test('kosong atau satu program berjalan memenuhi invarian', () {
      expect(
        ProgramLifecycle.satisfiesSingleRunningInvariant(const []),
        isTrue,
      );
      expect(
        ProgramLifecycle.satisfiesSingleRunningInvariant(const [
          ProgramState.active,
        ]),
        isTrue,
      );
      expect(
        ProgramLifecycle.satisfiesSingleRunningInvariant(const [
          ProgramState.paused,
        ]),
        isTrue,
      );
    });

    test('draf dan riwayat tidak melanggar invarian', () {
      expect(
        ProgramLifecycle.satisfiesSingleRunningInvariant(const [
          ProgramState.active,
          ProgramState.draft,
          ProgramState.completed,
          ProgramState.changed,
          ProgramState.cancelled,
        ]),
        isTrue,
      );
    });

    test('dua program berjalan sekaligus melanggar invarian', () {
      expect(
        ProgramLifecycle.satisfiesSingleRunningInvariant(const [
          ProgramState.active,
          ProgramState.paused,
        ]),
        isFalse,
      );
    });
  });
}
