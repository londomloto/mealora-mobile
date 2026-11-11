/// Panjang nomor barcode yang berlaku: EAN-8, UPC-A/EAN-12, EAN-13, GTIN-14
/// (spec packaged-food-barcode, "Masukkan barcode manual selalu tersedia" —
/// "Sistem SHALL menolak nomor yang tidak memenuhi bentuk barcode yang
/// berlaku").
const Set<int> kValidBarcodeLengths = <int>{8, 12, 13, 14};

final RegExp _digitsOnly = RegExp(r'^\d+$');

/// `true` bila [value] adalah nomor barcode yang bentuknya sah: hanya
/// digit, dengan salah satu panjang di [kValidBarcodeLengths].
///
/// Dipakai pada masukan barcode manual (task 6.2) untuk menolak nomor yang
/// tidak sah dengan penjelasan, tanpa melakukan pencarian apa pun.
bool isValidBarcodeFormat(String value) =>
    _digitsOnly.hasMatch(value) && kValidBarcodeLengths.contains(value.length);
