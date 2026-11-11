import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'package:path_provider/path_provider.dart';

/// Menyimpan foto label sumber di perangkat (change 010, Design D9, task
/// 3.6) — HANYA dipanggil ketika pengaturan retensi pengguna mengizinkan
/// (`ImageRetentionPreference.keepOnDevice`); pemanggil yang memutuskan
/// itu, berkas ini hanya menulis.
///
/// [fileId] SHALL berasal dari `IdGenerator` yang disuntikkan di pemanggil
/// (bukan dibangkitkan di sini) — berkas penulisan penyimpanan SHALL TIDAK
/// membangkitkan pengenal acak sendiri, sama seperti aturan lain di
/// `test/unit/architecture/layer_rules_test.dart`.
///
/// Mengembalikan path lengkap berkas yang ditulis, untuk disimpan sebagai
/// `PackagedFoodProvenance.sourceImagePath`.
Future<String> saveSourceImage(
  Uint8List bytes, {
  required String fileId,
}) async {
  final documentsDir = await getApplicationDocumentsDirectory();
  final labelPhotosDir = Directory('${documentsDir.path}/label-photos');
  await labelPhotosDir.create(recursive: true);
  final file = File('${labelPhotosDir.path}/$fileId.jpg');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

/// Menghapus satu foto label tersimpan — dipanggil setelah pencatatan
/// selesai ketika pengaturan retensi bernilai "hapus setelah dicatat"
/// (spec image-ai-access, "Pengaturan hapus setelah dicatat"). Tidak
/// melempar bila berkas sudah tidak ada (idempoten).
Future<void> deleteSourceImage(String path) async {
  try {
    await File(path).delete();
  } on PathNotFoundException {
    // Sudah tidak ada — idempoten.
  }
}
