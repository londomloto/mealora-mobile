import 'package:drift/drift.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/program/program_catalog.dart';
import 'package:mealora/domain/program/program_code.dart';

/// Pengenal baris katalog yang tetap — ditulis di kode, bukan dibangkitkan
/// saat pemasangan (Design D2), supaya baris katalog sama persis di setiap
/// perangkat dan riwayat pengguna tetap bermakna ketika sinkronisasi datang
/// di MVP 2. SHALL TIDAK pernah berubah setelah dirilis.
const Map<ProgramCode, String> kProgramCatalogIds = <ProgramCode, String>{
  ProgramCode.weightLoss: 'program-weight-loss',
  ProgramCode.weightGain: 'program-weight-gain',
  ProgramCode.maintenance: 'program-maintenance',
  ProgramCode.healthyEating: 'program-healthy-eating',
};

/// Versi definisi katalog saat ini. Naik saat bentuk definisi program itu
/// sendiri berubah — bukan setiap kali seed dijalankan.
const int kProgramCatalogDefinitionVersion = 1;

/// Waktu tetap untuk `created_at`/`updated_at` baris katalog.
///
/// Baris katalog bukan record yang dibuat pengguna — nilainya sama di
/// setiap perangkat dan setiap kali diseed (Design D2), jadi memakai waktu
/// tetap alih-alih memakai `Clock` menghindari suntikan `Clock` ke
/// `AppDatabase` hanya untuk empat baris yang isinya tidak pernah berubah
/// berdasarkan waktu seed dijalankan.
final DateTime kProgramCatalogSeedTimestamp = DateTime.utc(2024);

/// Menyisipkan atau memperbarui empat baris katalog program berdasarkan
/// pengenal tetapnya (Design D2) — idempoten: menjalankannya berkali-kali
/// tidak pernah menggandakan baris maupun memutus tautan riwayat.
Future<void> seedProgramCatalog(AppDatabase db) async {
  final definitions = ProgramCatalog.np1.definitions;
  for (var i = 0; i < definitions.length; i++) {
    final definition = definitions[i];
    final id = kProgramCatalogIds[definition.code]!;
    await db
        .into(db.programs)
        .insertOnConflictUpdate(
          ProgramsCompanion.insert(
            id: id,
            code: definition.code.stableCode,
            name: definition.displayName,
            description: definition.intent,
            requiresWeightTarget: definition.requiresTargetWeight,
            isAvailable: Value<bool>(definition.isAvailable),
            sortOrder: i,
            definitionVersion: kProgramCatalogDefinitionVersion,
            createdAt: kProgramCatalogSeedTimestamp,
            updatedAt: kProgramCatalogSeedTimestamp,
          ),
        );
  }
}
