import 'package:flutter/material.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Empat ruang utama Mealora.
///
/// Urutan enum menentukan urutan tampil di navigasi; [storageKey] dipakai
/// untuk menyimpan ruang terpilih dan tidak boleh berubah sembarangan karena
/// nilainya sudah ada di perangkat pengguna.
enum MealoraDestination {
  today('today', Icons.home_outlined, Icons.home_rounded),
  program('program', Icons.restaurant_outlined, Icons.restaurant_rounded),
  history(
    'history',
    Icons.calendar_month_outlined,
    Icons.calendar_month_rounded,
  ),
  profile('profile', Icons.person_outline_rounded, Icons.person_rounded);

  const MealoraDestination(this.storageKey, this.icon, this.selectedIcon);

  final String storageKey;

  /// Ikon ruang saat tidak aktif.
  final IconData icon;

  /// Ikon ruang saat aktif — bentuknya berbeda, bukan hanya warnanya, supaya
  /// keadaan terpilih tidak bergantung pada warna saja.
  final IconData selectedIcon;

  String label(AppText text) => switch (this) {
    MealoraDestination.today => text.navToday,
    MealoraDestination.program => text.navProgram,
    MealoraDestination.history => text.navHistory,
    MealoraDestination.profile => text.navProfile,
  };

  static MealoraDestination? fromStorageKey(String? key) {
    if (key == null) {
      return null;
    }
    for (final destination in MealoraDestination.values) {
      if (destination.storageKey == key) {
        return destination;
      }
    }
    return null;
  }
}
