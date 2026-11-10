import 'package:mealora/core/clock/clock.dart';

/// Satu catatan berat badan (change 008, design D1).
///
/// Berat "saat ini" bukan nilai tersendiri — ia adalah [WeightRecord]
/// terbaru menurut [recordedAt]/[localDate]. Lihat
/// `WeightRepository.latest`.
final class WeightRecord {
  const WeightRecord({
    required this.id,
    required this.profileId,
    required this.localDate,
    required this.recordedAt,
    required this.weightKg,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String profileId;
  final LocalDate localDate;
  final DateTime recordedAt;
  final double weightKg;
  final String? note;
  final DateTime createdAt;
}
