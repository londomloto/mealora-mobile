import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/features/share/share_card_frame.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Subfolder cache untuk PNG kartu sementara (change 014, Design D4).
const String shareCardsDirName = 'share-cards';

Future<Directory> _shareCardsDir() async {
  final cache = await getTemporaryDirectory();
  return Directory('${cache.path}/$shareCardsDirName');
}

/// Perender kartu (task 1.2): merekam [boundary] — kartu 360×640 logis di
/// dalam `RepaintBoundary` — menjadi PNG 1080×1920 di `share-cards/`.
Future<File> renderShareCard(
  RenderRepaintBoundary boundary, {
  required String fileId,
}) async {
  final image = await boundary.toImage(pixelRatio: ShareCardSize.pixelRatio);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) {
      throw StateError('PNG kartu tidak dapat dibuat');
    }
    final dir = await _shareCardsDir();
    await dir.create(recursive: true);
    final file = File('${dir.path}/$fileId.png');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return file;
  } finally {
    image.dispose();
  }
}

/// Membersihkan seluruh PNG kartu sementara — dipanggil saat start (task
/// 1.3, Design D4). Tidak pernah melempar.
Future<void> clearShareCards() async {
  try {
    final dir = await _shareCardsDir();
    if (dir.existsSync()) await dir.delete(recursive: true);
  } on Object {
    // Cache sementara: kegagalan pembersihan tidak boleh menghentikan start.
  }
}

/// Lembar berbagi sistem — di balik antarmuka supaya uji widget tidak
/// memanggil platform.
abstract interface class ShareSheetGateway {
  Future<void> shareImage(String path);
}

final class SystemShareSheetGateway implements ShareSheetGateway {
  const SystemShareSheetGateway();

  @override
  Future<void> shareImage(String path) async {
    // Hasil `dismissed` sengaja diabaikan: menutup lembar berbagi kembali ke
    // layar sebelumnya tanpa pesan galat (spec, "Batal di lembar berbagi").
    await SharePlus.instance.share(
      ShareParams(files: <XFile>[XFile(path, mimeType: 'image/png')]),
    );
  }
}

final Provider<ShareSheetGateway> shareSheetGatewayProvider =
    Provider<ShareSheetGateway>((ref) => const SystemShareSheetGateway());

/// Layanan berbagi (task 1.3): render → lembar berbagi sistem → hapus PNG,
/// baik selesai, dibatalkan, maupun gagal. Tidak ada unggahan ke server.
final Provider<ShareCardService> shareCardServiceProvider =
    Provider<ShareCardService>(
      (ref) => ShareCardService(
        gateway: ref.watch(shareSheetGatewayProvider),
        nextId: () => ref.read(idGeneratorProvider).next(),
      ),
    );

class ShareCardService {
  const ShareCardService({required this.gateway, required this.nextId});

  final ShareSheetGateway gateway;
  final String Function() nextId;

  Future<void> share(RenderRepaintBoundary boundary) async {
    final file = await renderShareCard(boundary, fileId: nextId());
    try {
      await gateway.shareImage(file.path);
    } finally {
      try {
        await file.delete();
      } on PathNotFoundException {
        // Sudah tidak ada.
      }
    }
  }
}
