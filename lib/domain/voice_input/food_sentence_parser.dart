import 'package:mealora/domain/image_ai_access/label_service_failure.dart';

/// Status satuan dari penguraian (change 012, design D5) — kontrak yang
/// sama dengan keluaran proksi `/parse-food-text`.
enum ParsedUnitStatus {
  /// Satuan termasuk daftar baku (piring, potong, gram, …).
  standard,

  /// Satuan disebut tetapi tidak baku ("sepotong besar") — SHALL ditetapkan
  /// pengguna dari takaran yang tersedia (task 7.3).
  nonstandard,

  /// Satuan tidak disebut.
  missing,
}

/// Siapa yang mengurai kalimat (design D14).
enum ParseSource {
  /// Model lewat proksi.
  service,

  /// Pengurai aturan di perangkat — cadangan; setiap komponennya perlu
  /// diperiksa dan layar menyatakan "diurai tanpa koneksi" (task 5.10).
  onDevice,
}

/// Satu makanan usulan hasil penguraian.
///
/// Sengaja TIDAK punya bidang nilai gizi: angka gizi dari model tidak
/// pernah dibaca, sehingga tidak ada jalan baginya masuk ke nilai komponen
/// (design D6, task 5.4/5.7). Nilai gizi datang dari padanan katalog.
final class ParsedFoodItem {
  const ParsedFoodItem({
    required this.foodName,
    required this.unitStatus,
    this.quantity,
    this.unit,
    this.needsCheck = false,
  });

  final String foodName;

  /// `null` berarti jumlah tidak disebut atau tidak pasti — SHALL ditanyakan,
  /// tidak pernah ditebak (design D5).
  final double? quantity;

  final String? unit;
  final ParsedUnitStatus unitStatus;

  /// `true` untuk setiap komponen dari pengurai di perangkat (task 5.10).
  final bool needsCheck;

  bool get quantityUndetermined => quantity == null;
}

/// Hasil penguraian satu kalimat.
final class ParsedSentence {
  const ParsedSentence({
    required this.items,
    required this.source,
    this.nonFoodRequests = const <String>[],
  });

  final List<ParsedFoodItem> items;
  final ParseSource source;

  /// Jenis permintaan di luar pencatatan makanan yang terdeteksi — hanya
  /// untuk menyatakan batas cakupan dan menunjukkan tempat yang tepat
  /// (task 6.1). Tidak pernah dijalankan.
  final List<String> nonFoodRequests;

  bool get hasItems => items.isNotEmpty;
}

/// Hasil [FoodSentenceParser.parse] — sealed supaya kegagalan tidak pernah
/// diam-diam menjadi daftar kosong.
sealed class FoodSentenceParseOutcome {
  const FoodSentenceParseOutcome();
}

final class FoodSentenceParsed extends FoodSentenceParseOutcome {
  const FoodSentenceParsed(this.sentence);

  final ParsedSentence sentence;
}

final class FoodSentenceParseUnavailable extends FoodSentenceParseOutcome {
  const FoodSentenceParseUnavailable(this.reason);

  /// Alasan yang sama dengan jalur gambar change 010: luring, waktu tunggu
  /// lewat, kuota habis, atau ditolak (task 5.6).
  final LabelServiceFailureReason reason;
}

/// Pengurai kalimat pencatatan makanan (change 012, design D3/D14).
///
/// Implementasi SHALL TIDAK melempar pengecualian ke pemanggil, dan SHALL
/// hanya menerima teks — tidak pernah rekaman suara (task 5.2).
abstract interface class FoodSentenceParser {
  Future<FoodSentenceParseOutcome> parse(String sentence);
}
