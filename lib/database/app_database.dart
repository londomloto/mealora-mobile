import 'package:drift/drift.dart';
import 'package:mealora/database/connection/mealora_connection.dart';
import 'package:mealora/database/migrations/food_diary_indexes.dart';
import 'package:mealora/database/migrations/food_photo_draft_indexes.dart';
import 'package:mealora/database/migrations/packaged_food_indexes.dart';
import 'package:mealora/database/migrations/program_indexes.dart';
import 'package:mealora/database/migrations/program_invariant_trigger.dart';
import 'package:mealora/database/migrations/recipe_ingredient_indexes.dart';
import 'package:mealora/database/migrations/user_record_triggers.dart';
import 'package:mealora/database/migrations/weight_indexes.dart';
import 'package:mealora/database/seeds/food_catalog_seed.dart';
import 'package:mealora/database/seeds/program_catalog_seed.dart';
import 'package:mealora/database/tables/food_photo_drafts_table.dart';
import 'package:mealora/database/tables/food_servings_table.dart';
import 'package:mealora/database/tables/foods_table.dart';
import 'package:mealora/database/tables/harness_records.dart';
import 'package:mealora/database/tables/meal_entries_table.dart';
import 'package:mealora/database/tables/meal_entry_items_table.dart';
import 'package:mealora/database/tables/nutrition_values_table.dart';
import 'package:mealora/database/tables/packaged_food_properties_table.dart';
import 'package:mealora/database/tables/profiles_table.dart';
import 'package:mealora/database/tables/program_events_table.dart';
import 'package:mealora/database/tables/program_progress_table.dart';
import 'package:mealora/database/tables/programs_table.dart';
import 'package:mealora/database/tables/recipe_ingredients_table.dart';
import 'package:mealora/database/tables/ui_preferences.dart';
import 'package:mealora/database/tables/user_programs_table.dart';
import 'package:mealora/database/tables/weight_records_table.dart';

part 'app_database.g.dart';

/// Versi skema penyimpanan lokal.
///
/// Setiap perubahan struktur menaikkan angka ini dan menambah langkah di
/// [AppDatabase.migration] beserta kasus uji di `test/database/`. Penurunan
/// versi (downgrade) tidak didukung.
const int kSchemaVersion = 11;

