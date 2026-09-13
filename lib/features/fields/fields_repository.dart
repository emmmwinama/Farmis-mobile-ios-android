import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../models/field.dart';
import '../../models/field_detail.dart';

/// Fields live on Ulimi's mobile API now (`/api/mobile/fields`) — this
/// repository pulls the farm's fields down into the local `fields` table on
/// every read (so it degrades to whatever's cached when offline) and writes
/// straight through to the API on create/update/delete, mirroring the
/// result locally afterward. Fields aren't in the offline batch queue (see
/// docs/MOBILE-API.md §8), so writes need a connection.
///
/// Everything below the API call is unchanged from the local-only version:
/// allocated area / crop names are still computed from the local
/// `cropFields` table, which is what keeps Reports/Dashboard/Records
/// working without having to touch them in this pass.
class FieldsRepository {
  FieldsRepository(this._db, this._dio);

  final AppDatabase _db;
  final Dio _dio;

  Future<List<FieldModel>> getFields() async {
    await _pullFromApi();
    return _localFields();
  }

  Future<void> _pullFromApi() async {
    try {
      final res = await _dio.get('/api/mobile/fields');
      final rows = ((res.data as Map)['data'] as List).cast<Map<String, dynamic>>();
      for (final row in rows) {
        await _upsertFromApi(row);
      }
    } catch (_) {
      // Offline or unreachable — fall back to whatever's cached locally.
    }
  }

  Future<void> _upsertFromApi(Map<String, dynamic> row) async {
    await _db.into(_db.fields).insertOnConflictUpdate(FieldsCompanion.insert(
          id: row['id'] as String,
          name: row['name'] as String,
          totalArea: asDouble(row['total_area']),
          cultivatableArea: asDouble(row['cultivatable_area']),
          soilType: row['soil_type'] as String,
          createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
          locationLat: Value(asDoubleOrNull(row['location_lat'])),
          locationLng: Value(asDoubleOrNull(row['location_lng'])),
          notes: Value(asStringOrNull(row['notes'])),
        ));
  }

  Future<List<FieldModel>> _localFields() async {
    final rows = await _db.select(_db.fields).get();
    final result = <FieldModel>[];
    for (final row in rows) {
      final crops = await (_db.select(_db.cropFields)
            ..where((t) =>
                t.fieldId.equals(row.id) &
                t.isArchived.equals(false) &
                t.status.equals('Active')))
          .get();
      final cropNames = <String>{};
      for (final crop in crops) {
        cropNames.add(await _cropTypeName(crop.cropTypeId));
      }
      result.add(FieldModel.fromJson({
        ...row.toJson(),
        'allocatedArea': crops.fold(0.0, (s, c) => s + c.areaPlanted),
        'cropCount': crops.length,
        'crops': cropNames.toList(),
      }));
    }
    return result;
  }

  Future<FieldDetail> getField(String id) async {
    final field =
        await (_db.select(_db.fields)..where((t) => t.id.equals(id)))
            .getSingle();

    final cropRows = await (_db.select(_db.cropFields)
          ..where((t) => t.fieldId.equals(id))
          ..orderBy([(t) => OrderingTerm.desc(t.plantingDate)]))
        .get();
    final crops = <Map<String, dynamic>>[];
    for (final crop in cropRows) {
      crops.add({
        ...crop.toJson(),
        'cropTypeName': await _cropTypeName(crop.cropTypeId),
      });
    }

    final activityRows = await (_db.select(_db.activities)
          ..where((t) => t.fieldId.equals(id))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(10))
        .get();
    final activities = <Map<String, dynamic>>[];
    for (final activity in activityRows) {
      String? cropName;
      final cropFieldId = activity.cropFieldId;
      if (cropFieldId != null) {
        final crop = await (_db.select(_db.cropFields)
              ..where((t) => t.id.equals(cropFieldId)))
            .getSingleOrNull();
        if (crop != null) cropName = await _cropTypeName(crop.cropTypeId);
      }
      activities.add({...activity.toJson(), 'cropName': cropName});
    }

    // Only still-growing crops occupy land — a harvested or archived
    // crop-field's area shouldn't keep counting against what's available to
    // plant next, even though it still belongs in the field's crop history
    // above.
    final allocatedArea = cropRows
        .where((c) => !c.isArchived && c.status == 'Active')
        .fold(0.0, (s, c) => s + c.areaPlanted);

    return FieldDetail.fromJson({
      ...field.toJson(),
      'allocatedArea': allocatedArea,
      'crops': crops,
      'recentActivities': activities,
    });
  }

  Map<String, dynamic> _apiBody(Map<String, dynamic> data) => {
        'name': data['name'],
        'total_area': asDouble(data['totalArea']),
        'cultivatable_area': asDouble(data['cultivatableArea']),
        'soil_type': data['soilType'],
        'location_lat': asDoubleOrNull(data['locationLat']),
        'location_lng': asDoubleOrNull(data['locationLng']),
        'notes': asStringOrNull(data['notes']),
      };

  Future<FieldModel> createField(Map<String, dynamic> data) async {
    final res = await _dio.post('/api/mobile/fields', data: _apiBody(data));
    final row = (res.data as Map)['data'] as Map<String, dynamic>;
    await _upsertFromApi(row);
    return FieldModel.fromJson({
      'id': row['id'],
      'name': row['name'],
      'totalArea': asDouble(row['total_area']),
      'cultivatableArea': asDouble(row['cultivatable_area']),
      'soilType': row['soil_type'],
      'locationLat': asDoubleOrNull(row['location_lat']),
      'locationLng': asDoubleOrNull(row['location_lng']),
      'notes': asStringOrNull(row['notes']),
      'createdAt': row['created_at'] ?? DateTime.now().toIso8601String(),
      'allocatedArea': 0.0,
      'cropCount': 0,
      'crops': const <String>[],
    });
  }

  /// The API's `PUT` requires the full object (no partial update support
  /// server-side), so an update that only touches some fields — like the
  /// rest of this class's callers expect — merges onto the current local
  /// row before sending, rather than sending `data` as-is and risking
  /// zeroing out whatever the caller didn't mention.
  Future<void> updateField(String id, Map<String, dynamic> data) async {
    final current =
        await (_db.select(_db.fields)..where((t) => t.id.equals(id))).getSingle();
    final merged = {
      'name': data.containsKey('name') ? data['name'] : current.name,
      'totalArea': data.containsKey('totalArea') ? data['totalArea'] : current.totalArea,
      'cultivatableArea':
          data.containsKey('cultivatableArea') ? data['cultivatableArea'] : current.cultivatableArea,
      'soilType': data.containsKey('soilType') ? data['soilType'] : current.soilType,
      'locationLat': data.containsKey('locationLat') ? data['locationLat'] : current.locationLat,
      'locationLng': data.containsKey('locationLng') ? data['locationLng'] : current.locationLng,
      'notes': data.containsKey('notes') ? data['notes'] : current.notes,
    };

    final res = await _dio.put('/api/mobile/fields/$id', data: _apiBody(merged));
    final row = (res.data as Map)['data'] as Map<String, dynamic>;
    await _upsertFromApi(row);
  }

  Future<void> deleteField(String id) async {
    await _dio.post('/api/mobile/fields/$id/delete');
    await (_db.delete(_db.fields)..where((t) => t.id.equals(id))).go();
  }

  Future<String> _cropTypeName(String cropTypeId) async {
    final type = await (_db.select(_db.cropTypes)
          ..where((t) => t.id.equals(cropTypeId)))
        .getSingleOrNull();
    return type?.name ?? 'Crop';
  }
}
