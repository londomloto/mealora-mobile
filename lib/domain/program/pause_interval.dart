/// Satu rentang jeda — jeda dicatat sebagai rentang, bukan penanda
/// tunggal, sehingga seluruh riwayat jeda tetap dapat ditelusuri setelah
/// program dilanjutkan (Design D8).
final class PauseInterval {
  const PauseInterval({required this.startedAt, this.endedAt});

  final DateTime startedAt;

  /// `null` berarti jeda ini masih berlangsung.
  final DateTime? endedAt;

  PauseInterval ended(DateTime at) =>
      PauseInterval(startedAt: startedAt, endedAt: at);

  bool get isOpen => endedAt == null;
}
