import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../models/field.dart';
import '../../models/field_detail.dart';

class FieldsRepository {
  FieldsRepository(this._db);

  final AppDatabase _db;

  Future<List<FieldModel>> getFields() async {
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

  Future<FieldModel> createField(Map<String, dynamic> data) async {
    final id = newId();
    final now = DateTime.now();
    await _db.into(_db.fields).insert(FieldsCompanion.insert(
          id: id,
          name: data['name'] as String,
          totalArea: asDouble(data['totalArea']),
          cultivatableArea: asDouble(data['cultivatableArea']),
          soilType: data['soilType'] as String,
          createdAt: now,
          locationLat: Value(asDoubleOrNull(data['locationLat'])),
          locationLng: Value(asDoubleOrNull(data['locationLng'])),
          notes: Value(asStringOrNull(data['notes'])),
        ));
    return FieldModel.fromJson({
      'id': id,
      'name': data['name'],
      'totalArea': asDouble(data['totalArea']),
      'cultivatableArea': asDouble(data['cultivatableArea']),
      'soilType': data['soilType'],
      'locationLat': asDoubleOrNull(data['locationLat']),
      'locationLng': asDoubleOrNull(data['locationLng']),
      'notes': asStringOrNull(data['notes']),
      'createdAt': now.toIso8601String(),
      'allocatedArea': 0.0,
      'cropCount': 0,
      'crops': const <String>[],
    });
  }

  Future<void> updateField(String id, Map<String, dynamic> data) async {
    await (_db.update(_db.fields)..where((t) => t.id.equals(id))).write(
      FieldsCompanion(
        name: data.containsKey('name')
            ? Value(data['name'] as String)
            : const Value.absent(),
        totalArea: data.containsKey('totalArea')
            ? Value(asDouble(data['totalArea']))
            : const Value.absent(),
        cultivatableArea: data.containsKey('cultivatableArea')
            ? Value(asDouble(data['cultivatableArea']))
            : const Value.absent(),
        soilType: data.containsKey('soilType')
            ? Value(data['soilType'] as String)
            : const Value.absent(),
        locationLat: data.containsKey('locationLat')
            ? Value(asDoubleOrNull(data['locationLat']))
            : const Value.absent(),
        locationLng: data.containsKey('locationLng')
            ? Value(asDoubleOrNull(data['locationLng']))
            : const Value.absent(),
        notes: data.containsKey('notes')
            ? Value(asStringOrNull(data['notes']))
            : const Value.absent(),
      ),
    );
  }

  Future<void> deleteField(String id) async {
    await (_db.delete(_db.fields)..where((t) => t.id.equals(id))).go();
  }

  Future<String> _cropTypeName(String cropTypeId) async {
    final type = await (_db.select(_db.cropTypes)
          ..where((t) => t.id.equals(cropTypeId)))
        .getSingleOrNull();
    return type?.name ?? 'Crop';
  }
}
