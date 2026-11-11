import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/data/local/user_record_support.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/tables/food_photo_drafts_table.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food_photo_input/photo_draft.dart';
import 'package:mealora/domain/food_photo_input/photo_draft_repository.dart';

part 'drift_photo_draft_repository.g.dart';

/// Implementasi `PhotoDraftRepository` (change 011) memakai DAO Drift.
///
/// [PhotoDraft.id] dan `PhotoDraftComponent.localId` SHALL sudah berasal
/// dari `IdGenerator` yang disuntikkan di pemanggil sebelum `save` pertama
/// kali dipanggil (pola yang sama dengan `source_image_storage.dart`,
/// change 010) — draf dibuat di lapisan fitur sebelum ada baris basis data
/// sama sekali, jadi repositori ini TIDAK membangkitkan pengenal sendiri.
@DriftAccessor(tables: <Type>[FoodPhotoDrafts])
class DriftPhotoDraftRepository extends DatabaseAccessor<AppDatabase>
    with _$DriftPhotoDraftRepositoryMixin
    implements PhotoDraftRepository {
  DriftPhotoDraftRepository(super.db, {required Clock clock}) : _clock = clock;

  final Clock _clock;

  @override
  Future<PhotoDraft?> current(String profileId) async {
    final row =
        await (select(foodPhotoDrafts)
              ..where(
                (t) =>
                    t.profileId.equals(profileId) &
                    UserRecords.active(t.deletedAt),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<void> save(PhotoDraft draft) async {
    final now = _clock.nowUtc();
    final existing = await (select(
      foodPhotoDrafts,
    )..where((t) => t.id.equals(draft.id))).getSingleOrNull();

    final componentsJson = jsonEncode(
      draft.components.map(_componentToJson).toList(growable: false),
    );

    if (existing == null) {
      await into(foodPhotoDrafts).insert(
        FoodPhotoDraftsCompanion.insert(
          id: draft.id,
          createdAt: now,
          updatedAt: now,
          profileId: draft.profileId,
          localDate: draft.localDate.iso,
          mealTime: draft.mealTime.stableCode,
          sourceImagePath: Value<String?>(draft.sourceImagePath),
          componentsJson: componentsJson,
        ),
      );
      return;
    }

    await (update(foodPhotoDrafts)..where((t) => t.id.equals(draft.id))).write(
      FoodPhotoDraftsCompanion(
        mealTime: Value<String>(draft.mealTime.stableCode),
        sourceImagePath: Value<String?>(draft.sourceImagePath),
        componentsJson: Value<String>(componentsJson),
        updatedAt: Value<DateTime>(now),
        revision: Value<int>(existing.revision + 1),
      ),
    );
  }

  @override
  Future<void> discard(String draftId) async {
    final existing = await (select(
      foodPhotoDrafts,
    )..where((t) => t.id.equals(draftId))).getSingleOrNull();
    if (existing == null) {
      return;
    }
    final now = _clock.nowUtc();
    await (update(foodPhotoDrafts)..where((t) => t.id.equals(draftId))).write(
      FoodPhotoDraftsCompanion(
        deletedAt: Value<DateTime?>(now),
        updatedAt: Value<DateTime>(now),
        revision: Value<int>(existing.revision + 1),
      ),
    );
  }

  PhotoDraft _toDomain(FoodPhotoDraftRow row) {
    final rawComponents = jsonDecode(row.componentsJson) as List<Object?>;
    return PhotoDraft(
      id: row.id,
      profileId: row.profileId,
      localDate: LocalDate.parse(row.localDate),
      mealTime: MealTime.fromStableCode(row.mealTime),
      sourceImagePath: row.sourceImagePath,
      createdAt: row.createdAt,
      components: rawComponents
          .map((raw) => _componentFromJson(raw as Map<String, Object?>))
          .toList(growable: false),
    );
  }

  Map<String, Object?> _componentToJson(PhotoDraftComponent c) =>
      <String, Object?>{
        'localId': c.localId,
        'foodNameGuess': c.foodNameGuess,
        'matchedFoodId': c.matchedFoodId,
        'matchedServingId': c.matchedServingId,
        'matchedFoodName': c.matchedFoodName,
        'quantity': c.quantity,
        'quantityUnitLabel': c.quantityUnitLabel,
        'cookingMethod': c.cookingMethod,
        'portionNeedsCheck': c.portionNeedsCheck,
        'cookingMethodNeedsCheck': c.cookingMethodNeedsCheck,
      };

  PhotoDraftComponent _componentFromJson(Map<String, Object?> json) =>
      PhotoDraftComponent(
        localId: json['localId'] as String,
        foodNameGuess: json['foodNameGuess'] as String,
        matchedFoodId: json['matchedFoodId'] as String?,
        matchedServingId: json['matchedServingId'] as String?,
        matchedFoodName: json['matchedFoodName'] as String?,
        quantity: (json['quantity'] as num).toDouble(),
        quantityUnitLabel: json['quantityUnitLabel'] as String?,
        cookingMethod: json['cookingMethod'] as String?,
        portionNeedsCheck: json['portionNeedsCheck'] as bool,
        cookingMethodNeedsCheck: json['cookingMethodNeedsCheck'] as bool,
      );
}
