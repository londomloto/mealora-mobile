import 'package:mealora/domain/packaged_food/product_data_source_client.dart';

/// Tiruan `ProductDataSourceClient` untuk pengujian (task 4.1, change 009)
/// — tanpa jaringan sungguhan. Melacak panggilan supaya uji dapat
/// membuktikan "pencarian daring hanya dipanggil ketika produk tidak ada di
/// perangkat" (task 4.7) tanpa bergantung pada mengintip jaringan.
final class FakeProductDataSourceClient implements ProductDataSourceClient {
  final Map<String, RemoteProductLookup> _byBarcode =
      <String, RemoteProductLookup>{};

  /// `true` membuat setiap panggilan melempar — mensimulasikan sumber
  /// daring yang gagal/menolak (task 4.6). Pola sama dengan kontrak
  /// `ProductDataSourceClient.lookupByBarcode`: pemanggil (repositori)
  /// SHALL tetap memperlakukan ini sebagai "belum ditemukan daring".
  bool throwOnLookup = false;

  final List<String> calledWithBarcodes = <String>[];

  void seed(String barcode, RemoteProductLookup lookup) {
    _byBarcode[barcode] = lookup;
  }

  @override
  Future<RemoteProductLookup?> lookupByBarcode(String barcode) async {
    calledWithBarcodes.add(barcode);
    if (throwOnLookup) {
      throw StateError('sumber daring tiruan gagal');
    }
    return _byBarcode[barcode];
  }
}
