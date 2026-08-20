import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../models/crop_field.dart';
import '../../models/crop_detail.dart';
import '../../models/crop_type.dart';

class CropsRepository {
  CropsRepository(this._db);

  final AppDatabase _db;

  Future<List<CropFieldModel>> getCrops({String? archived}) async {
    final query = _db.select(_db.cropFields);
    if (archived == 'true') {
      query.where((t) => t.status.equals('Archived'));
    } else if (archived == 'false') {
      query.where((t) => t.status.equals('Archived').not());
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

  Future<CropFieldModel> createCrop(Map<String, dynamic> data) async {
    final id = newId();
    final now = DateTime.now();
    await _db.into(_db.cropFields).insert(CropFieldsCompanion.insert(
          id: id,
          cropTypeId: data['cropTypeId'] as String,
          fieldId: data['fieldId'] as String,
          variety: asStringOrNull(data['variety']) ?? '',
          areaPlanted: asDouble(data['areaPlanted']),
          season: data['season'] as String,
          plantingDate: DateTime.parse(data['plantingDate'] as String),
          expectedHarvestDate:
              DateTime.parse(data['expectedHarvestDate'] as String),
          status: Value(asStringOrNull(data['status']) ?? 'Active'),
          createdAt: now,
        ));
    return getCrops().then((list) => list.firstWhere((c) => c.id == id));
  }

  /// The explicit "take it out of focus" action: a harvested crop stops
  /// generating overdue/due-soon and activity-reminder alerts (see
  /// CropDetail.isActive and NotificationsRepository), but — unlike
  /// archiving — stays visible in the normal crop list and still counts
  /// toward the field's allocated area, since the land is still occupied
  /// until something new is planted there.
  Future<void> markHarvested(String id) async {
    await (_db.update(_db.cropFields)..where((t) => t.id.equals(id))).write(
      const CropFieldsCompanion(status: Value('Harvested')),
    );
  }

  Future<void> archiveCrop(String id) async {
    await (_db.update(_db.cropFields)..where((t) => t.id.equals(id))).write(
      const CropFieldsCompanion(
        status: Value('Archived'),
        isArchived: Value(true),
      ),
    );
  }

  Future<void> restoreCrop(String id) async {
    await (_db.update(_db.cropFields)..where((t) => t.id.equals(id))).write(
      const CropFieldsCompanion(
        status: Value('Active'),
        isArchived: Value(false),
      ),
    );
  }

  Future<void> deleteCrop(String id) async {
    await (_db.delete(_db.cropFields)..where((t) => t.id.equals(id))).go();
  }

  Future<List<CropType>> getCropTypes() async {
    final rows = await _db.select(_db.cropTypes).get();
    return rows.map((r) => CropType.fromJson(r.toJson())).toList();
  }

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
