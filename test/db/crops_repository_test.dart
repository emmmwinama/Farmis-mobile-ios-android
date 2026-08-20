import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/crops/crops_repository.dart';
import 'package:farmio_mobile/features/fields/fields_repository.dart';

void main() {
  late AppDatabase db;
  late CropsRepository repo;
  late FieldsRepository fields;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = CropsRepository(db);
    fields = FieldsRepository(db);
  });

  tearDown(() async => db.close());

  Future<String> _seedField() async =>
      (await fields.createField({
        'name': 'North Field',
        'totalArea': '10',
        'cultivatableArea': '9',
        'soilType': 'Loam',
      }))
          .id;

  test('createCropType then createCrop then getCrops reflects it', () async {
    final cropType = await repo.createCropType('Maize');
    final fieldId = await _seedField();

    final crop = await repo.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': fieldId,
      'variety': 'DK8053',
      'areaPlanted': '3.5',
      'season': '2026 Rain',
      'plantingDate': DateTime(2026, 1, 10).toIso8601String(),
      'expectedHarvestDate': DateTime(2026, 5, 10).toIso8601String(),
    });

    final crops = await repo.getCrops();
    expect(crops, hasLength(1));
    expect(crops.first.id, crop.id);
    expect(crops.first.cropTypeName, 'Maize');
    expect(crops.first.fieldName, 'North Field');
    expect(crops.first.status, 'Active');
  });

  test('getCrops filters by archived status', () async {
    final cropType = await repo.createCropType('Beans');
    final fieldId = await _seedField();
    final crop = await repo.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': fieldId,
      'variety': 'Local',
      'areaPlanted': '1',
      'season': '2026 Rain',
      'plantingDate': DateTime(2026, 1, 1).toIso8601String(),
      'expectedHarvestDate': DateTime(2026, 4, 1).toIso8601String(),
    });

    expect(await repo.getCrops(archived: 'false'), hasLength(1));
    expect(await repo.getCrops(archived: 'true'), isEmpty);

    await repo.archiveCrop(crop.id);

    expect(await repo.getCrops(archived: 'false'), isEmpty);
    final archived = await repo.getCrops(archived: 'true');
    expect(archived, hasLength(1));
    expect(archived.first.status, 'Archived');

    await repo.restoreCrop(crop.id);
    final restored = await repo.getCrops(archived: 'false');
    expect(restored, hasLength(1));
    expect(restored.first.status, 'Active');
  });

  test('markHarvested sets status without archiving — stays in the non-archived list', () async {
    final cropType = await repo.createCropType('Beans');
    final fieldId = await _seedField();
    final crop = await repo.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': fieldId,
      'variety': 'Local',
      'areaPlanted': '1',
      'season': '2026 Rain',
      'plantingDate': DateTime(2026, 1, 1).toIso8601String(),
      'expectedHarvestDate': DateTime(2026, 4, 1).toIso8601String(),
    });

    await repo.markHarvested(crop.id);

    final notArchived = await repo.getCrops(archived: 'false');
    expect(notArchived, hasLength(1));
    expect(notArchived.first.status, 'Harvested');
    expect(notArchived.first.isActive, isFalse);
  });

  test('getCrop(id) computes costs from activity children', () async {
    final cropType = await repo.createCropType('Tobacco');
    final fieldId = await _seedField();
    final crop = await repo.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': fieldId,
      'variety': 'Burley',
      'areaPlanted': '2',
      'season': '2026 Rain',
      'plantingDate': DateTime(2026, 1, 1).toIso8601String(),
      'expectedHarvestDate': DateTime(2026, 6, 1).toIso8601String(),
    });

    await db.into(db.activities).insert(ActivitiesCompanion.insert(
          id: 'act-1',
          activityType: 'Spraying',
          date: DateTime(2026, 2, 1),
          fieldId: fieldId,
          createdAt: DateTime.now(),
          cropFieldId: Value(crop.id),
        ));
    await db.into(db.activityInputs).insert(ActivityInputsCompanion.insert(
          id: 'in-1',
          activityId: 'act-1',
          inputName: 'Pesticide',
          category: 'Chemical',
          quantity: 2,
          unit: 'L',
          unitCost: 5000,
          totalCost: 10000,
        ));
    await db
        .into(db.activityLabourRecords)
        .insert(ActivityLabourRecordsCompanion.insert(
          id: 'lab-1',
          activityId: 'act-1',
          employeeId: 'emp-1',
          hoursWorked: 8,
          daysWorked: 1,
          totalCost: 5000,
        ));

    final detail = await repo.getCrop(crop.id);
    expect(detail.cropTypeName, 'Tobacco');
    expect(detail.fieldName, 'North Field');
    expect(detail.costs.inputs, 10000);
    expect(detail.costs.labour, 5000);
    expect(detail.costs.total, 15000);
    expect(detail.activities, hasLength(1));
    expect(detail.activities.first.totalCost, 15000);
  });

  test('deleteCrop removes the row', () async {
    final cropType = await repo.createCropType('Rice');
    final fieldId = await _seedField();
    final crop = await repo.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': fieldId,
      'variety': 'Kilombero',
      'areaPlanted': '1',
      'season': '2026 Rain',
      'plantingDate': DateTime(2026, 1, 1).toIso8601String(),
      'expectedHarvestDate': DateTime(2026, 4, 1).toIso8601String(),
    });

    await repo.deleteCrop(crop.id);

    expect(await repo.getCrops(), isEmpty);
  });
}
