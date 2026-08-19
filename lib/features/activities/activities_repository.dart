import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../models/activity.dart';
import '../../models/activity_detail.dart';

class _Agg {
  int count = 0;
  double totalCost = 0;
  final Set<String> types = {};

  void add(double cost, [String? type]) {
    count++;
    totalCost += cost;
    if (type != null) types.add(type);
  }
}

class ActivitiesRepository {
  ActivitiesRepository(this._db);

  final AppDatabase _db;

  Future<ActivitiesData> getActivities({
    String? fieldId,
    String? cropFieldId,
  }) async {
    final query = _db.select(_db.activities)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    if (fieldId != null) query.where((t) => t.fieldId.equals(fieldId));
    if (cropFieldId != null) {
      query.where((t) => t.cropFieldId.equals(cropFieldId));
    }
    final rows = await query.get();

    final activities = <Map<String, dynamic>>[];
    final allSeasons = <String>{};
    final byType = <String, _Agg>{};
    final byField = <String, _Agg>{};
    final bySeason = <String, _Agg>{};

    for (final row in rows) {
      final field = await (_db.select(_db.fields)
            ..where((t) => t.id.equals(row.fieldId)))
          .getSingleOrNull();

      String? cropName, cropVariety, season;
      final rowCropFieldId = row.cropFieldId;
      if (rowCropFieldId != null) {
        final crop = await (_db.select(_db.cropFields)
              ..where((t) => t.id.equals(rowCropFieldId)))
            .getSingleOrNull();
        if (crop != null) {
          cropName = await _cropTypeName(crop.cropTypeId);
          cropVariety = crop.variety;
          season = crop.season;
        }
      }

      final inputs = await (_db.select(_db.activityInputs)
            ..where((t) => t.activityId.equals(row.id)))
          .get();
      final labour = await (_db.select(_db.activityLabourRecords)
            ..where((t) => t.activityId.equals(row.id)))
          .get();
      final other = await (_db.select(_db.activityOtherCosts)
            ..where((t) => t.activityId.equals(row.id)))
          .get();

      final inputCost = inputs.fold<double>(0, (s, r) => s + r.totalCost);
      final labourCost = labour.fold<double>(0, (s, r) => s + r.totalCost);
      final otherCost = other.fold<double>(0, (s, r) => s + r.amount);
      final totalCost = inputCost + labourCost + otherCost;

      activities.add({
        ...row.toJson(),
        'fieldName': field?.name ?? 'Field',
        'cropName': cropName,
        'cropVariety': cropVariety,
        'season': season,
        'totalCost': totalCost,
        'totalInputCost': inputCost,
        'totalLabourCost': labourCost,
        'totalOtherCost': otherCost,
        'inputCount': inputs.length,
        'labourCount': labour.length,
        'inputs': inputs.map((r) => r.toJson()).toList(),
        'labourRecords': await _labourJson(labour),
        'otherCosts': other.map((r) => r.toJson()).toList(),
      });

      if (season != null) allSeasons.add(season);
      byType.putIfAbsent(row.activityType, () => _Agg()).add(totalCost);
      byField.putIfAbsent(field?.name ?? 'Field', () => _Agg()).add(totalCost);
      if (season != null) {
        bySeason
            .putIfAbsent(season, () => _Agg())
            .add(totalCost, row.activityType);
      }
    }

    return ActivitiesData.fromJson({
      'activities': activities,
      'allSeasons': allSeasons.toList(),
      'byType': byType.entries
          .map((e) => {
                'type': e.key,
                'count': e.value.count,
                'totalCost': e.value.totalCost,
              })
          .toList(),
      'byField': byField.entries
          .map((e) => {
                'name': e.key,
                'count': e.value.count,
                'totalCost': e.value.totalCost,
              })
          .toList(),
      'bySeason': bySeason.entries
          .map((e) => {
                'season': e.key,
                'count': e.value.count,
                'totalCost': e.value.totalCost,
                'types': e.value.types.toList(),
              })
          .toList(),
    });
  }

