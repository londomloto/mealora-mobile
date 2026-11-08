/// Pembulatan kanonis.
///
/// Satu tempat untuk aturan "setengah ke atas, menjauhi nol" yang dipakai
/// seluruh domain program dan nutrisi (Lampiran A, dokumen kebijakan gizi).
/// Pembulatan hanya dipanggil pada nilai akhir, tidak pernah pada nilai
/// antara perhitungan.
library;

abstract final class Rounding {
  /// Membulatkan [value] ke kelipatan [step] terdekat, setengah menjauhi nol.
  static double toNearest(double value, double step) {
    if (value == 0) {
      return 0;
    }
    final sign = value.isNegative ? -1 : 1;
    // Epsilon kecil menetralkan galat pembulatan biner pada titik tepat
    // setengah (mis. 1,25 yang tersimpan sebagai 1,249999999999...).
    const epsilon = 1e-9;
    final steps = (value.abs() / step + 0.5 + epsilon).floorToDouble();
    return sign * steps * step;
  }

  /// Membulatkan [value] ke bilangan bulat terdekat, setengah menjauhi nol.
  static int toNearestInt(double value) => toNearest(value, 1).round();
}
