import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../models/crop_field.dart';
import '../../models/crop_detail.dart';
import '../../models/crop_type.dart';

/// Crop plantings live on Ulimi's mobile API now (`/api/mobile/crops`) —
/// same write-through pattern as FieldsRepository. Two real differences
/// from the API's shape worth knowing:
///  - `crop_type` is sent/received as a free-text *name*, resolved-or-created
///    server-side into a type — never a foreign key you look up first. The
///    local `crop_types` table still exists (for the offline dropdown +
///    "quick add" flow), so responses get mirrored into it by id/name too,
///    keeping local type lookups consistent with the server's.
///  - The server's `status` enum is Active/Harvested/Failed/Terminated —
///    "Archived" is a *separate* `is_archived` flag, set only via the
///    dedicated archive/restore endpoints, never sent as a status value.
///  - There's no delete endpoint for a crop planting at all (matches the
///    web app — plantings are archived, not deleted, once they exist).
class CropsRepository {
  CropsRepository(this._db, this._dio);

  final AppDatabase _db;
  final Dio _dio;

  Future<List<CropFieldModel>> getCrops({String? archived}) async {
    await _pullFromApi();
    return getCropsLocalOnly(archived: archived);
  }

  /// Same as [getCrops] but skips the network pull — for background/local
  /// computations (see NotificationsRepository's timeline scan) that run
  /// frequently and shouldn't force a round-trip just to check due dates
  /// against whatever's already cached.
  Future<List<CropFieldModel>> getCropsLocalOnly({String? archived}) async {
    final query = _db.select(_db.cropFields);
    if (archived == 'true') {
      query.where((t) => t.isArchived.equals(true));
    } else if (archived == 'false') {
      query.where((t) => t.isArchived.equals(false));
    }
    final rows = await query.get();

    final result = <CropFieldModel>[];
    for (final row in rows) {
      final field = await (_db.select(_db.fields)
            ..where((t) => t.id.equals(row.fieldId)))
          .getSingleOrNull();
      result.add(CropFieldModel.fromJson({
        ...row.toJson(),
        'cropTypeName': await _cropTypeName(row.cropTypeId),
        'fieldName': field?.name ?? 'Field',
        'fieldCultivatable': field?.cultivatableArea ?? 0,
      }));
    }
    return result;
  }

  Future<void> _pullFromApi() async {
    try {
      final res = await _dio.get('/api/mobile/crops', queryParameters: {'archived': '1'});
      final archivedRows = ((res.data as Map)['data'] as List).cast<Map<String, dynamic>>();
      final res2 = await _dio.get('/api/mobile/crops');
      final activeRows = ((res2.data as Map)['data'] as List).cast<Map<String, dynamic>>();
      for (final row in [...activeRows, ...archivedRows]) {
        await _upsertFromApi(row);
      }
    } catch (_) {
      // Offline or unreachable — fall back to whatever's cached locally.
    }
  }

  Future<void> _upsertFromApi(Map<String, dynamic> row) async {
    final cropTypeId = row['crop_type_id'] as String;
    final cropName = row['crop_name'] as String? ?? 'Crop';
    await _db.into(_db.cropTypes).insertOnConflictUpdate(
          CropTypesCompanion.insert(id: cropTypeId, name: cropName, isCustom: const Value(true)),
        );
    await _db.into(_db.cropFields).insertOnConflictUpdate(CropFieldsCompanion.insert(
          id: row['id'] as String,
          cropTypeId: cropTypeId,
          fieldId: row['field_id'] as String,
          variety: asStringOrNull(row['variety']) ?? '',
          areaPlanted: asDouble(row['area_planted']),
          season: row['season'] as String,
          plantingDate: DateTime.parse(row['planting_date'] as String),
          expectedHarvestDate: DateTime.parse(row['expected_harvest_date'] as String),
          status: Value(row['status'] as String? ?? 'Active'),
          isArchived: Value(_asBool(row['is_archived'])),
          createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
        ));
  }

