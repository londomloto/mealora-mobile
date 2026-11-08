import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/ids/id_generator.dart';

/// Sumber waktu aplikasi.
///
/// Ditimpa saat aplikasi dimulai (`main.dart`) dan di dalam pengujian.
final Provider<Clock> clockProvider = Provider<Clock>(
  (ref) => throw UnimplementedError(
    'clockProvider harus ditimpa di ProviderScope '
    '(lihat lib/main.dart dan test/).',
  ),
);

/// Pembangkit pengenal record.
final Provider<IdGenerator> idGeneratorProvider = Provider<IdGenerator>(
  (ref) => throw UnimplementedError(
    'idGeneratorProvider harus ditimpa di ProviderScope '
    '(lihat lib/main.dart dan test/).',
  ),
);
