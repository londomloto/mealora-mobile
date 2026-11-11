import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'package:path_provider/path_provider.dart';

/// Menyimpan foto draf makanan di perangkat (change 011, Design D6) — SELALU
/// dipanggil segera setelah pemotretan, terlepas dari pengaturan retensi
/// gambar pengguna (change 010): draf harus bertahan melewati penutupan
/// aplikasi (task 3.2/3.4), jadi foto perlu ada di perangkat sejak sebelum
/// pengiriman, bukan hanya di memori.
///
/// Disposisi akhir mengikuti pengaturan retensi (change 010, Design D9):
/// [deleteDraftPhoto] dipanggil saat draf dibuang bila pengaturannya "hapus
/// setelah dicatat"; berkas dibiarkan apa adanya bila "simpan di perangkat".
///
/// [fileId] SHALL berasal dari `IdGenerator` yang disuntikkan di pemanggil
/// (pola yang sama dengan `source_image_storage.dart`, change 010).
Future<String> saveDraftPhoto(Uint8List bytes, {required String fileId}) async {
  final documentsDir = await getApplicationDocumentsDirectory();
  final draftPhotosDir = Directory('${documentsDir.path}/food-photo-drafts');
  await draftPhotosDir.create(recursive: true);
  final file = File('${draftPhotosDir.path}/$fileId.jpg');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

/// Menghapus satu foto draf tersimpan — idempoten, tidak melempar bila
/// berkas sudah tidak ada.
Future<void> deleteDraftPhoto(String path) async {
  try {
    await File(path).delete();
  } on PathNotFoundException {
    // Sudah tidak ada — idempoten.
  }
}
