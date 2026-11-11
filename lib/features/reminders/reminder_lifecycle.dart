import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/reminders/reminder_scheduler.dart';
import 'package:mealora/features/reminders/reminder_providers.dart';
import 'package:mealora/features/shell/destinations.dart';
import 'package:mealora/features/weight/add_weight_screen.dart';

/// Pembaca zona waktu perangkat saat ini (IANA), `null` bila tidak tersedia.
final Provider<Future<String?> Function()> deviceTimeZoneReaderProvider =
    Provider<Future<String?> Function()>(
      (ref) => () async {
        try {
          return (await FlutterTimezone.getLocalTimezone()).identifier;
        } on Object {
          return null;
        }
      },
    );

/// Menjaga jadwal pengingat tetap selaras dan menangani ketukan notifikasi
/// (change 013, task 2.3 & 3.5). Membungkus ruang utama — tidak aktif saat
/// onboarding, sehingga onboarding tidak pernah menyentuh notifikasi.
class ReminderLifecycle extends ConsumerStatefulWidget {
  const ReminderLifecycle({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ReminderLifecycle> createState() => _ReminderLifecycleState();
}

class _ReminderLifecycleState extends ConsumerState<ReminderLifecycle>
    with WidgetsBindingObserver {
  StreamSubscription<ReminderTapTarget>? _taps;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final gateway = ref.read(reminderNotificationGatewayProvider);
    _taps = gateway.taps.listen(_open);
    unawaited(_onStart(gateway));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_taps?.cancel());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(notificationsEnabledProvider);
      unawaited(_syncTimeZone(force: false));
    }
  }

  Future<void> _onStart(ReminderNotificationGateway gateway) async {
    await _syncTimeZone(force: true);
    final target = await gateway.launchTarget();
    if (target != null && mounted) _open(target);
  }

  /// Rekonsiliasi saat aplikasi dimulai ([force]) atau saat kembali ke
  /// foreground dan zona waktu berbeda dari yang tersimpan (Design D3).
  Future<void> _syncTimeZone({required bool force}) async {
    try {
      final repository = ref.read(reminderSettingsRepositoryProvider);
      final current =
          await ref.read(deviceTimeZoneReaderProvider)() ??
          ref.read(clockProvider).timeZoneId();
      final stored = await repository.scheduledTimeZone();
      if (!force && current == stored) return;
      ref.read(reminderNotificationGatewayProvider).setLocalTimeZone(current);
      await ref.read(reminderSettingsProvider.notifier).reconcile();
      await repository.saveScheduledTimeZone(current);
    } on Object catch (error) {
      // Penjadwalan gagal tidak boleh menjatuhkan ruang utama; dicoba lagi
      // pada pembukaan berikutnya.
      debugPrint('Rekonsiliasi pengingat gagal: ${error.runtimeType}');
    }
  }

  void _open(ReminderTapTarget target) {
    if (!mounted) return;
    final navigator = Navigator.of(context)..popUntil((route) => route.isFirst);
    switch (target) {
      case ReminderTapTarget.today:
        unawaited(
          ref
              .read(selectedDestinationProvider.notifier)
              .select(MealoraDestination.today),
        );
      case ReminderTapTarget.addWeight:
        unawaited(
          navigator.push(
            MaterialPageRoute<void>(builder: (_) => const AddWeightScreen()),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