@DriftDatabase(
  tables: <Type>[
    HarnessRecords,
    HarnessRecordNotes,
    UiPreferences,
    Programs,
    UserPrograms,
    ProgramProgress,
    ProgramEvents,
    Profiles,
    Foods,
    FoodServings,
    NutritionValues,
    MealEntries,
    MealEntryItems,
    WeightRecords,
    PackagedFoodProperties,
    FoodPhotoDrafts,
    RecipeIngredients,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? openMealoraConnection());

  @override
  int get schemaVersion => kSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await createUserRecordTriggers(this);
      await createProgramIndexes(this);
      await createProgramInvariantTrigger(this);
      await seedProgramCatalog(this);
      await createFoodDiaryIndexes(this);
      await ensureFoodCatalogSeeded(this);
      await createWeightIndexes(this);
      await createPackagedFoodIndexes(this);
      await createFoodPhotoDraftIndexes(this);
      await createRecipeIngredientIndexes(this);
    },
    onUpgrade: (m, from, to) async {
      if (from > to) {
        throw StateError(
          'Penurunan versi skema tidak didukung (dari $from ke $to).',
        );
      }
      if (from < 2) {
        // Versi 1 → 2 (change 004): empat tabel program, indeks, dan
        // trigger invarian, lalu seed katalog. Tidak menyentuh data versi 1
        // dan tidak mendaftarkan profil mana pun ke program (Design D8).
        //
        // `userPrograms` di sini sudah memakai definisi Dart terkini —
        // yaitu sudah menyertakan foreign key ke `profiles` (change 005).
        // SQLite mengizinkan `CREATE TABLE` merujuk tabel yang belum ada;
        // tabel `profiles` dibuat di blok `from < 3` tepat setelah ini,
        // sebelum `beforeOpen` mengaktifkan penegakan kunci asing.
        await m.createTable(programs);
        await m.createTable(userPrograms);
        await m.createTable(programProgress);
        await m.createTable(programEvents);
        await createUserRecordTriggers(this);
        await createProgramIndexes(this);
        await createProgramInvariantTrigger(this);
        await seedProgramCatalog(this);
      }
      if (from < 3) {
        // Versi 2 → 3 (change 005): tabel profil, lalu rujukan profil pada
        // `user_programs` dilengkapi menjadi foreign key sungguhan (Design
        // D8). Migrasi ini TIDAK membuat profil otomatis dan TIDAK
        // mengaktifkan program apa pun.
        await m.createTable(profiles);

        if (from == 2) {
          // Catatan migrasi (task 2.7, design.md Open Questions): tabel
          // `profiles` baru dan selalu kosong pada titik ini — tidak ada
          // profil yang pernah ada sebelum change ini. Akibatnya, SETIAP
          // baris `user_programs` dari versi 2 ke bawah adalah baris
          // "yatim" di bawah foreign key sungguhan: `profile_id`-nya tidak
          // pernah menunjuk ke profil nyata, karena profil belum pernah
          // ada untuk ditunjuk.
          //
          // Keputusan yang diambil: baris yatim tersebut DIHAPUS beserta
          // peristiwa dan potret kemajuannya, bukan migrasi yang ditolak.
          // Ini hanya mungkin terjadi pada perangkat uji internal (belum
          // ada rilis publik), dan ini pula perilaku yang dituntut spesifik
          // program-onboarding — "Pengguna dari versi sebelumnya": tidak
          // ada program aktif setelah migrasi, pengguna diajak memilih
          // program dari awal. Bila baris ini dibiarkan, `PRAGMA
          // foreign_key_check` setelah migrasi akan melaporkannya sebagai
          // pelanggaran.
          await customStatement('''
DELETE FROM program_progress
WHERE user_program_id IN (
  SELECT id FROM user_programs
  WHERE profile_id NOT IN (SELECT id FROM profiles)
);
''');
          await customStatement('''
DELETE FROM program_events
WHERE user_program_id IN (
  SELECT id FROM user_programs
  WHERE profile_id NOT IN (SELECT id FROM profiles)
);
''');
          await customStatement('''
DELETE FROM user_programs
WHERE profile_id NOT IN (SELECT id FROM profiles);
''');

          // Membangun ulang `user_programs` dengan definisi Dart terkini
          // (foreign key sungguhan ke `profiles`) — proses ini menghapus
          // indeks dan trigger milik tabel lama, jadi keduanya dibuat ulang
          // sesudahnya (idiom `IF NOT EXISTS`/`insertOnConflictUpdate` di
          // setiap fungsi ini membuatnya aman dipanggil berkali-kali).
          await m.alterTable(TableMigration(userPrograms));
          await createUserRecordTriggers(this);
          await createProgramIndexes(this);
          await createProgramInvariantTrigger(this);
        }
      }
      if (from < 4) {
        // Versi 3 → 4 (change 007): tabel makanan, takaran saji, nilai
        // gizi, catatan makan, dan butir catatan, beserta indeks dan seed
        // katalog bawaan. Tidak menyentuh data versi 3 (Migration Plan
        // design.md item 4).
        await m.createTable(foods);
        await m.createTable(foodServings);
        await m.createTable(nutritionValues);
        await m.createTable(mealEntries);
        await m.createTable(mealEntryItems);
        await createFoodDiaryIndexes(this);
        await ensureFoodCatalogSeeded(this);
      }
      if (from < 5) {
        // Versi 4 → 5 (change 008): tabel catatan berat beserta indeks
        // menurut profil dan tanggal lokal. Tidak menyentuh data versi 4
        // (design.md Migration Plan item 3).
        await m.createTable(weightRecords);
        await createWeightIndexes(this);
      }
      if (from < 6) {
        // Versi 5 → 6 (change 009): tabel sifat produk kemasan beserta
        // kolom provenans dan indeks pada barcode. Tidak menyentuh data
        // versi 5 (design.md Migration Plan item 1-3).
        await m.createTable(packagedFoodProperties);
        await createPackagedFoodIndexes(this);
      }
      if (from < 7) {
        // Versi 6 → 7 (change 010): `packaged_food_properties` mendapat
        // nilai `source_type` baru (`label_extraction`) dan kolom
        // `source_image_path` opsional. CHECK constraint pada
        // `source_type` adalah bagian dari SQL `CREATE TABLE` — melonggarkannya
        // tidak bisa lewat `ALTER TABLE` biasa, jadi tabel dibangun ulang
        // dengan definisi Dart terkini (idiom yang sama dengan migrasi versi
        // 2 → 3 untuk `user_programs`, lihat komentar `from == 2` di atas).
        // Baris versi 6 yang ada — hanya `openfoodfacts`/`user_manual` —
        // tetap sah di bawah CHECK yang lebih longgar ini, jadi seluruh
        // data dipertahankan tanpa perubahan (design.md Migration Plan).
        await m.alterTable(
          TableMigration(
            packagedFoodProperties,
            newColumns: <GeneratedColumn<Object>>[
              packagedFoodProperties.sourceImagePath,
            ],
          ),
        );
        await createPackagedFoodIndexes(this);
      }
      if (from < 8) {
        // Versi 7 → 8 (change 010): `packaged_food_properties.barcode`
        // menjadi nullable — produk yang dikonfirmasi lewat foto label
        // tanpa barcode (kemasan rusak, atau jalur foto langsung dari
        // layar pindai) tidak punya pengenal barcode sama sekali. NOT
        // NULL adalah bagian dari SQL `CREATE TABLE`, sama seperti migrasi
        // versi 6 → 7, sehingga tabel dibangun ulang lagi. Baris versi 7
        // yang ada semuanya punya barcode terisi, jadi tetap sah di bawah
        // kolom yang lebih longgar ini tanpa kehilangan data (design.md
        // Migration Plan). Indeks unik pada barcode tetap berlaku — SQLite
        // memperlakukan setiap NULL sebagai berbeda, jadi produk tanpa
        // barcode tidak saling bentrok.
        await m.alterTable(TableMigration(packagedFoodProperties));
        await createPackagedFoodIndexes(this);
      }
      if (from < 9) {
        // Versi 8 → 9 (change 011): tabel draf foto makanan. Tidak
        // menyentuh data versi 8 (design.md Migration Plan — tidak ada
        // perubahan skema buku harian, hanya kapabilitas baru).
        await m.createTable(foodPhotoDrafts);
        await createFoodPhotoDraftIndexes(this);
      }
      if (from < 10) {
        // Versi 9 → 10 (change 015): provenans per takaran, bentuk makanan,
        // dan status aktif. Hanya `addColumn` dengan nilai bawaan aman —
        // tidak ada baris yang disalin ulang, catatan makan tidak tersentuh
        // (design.md D2 & Migration Plan).
        // Blok `from < 4` membuat `foods`/`food_servings` dengan definisi
        // terkini (sudah memuat kolom ini), jadi kolom hanya ditambahkan
        // bila belum ada.
        for (final (table, column)
            in <(TableInfo<Table, Object?>, GeneratedColumn<Object>)>[
              (foods, foods.form),
              (foods, foods.isActive),
              (foodServings, foodServings.provenanceTier),
              (foodServings, foodServings.provenanceRef),
              (foodServings, foodServings.provenanceNote),
            ]) {
          final existing = await customSelect(
            "SELECT 1 FROM pragma_table_info('${table.actualTableName}') "
            'WHERE name = ?',
            variables: <Variable>[Variable<String>(column.name)],
          ).get();
          if (existing.isEmpty) {
            await m.addColumn(table, column);
          }
        }
      }
      if (from < 11) {
        // Versi 10 → 11 (change 016): tabel bahan resep, asal nilai gizi,
        // dan hasil resep. Makanan buatan pengguna lama ditandai `manual`;
        // catatan makan tidak tersentuh (design.md Migration Plan).
        // Blok `from < 4` membuat `foods` dengan definisi terkini, jadi
        // kolom hanya ditambahkan bila belum ada (idiom yang sama dengan
        // blok `from < 10`).
        for (final column in <GeneratedColumn<Object>>[
          foods.nutritionOrigin,
          foods.recipeYieldServings,
          foods.recipeYieldGrams,
        ]) {
          final existing = await customSelect(
            "SELECT 1 FROM pragma_table_info('foods') WHERE name = ?",
            variables: <Variable>[Variable<String>(column.name)],
          ).get();
          if (existing.isEmpty) {
            await m.addColumn(foods, column);
          }
        }
        await m.createTable(recipeIngredients);
        await createRecipeIngredientIndexes(this);
        await customStatement(
          "UPDATE foods SET nutrition_origin = 'manual' "
          'WHERE is_user_created = 1 AND nutrition_origin IS NULL',
        );
      }
    },
    beforeOpen: (details) async {
      // Kunci asing diaktifkan pada setiap pembukaan koneksi: PRAGMA ini
      // tidak bertahan antar koneksi di SQLite.
      await customStatement('PRAGMA foreign_keys = ON');
      await ensureFoodCatalogSeeded(this);
    },
  );
}
