import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/serving_size.dart';

/// Satu entri "terakhir dicatat" (Design D4, change 007): makanan yang
/// terakhir dicatat profil ini, beserta takaran yang terakhir dipakai untuk
/// makanan itu. Diturunkan dari buku harian, bukan tabel riwayat pencarian
/// tersendiri.
final class RecentFood {
  const RecentFood({
    required this.food,
    required this.lastServing,
    required this.lastLoggedAt,
  });

  final Food food;
  final ServingSize lastServing;
  final DateTime lastLoggedAt;
}
