import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/reminders/reminder_scheduler.dart';
import 'package:mealora/domain/reminders/reminder_settings.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Copy notifikasi dari ARB (Design D6). Aplikasi hanya memakai `id`.
ReminderCopy reminderCopyOf(AppText text) => ReminderCopy(
  meals: <MealReminderSlot, ReminderMessage>{
    MealReminderSlot.breakfast: ReminderMessage(
      title: text.reminderBreakfastTitle,
      body: text.reminderBreakfastBody,
    ),
    MealReminderSlot.lunch: ReminderMessage(
      title: text.reminderLunchTitle,
      body: text.reminderLunchBody,
    ),
    MealReminderSlot.snack: ReminderMessage(
      title: text.reminderSnackTitle,
      body: text.reminderSnackBody,
    ),
    MealReminderSlot.dinner: ReminderMessage(
      title: text.reminderDinnerTitle,
      body: text.reminderDinnerBody,
    ),
  },
  weigh: ReminderMessage(
    title: text.reminderWeighTitle,
    body: text.reminderWeighBody,
  ),
);

/// Teks aplikasi tanpa `BuildContext` — untuk penjadwalan di luar pohon
/// widget. Satu locale (`id`), sama dengan `MealoraApp`.
final Provider<AppText> appTextProvider = Provider<AppText>(
  (ref) => lookupAppText(const Locale('id')),
);

/// Pengaturan pengingat; setiap perubahan disimpan lalu jadwal
/// direkonsiliasi (task 2.3, Design D3).
final AsyncNotifierProvider<ReminderSettingsController, ReminderSettings>
reminderSettingsProvider =
    AsyncNotifierProvider<ReminderSettingsController, ReminderSettings>(
      ReminderSettingsController.new,
    );

class ReminderSettingsController extends AsyncNotifier<ReminderSettings> {
  @override
  Future<ReminderSettings> build() =>
      ref.watch(reminderSettingsRepositoryProvider).load();

  Future<void> save(ReminderSettings settings) async {
    state = AsyncValue<ReminderSettings>.data(settings);
    await ref.read(reminderSettingsRepositoryProvider).save(settings);
    await reconcile();
  }

  /// Menjadwalkan ulang dari pengaturan tersimpan dan mencatat zona waktu
  /// yang dipakai.
  Future<void> reconcile() async {
    final settings = await future;
    final gateway = ref.read(reminderNotificationGatewayProvider);
    await ReminderScheduler(
      gateway,
    ).reconcile(settings, reminderCopyOf(ref.read(appTextProvider)));
  }
}

/// Apakah notifikasi diizinkan sistem; di-`invalidate` saat aplikasi
/// kembali ke foreground (pengguna mungkin baru dari pengaturan sistem).
final FutureProvider<bool> notificationsEnabledProvider = FutureProvider<bool>(
  (ref) =>
      ref.watch(reminderNotificationGatewayProvider).areNotificationsEnabled(),
);
