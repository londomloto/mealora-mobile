import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/data/local/reminder_settings_repository.dart';
import 'package:mealora/domain/reminders/late_meal_window.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Peringatan makan menjelang tidur (change 013, Design D5).
///
/// Dibaca lewat [lateMealNoticeProvider] SEBELUM layar pencatat menutup
/// dirinya, lalu [maybeShow] dipanggil setelah `Ok` — aman dipakai setelah
/// layar pemanggil dibuang karena tidak lagi menyentuh `WidgetRef`.
class LateMealNotice {
  const LateMealNotice({
    required Clock clock,
    required ReminderSettingsRepository repository,
  }) : _clock = clock,
       _repository = repository;

  /// Lama tampil pesan; tidak memblokir dan bisa ditutup.
  static const Duration displayDuration = Duration(seconds: 8);

  final Clock _clock;
  final ReminderSettingsRepository _repository;

  /// Menampilkan pesan bila [date] (atau hari ini bila `null`) = hari ini,
  /// waktu sekarang di dalam rentang jam tidur, dan belum tampil malam ini.
  /// Mengembalikan `true` bila pesan ditampilkan.
  Future<bool> maybeShow({
    required ScaffoldMessengerState messenger,
    required AppText text,
    LocalDate? date,
  }) async {
    if (date != null && date != _clock.today()) return false;
    final settings = await _repository.load();
    final night = LateMealWindow.nightKey(_clock.localNow(), settings.bedtime);
    if (night == null) return false;
    if (await _repository.lastLateMealNoticeNight() == night) return false;
    await _repository.saveLateMealNoticeNight(night);
    if (!messenger.mounted) return false;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(_snackBar(text));
    return true;
  }

  SnackBar _snackBar(AppText text) => SnackBar(
    behavior: SnackBarBehavior.floating,
    duration: displayDuration,
    showCloseIcon: true,
    closeIconColor: MealoraColors.muted,
    // Solid, bukan glass: SnackBar tidak memburamkan latar, jadi glass
    // tembus pandang membuat teks di belakangnya bertabrakan.
    backgroundColor: MealoraColors.surface,
    elevation: MealoraElevation.raised,
    margin: const EdgeInsets.fromLTRB(
      MealoraSpacing.md,
      0,
      MealoraSpacing.md,
      // Scaffold shell sudah menaruh SnackBar di atas `bottomNavigationBar`;
      // cukup jarak kecil agar menempel di atas navigasi (rancangan `54`).
      MealoraSpacing.sm,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(MealoraRadius.choiceCard),
      side: const BorderSide(color: MealoraColors.glassBorder),
    ),
    content: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: MealoraColors.iconFieldAmber,
            borderRadius: BorderRadius.circular(MealoraRadius.compactIconField),
          ),
          child: const Icon(
            Icons.nightlight_outlined,
            color: MealoraColors.amberText,
            size: 18,
          ),
        ),
        const SizedBox(width: MealoraSpacing.sm),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                text.lateMealNoticeTitle,
                style: MealoraTypography.bodyEmphasis,
              ),
              const SizedBox(height: 2),
              Text(text.lateMealNoticeBody, style: MealoraTypography.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );
}

final Provider<LateMealNotice> lateMealNoticeProvider =
    Provider<LateMealNotice>(
      (ref) => LateMealNotice(
        clock: ref.watch(clockProvider),
        repository: ref.watch(reminderSettingsRepositoryProvider),
      ),
    );