  Future<ActivityDetail> getActivity(String id) async {
    final row = await (_db.select(_db.activities)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    final field = await (_db.select(_db.fields)
          ..where((t) => t.id.equals(row.fieldId)))
        .getSingleOrNull();

    String? cropName;
    final rowCropFieldId = row.cropFieldId;
    if (rowCropFieldId != null) {
      final crop = await (_db.select(_db.cropFields)
            ..where((t) => t.id.equals(rowCropFieldId)))
          .getSingleOrNull();
      if (crop != null) cropName = await _cropTypeName(crop.cropTypeId);
    }

    final inputs = await (_db.select(_db.activityInputs)
          ..where((t) => t.activityId.equals(id)))
        .get();
    final labour = await (_db.select(_db.activityLabourRecords)
          ..where((t) => t.activityId.equals(id)))
        .get();
    final other = await (_db.select(_db.activityOtherCosts)
          ..where((t) => t.activityId.equals(id)))
        .get();

    final inputCost = inputs.fold<double>(0, (s, r) => s + r.totalCost);
    final labourCost = labour.fold<double>(0, (s, r) => s + r.totalCost);
    final otherCost = other.fold<double>(0, (s, r) => s + r.amount);

    return ActivityDetail.fromJson({
      ...row.toJson(),
      'fieldName': field?.name ?? 'Field',
      'cropName': cropName,
      'costs': {
        'inputs': inputCost,
        'labour': labourCost,
        'other': otherCost,
        'total': inputCost + labourCost + otherCost,
      },
      'inputs': inputs.map((r) => r.toJson()).toList(),
      'labourRecords': await _labourJson(labour),
      'otherCosts': other.map((r) => r.toJson()).toList(),
    });
  }

  Future<List<Map<String, dynamic>>> _labourJson(
      List<ActivityLabourRecord> labour) async {
    final result = <Map<String, dynamic>>[];
    for (final record in labour) {
      result.add({
        ...record.toJson(),
        'employeeName': await _employeeName(record.employeeId),
      });
    }
    return result;
  }

  Future<String> _employeeName(String employeeId) async {
    final employee = await (_db.select(_db.employees)
          ..where((t) => t.id.equals(employeeId)))
        .getSingleOrNull();
    return employee?.name ?? 'Worker';
  }

  Future<String> createActivity(Map<String, dynamic> data) async {
    final id = newId();
    await _db.into(_db.activities).insert(ActivitiesCompanion.insert(
          id: id,
          activityType: data['activityType'] as String,
          date: DateTime.parse(data['date'] as String),
          fieldId: data['fieldId'] as String,
          createdAt: DateTime.now(),
          notes: Value(asStringOrNull(data['notes'])),
          cropFieldId: Value(asStringOrNull(data['cropFieldId'])),
        ));

    for (final raw in (data['inputs'] as List? ?? const [])) {
      final input = raw as Map;
      final quantity = asDouble(input['quantity']);
      final unitCost = asDouble(input['unitCost']);
      await _db.into(_db.activityInputs).insert(ActivityInputsCompanion.insert(
            id: newId(),
            activityId: id,
            inputName: input['inputName'] as String,
            category: asStringOrNull(input['category']) ?? 'Other',
            quantity: quantity,
            unit: asStringOrNull(input['unit']) ?? '',
            unitCost: unitCost,
            totalCost: quantity * unitCost,
          ));
    }

    for (final raw in (data['otherCosts'] as List? ?? const [])) {
      final cost = raw as Map;
      await _db
          .into(_db.activityOtherCosts)
          .insert(ActivityOtherCostsCompanion.insert(
            id: newId(),
            activityId: id,
            description: cost['description'] as String,
            amount: asDouble(cost['amount']),
          ));
    }

    for (final raw in (data['labour'] as List? ?? const [])) {
      final labour = raw as Map;
      final hours = asDouble(labour['hoursWorked']);
      final days = asDouble(labour['daysWorked']);
      await _db.into(_db.activityLabourRecords).insert(
            ActivityLabourRecordsCompanion.insert(
              id: newId(),
              activityId: id,
              employeeId: labour['employeeId'] as String,
              hoursWorked: hours,
              daysWorked: days,
              totalCost: asDouble(labour['totalCost']),
            ),
          );
    }

    return id;
  }

  Future<void> deleteActivity(String id) async {
    await (_db.delete(_db.activityInputs)
          ..where((t) => t.activityId.equals(id)))
        .go();
    await (_db.delete(_db.activityLabourRecords)
          ..where((t) => t.activityId.equals(id)))
        .go();
    await (_db.delete(_db.activityOtherCosts)
          ..where((t) => t.activityId.equals(id)))
        .go();
    await (_db.delete(_db.activities)..where((t) => t.id.equals(id))).go();
  }

  Future<String> _cropTypeName(String cropTypeId) async {
    final type = await (_db.select(_db.cropTypes)
          ..where((t) => t.id.equals(cropTypeId)))
        .getSingleOrNull();
    return type?.name ?? 'Crop';
  }
}
