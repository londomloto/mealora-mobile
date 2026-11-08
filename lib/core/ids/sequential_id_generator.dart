import 'package:mealora/core/ids/id_generator.dart';

/// Pembangkit pengenal berurutan tetap untuk pengujian.
///
/// Menghasilkan `<prefix>-0001`, `<prefix>-0002`, dan seterusnya sehingga
/// pengenal dalam pengujian dapat ditulis apa adanya.
final class SequentialIdGenerator implements IdGenerator {
  SequentialIdGenerator({String prefix = 'test'}) : _prefix = prefix;

  final String _prefix;
  int _counter = 0;

  @override
  String next() {
    _counter += 1;
    return '$_prefix-${_counter.toString().padLeft(4, '0')}';
  }
}
