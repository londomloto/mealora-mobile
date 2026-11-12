/// Cek update app (change 017-app-update-check, design D3/D4).
///
/// Murni Dart: tidak ada Flutter, jaringan, atau penyimpanan di sini, sehingga
/// seluruh keputusan "wajib / opsional / tidak ada" dapat diuji sebagai fungsi.
library;

import 'package:mealora/core/clock/clock.dart';

/// Versi `mayor.minor.patch`. Nomor build (`+n`) dan suffix pra-rilis (`-x`)
/// dibuang karena pengguna hanya melihat versi toko.
final class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch);

  /// Null bila [raw] tidak dapat diurai: konfigurasi seperti ini diperlakukan
  /// tidak valid (spec, "Perbandingan versi").
  static AppVersion? tryParse(String? raw) {
    if (raw == null) return null;
    final core = raw.trim().split('+').first.split('-').first;
    final match = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(core);
    if (match == null) return null;
    return AppVersion(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  final int major;
  final int minor;
  final int patch;

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  bool operator <(AppVersion other) => compareTo(other) < 0;

  @override
  bool operator ==(Object other) =>
      other is AppVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}

/// Platform toko yang dikenal.
enum AppStorePlatform { android, ios }

/// Konfigurasi versi dari server (kontrak `/app-config`, design D2).
final class AppVersionConfig {
  const AppVersionConfig({
    required this.latestVersion,
    required this.minSupportedVersion,
    required this.releaseNotes,
    required this.androidStoreUrl,
    required this.iosStoreUrl,
  });

  final AppVersion latestVersion;
  final AppVersion minSupportedVersion;
  final String releaseNotes;
  final String androidStoreUrl;
  final String iosStoreUrl;

  /// Tautan toko `https` untuk [platform], atau null bila kosong/tidak valid.
  String? storeUrlFor(AppStorePlatform platform) {
    final url = switch (platform) {
      AppStorePlatform.android => androidStoreUrl,
      AppStorePlatform.ios => iosStoreUrl,
    };
    return url.startsWith('https://') ? url : null;
  }

  /// Mengurai bentuk JSON kontrak. Null bila field hilang, bertipe salah,
  /// versi tidak dapat diurai, atau minimum melebihi terbaru.
  static AppVersionConfig? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final latest = AppVersion.tryParse(_string(json['latestVersion']));
    final min = AppVersion.tryParse(_string(json['minSupportedVersion']));
    final storeUrl = json['storeUrl'];
    if (latest == null || min == null || latest < min) return null;
    if (storeUrl is! Map<String, Object?>) return null;
    return AppVersionConfig(
      latestVersion: latest,
      minSupportedVersion: min,
      releaseNotes: _string(json['releaseNotes']) ?? '',
      androidStoreUrl: _string(storeUrl['android']) ?? '',
      iosStoreUrl: _string(storeUrl['ios']) ?? '',
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'latestVersion': '$latestVersion',
    'minSupportedVersion': '$minSupportedVersion',
    'releaseNotes': releaseNotes,
    'storeUrl': <String, Object?>{
      'android': androidStoreUrl,
      'ios': iosStoreUrl,
    },
  };

  static String? _string(Object? value) => value is String ? value : null;
}

/// Sumber konfigurasi versi. Implementasi awal lewat proksi; nanti cukup
/// diganti implementasi Supabase dengan bentuk data yang sama.
abstract interface class AppConfigSource {
  /// Null untuk kegagalan apa pun (fail-open): tidak dikonfigurasi, jaringan,
  /// timeout, status non-200, atau respons tidak valid.
  Future<AppVersionConfig?> fetch();
}

/// Hasil keputusan cek update.
sealed class AppUpdateStatus {
  const AppUpdateStatus();
}

final class AppUpdateNone extends AppUpdateStatus {
  const AppUpdateNone();
}

/// Update tersedia tetapi boleh ditunda.
final class AppUpdateOptional extends AppUpdateStatus {
  const AppUpdateOptional({
    required this.version,
    required this.releaseNotes,
    required this.storeUrl,
  });

  final AppVersion version;
  final String releaseNotes;
  final String storeUrl;
}

/// Versi terpasang tidak didukung lagi.
final class AppUpdateForced extends AppUpdateStatus {
  const AppUpdateForced({required this.releaseNotes, required this.storeUrl});

  final String releaseNotes;
  final String storeUrl;
}

/// Keputusan cek update (spec `app-update-check`).
///
/// - [fresh]: konfigurasi yang baru saja berhasil diambil; null bila gagal.
/// - [cached]: konfigurasi valid terakhir yang tersimpan.
/// - Wajib update berlaku dari [fresh], atau dari [cached] bila [fresh] null.
/// - Update opsional hanya dari [fresh], dan tidak untuk versi yang sudah
///   ditunda pengguna ([dismissedVersion]).
/// - Tanpa tautan toko untuk [platform], tidak ada UI update sama sekali.
AppUpdateStatus evaluateAppUpdate({
  required AppVersion installed,
  required AppStorePlatform platform,
  required AppVersionConfig? fresh,
  required AppVersionConfig? cached,
  required AppVersion? dismissedVersion,
}) {
  final effective = fresh ?? cached;
  if (effective == null) return const AppUpdateNone();

  final storeUrl = effective.storeUrlFor(platform);
  if (storeUrl == null) return const AppUpdateNone();

  if (installed < effective.minSupportedVersion) {
    return AppUpdateForced(
      releaseNotes: effective.releaseNotes,
      storeUrl: storeUrl,
    );
  }

  if (fresh != null &&
      installed < fresh.latestVersion &&
      dismissedVersion != fresh.latestVersion) {
    return AppUpdateOptional(
      version: fresh.latestVersion,
      releaseNotes: fresh.releaseNotes,
      storeUrl: storeUrl,
    );
  }

  return const AppUpdateNone();
}

/// Penyimpanan lokal cek update (design D5).
abstract interface class AppUpdateStore {
  Future<AppVersionConfig?> readCachedConfig();

  /// Hanya dipanggil dengan konfigurasi yang sudah valid.
  Future<void> writeCachedConfig(AppVersionConfig config);

  Future<AppVersion?> readDismissedVersion();
  Future<void> writeDismissedVersion(AppVersion version);
  Future<DateTime?> readLastSuccessAt();
  Future<void> writeLastSuccessAt(DateTime instantUtc);
}

/// Orkestrasi cek update: sumber, cache, throttle, dan keputusan.
final class AppUpdateService {
  AppUpdateService({
    required this.source,
    required this.store,
    required this.clock,
    required this.installed,
    required this.platform,
    this.resumeThrottle = const Duration(hours: 1),
  });

  final AppConfigSource source;
  final AppUpdateStore store;
  final Clock clock;
  final AppVersion installed;
  final AppStorePlatform platform;
  final Duration resumeThrottle;

  /// Status dari konfigurasi tersimpan saja (tanpa jaringan): hanya wajib
  /// update yang dapat dihasilkan, sehingga gerbang langsung berlaku.
  Future<AppUpdateStatus> cachedStatus() async => evaluateAppUpdate(
    installed: installed,
    platform: platform,
    fresh: null,
    cached: await store.readCachedConfig(),
    dismissedVersion: null,
  );

  /// Mengambil konfigurasi terbaru. Dengan [throttled], pengambilan dilewati
  /// bila pengecekan berhasil terakhir kurang dari [resumeThrottle] lalu;
  /// hasilnya null, yang berarti status tidak berubah.
  Future<AppUpdateStatus?> refresh({bool throttled = false}) async {
    if (throttled) {
      final last = await store.readLastSuccessAt();
      if (last != null && clock.nowUtc().difference(last) < resumeThrottle) {
        return null;
      }
    }
    final fresh = await source.fetch();
    if (fresh != null) {
      try {
        await store.writeCachedConfig(fresh);
        await store.writeLastSuccessAt(clock.nowUtc());
      } on Object {
        // Gagal menyimpan tidak membatalkan hasil yang baru diambil.
      }
    }
    return evaluateAppUpdate(
      installed: installed,
      platform: platform,
      fresh: fresh,
      cached: fresh == null ? await store.readCachedConfig() : null,
      dismissedVersion: await store.readDismissedVersion(),
    );
  }

  Future<void> dismiss(AppVersion version) =>
      store.writeDismissedVersion(version);
}