  bool _asBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return value?.toString() == '1' || value?.toString().toLowerCase() == 'true';
  }

  /// The plain create/update-shaped record for [id] — used by the edit form,
  /// which needs `cropTypeId` and `fieldId` rather than [CropDetail]'s
  /// display-only `cropTypeName`/`fieldName`.
  Future<CropFieldModel> getCropField(String id) async {
    final row = await (_db.select(_db.cropFields)..where((t) => t.id.equals(id))).getSingle();
    final field = await (_db.select(_db.fields)..where((t) => t.id.equals(row.fieldId))).getSingleOrNull();
    return CropFieldModel.fromJson({
      ...row.toJson(),
      'cropTypeName': await _cropTypeName(row.cropTypeId),
      'fieldName': field?.name ?? 'Field',
      'fieldCultivatable': field?.cultivatableArea ?? 0,
    });
  }

  Future<CropDetail> getCrop(String id) async {
    final crop = await (_db.select(_db.cropFields)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    final field = await (_db.select(_db.fields)
          ..where((t) => t.id.equals(crop.fieldId)))
        .getSingleOrNull();

    final activityRows = await (_db.select(_db.activities)
          ..where((t) => t.cropFieldId.equals(id))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();

    double totalInputs = 0, totalLabour = 0, totalOther = 0;
    final activities = <Map<String, dynamic>>[];
    for (final activity in activityRows) {
      final inputCost = await _sumActivityInputs(activity.id);
      final labourCost = await _sumActivityLabour(activity.id);
      final otherCost = await _sumActivityOtherCosts(activity.id);
      totalInputs += inputCost;
      totalLabour += labourCost;
      totalOther += otherCost;
      activities.add({
        ...activity.toJson(),
        'totalCost': inputCost + labourCost + otherCost,
      });
    }

    final yieldRows = await (_db.select(_db.harvestYields)
          ..where((t) => t.cropFieldId.equals(id))
          ..orderBy([(t) => OrderingTerm.desc(t.harvestDate)]))
        .get();

    return CropDetail.fromJson({
      ...crop.toJson(),
      'cropTypeName': await _cropTypeName(crop.cropTypeId),
      'fieldName': field?.name ?? 'Field',
      'costs': {
        'inputs': totalInputs,
        'labour': totalLabour,
        'other': totalOther,
        'total': totalInputs + totalLabour + totalOther,
      },
      'yields': yieldRows.map((y) => y.toJson()).toList(),
      'activities': activities,
    });
  }

  Future<Map<String, dynamic>> _apiBody(Map<String, dynamic> data) async => {
        'field_id': data['fieldId'],
        'crop_type': await _cropTypeName(data['cropTypeId'] as String),
        'variety': asStringOrNull(data['variety']) ?? '',
        'area_planted': asDouble(data['areaPlanted']),
        'season': data['season'],
        'planting_date': (data['plantingDate'] as String).split('T').first,
        'expected_harvest_date': (data['expectedHarvestDate'] as String).split('T').first,
        'status': asStringOrNull(data['status']) ?? 'Active',
      };

  Future<CropFieldModel> createCrop(Map<String, dynamic> data) async {
    final res = await _dio.post('/api/mobile/crops', data: await _apiBody(data));
    final row = (res.data as Map)['data'] as Map<String, dynamic>;
    await _upsertFromApi(row);
    return getCropField(row['id'] as String);
  }

  Future<void> updateCrop(String id, Map<String, dynamic> data) async {
    final current = await (_db.select(_db.cropFields)..where((t) => t.id.equals(id))).getSingle();
    final merged = {
      'fieldId': current.fieldId, // immutable after create — the API ignores it anyway
      'cropTypeId': data.containsKey('cropTypeId') ? data['cropTypeId'] : current.cropTypeId,
      'variety': data.containsKey('variety') ? data['variety'] : current.variety,
      'areaPlanted': data.containsKey('areaPlanted') ? data['areaPlanted'] : current.areaPlanted,
      'season': data.containsKey('season') ? data['season'] : current.season,
      'plantingDate': data.containsKey('plantingDate')
          ? data['plantingDate']
          : current.plantingDate.toIso8601String(),
      'expectedHarvestDate': data.containsKey('expectedHarvestDate')
          ? data['expectedHarvestDate']
          : current.expectedHarvestDate.toIso8601String(),
      'status': data.containsKey('status') ? data['status'] : current.status,
    };

    final res = await _dio.put('/api/mobile/crops/$id', data: await _apiBody(merged));
    final row = (res.data as Map)['data'] as Map<String, dynamic>;
    await _upsertFromApi(row);
  }

  /// The explicit "take it out of focus" action: a harvested crop stops
  /// generating overdue/due-soon and activity-reminder alerts (see
  /// CropDetail.isActive and NotificationsRepository), but — unlike
  /// archiving — stays visible in the normal crop list and still counts
  /// toward the field's allocated area, since the land is still occupied
  /// until something new is planted there.
  Future<void> markHarvested(String id) async {
    await updateCrop(id, {'status': 'Harvested'});
  }

  Future<void> archiveCrop(String id) async {
    final res = await _dio.post('/api/mobile/crops/$id/archive');
    final row = (res.data as Map)['data'] as Map<String, dynamic>;
    await _upsertFromApi(row);
  }

  Future<void> restoreCrop(String id) async {
    final res = await _dio.post('/api/mobile/crops/$id/restore');
    final row = (res.data as Map)['data'] as Map<String, dynamic>;
    await _upsertFromApi(row);
  }

  Future<List<CropType>> getCropTypes() async {
    final rows = await _db.select(_db.cropTypes).get();
    return rows.map((r) => CropType.fromJson(r.toJson())).toList();
  }

  /// Local-only until the crop it's used on is actually saved — the server
  /// resolves-or-creates crop types by name as part of crop create/update,
  /// there's no standalone "create a crop type" endpoint.
  Future<CropType> createCropType(String name) async {
    final id = newId();
    await _db.into(_db.cropTypes).insert(CropTypesCompanion.insert(
          id: id,
          name: name,
          isCustom: const Value(true),
        ));
    return CropType(id: id, name: name, isCustom: true);
  }

  Future<String> _cropTypeName(String cropTypeId) async {
    final type = await (_db.select(_db.cropTypes)
          ..where((t) => t.id.equals(cropTypeId)))
        .getSingleOrNull();
    return type?.name ?? 'Crop';
  }

  Future<double> _sumActivityInputs(String activityId) async {
    final rows = await (_db.select(_db.activityInputs)
          ..where((t) => t.activityId.equals(activityId)))
        .get();
    return rows.fold<double>(0.0, (s, r) => s + r.totalCost);
  }

  Future<double> _sumActivityLabour(String activityId) async {
    final rows = await (_db.select(_db.activityLabourRecords)
          ..where((t) => t.activityId.equals(activityId)))
        .get();
    return rows.fold<double>(0.0, (s, r) => s + r.totalCost);
  }

  Future<double> _sumActivityOtherCosts(String activityId) async {
    final rows = await (_db.select(_db.activityOtherCosts)
          ..where((t) => t.activityId.equals(activityId)))
        .get();
    return rows.fold<double>(0.0, (s, r) => s + r.amount);
  }
}
