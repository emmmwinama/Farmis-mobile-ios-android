import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/fields/fields_repository.dart';

void main() {
  late AppDatabase db;
  late FieldsRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = FieldsRepository(db);
  });

  tearDown(() async => db.close());

  test('createField then getFields reflects the new field with zero crops',
      () async {
    await repo.createField({
      'name': 'North Field',
      'totalArea': '4.5',
      'cultivatableArea': '4.0',
      'soilType': 'Loam',
      'notes': '',
    });

    final fields = await repo.getFields();
    expect(fields, hasLength(1));
    expect(fields.first.name, 'North Field');
    expect(fields.first.totalArea, 4.5);
    expect(fields.first.cultivatableArea, 4.0);
    expect(fields.first.allocatedArea, 0);
    expect(fields.first.cropCount, 0);
  });

  test('getFields computes allocatedArea/cropCount/crops from crop_fields',
      () async {
    final field = await repo.createField({
      'name': 'South Field',
      'totalArea': '10',
      'cultivatableArea': '9',
      'soilType': 'Clay',
    });

    await db.into(db.cropTypes).insert(
        const CropTypesCompanion(id: Value('ct-1'), name: Value('Maize')));
    await db.into(db.cropFields).insert(CropFieldsCompanion.insert(
          id: 'cf-1',
          cropTypeId: 'ct-1',
          fieldId: field.id,
          variety: 'DK8053',
          areaPlanted: 3.0,
          season: '2026 Rain',
          plantingDate: DateTime(2026, 1, 10),
          expectedHarvestDate: DateTime(2026, 5, 10),
          createdAt: DateTime.now(),
        ));

    final fields = await repo.getFields();
    expect(fields.first.allocatedArea, 3.0);
    expect(fields.first.cropCount, 1);
    expect(fields.first.crops, ['Maize']);
    expect(fields.first.availableArea, 6.0); // 9 cultivatable - 3 allocated
  });

  test('getField(id) returns nested crops and recent activities', () async {
    final field = await repo.createField({
      'name': 'East Field',
      'totalArea': '5',
      'cultivatableArea': '5',
      'soilType': 'Sandy',
    });
    await db.into(db.cropTypes).insert(
        const CropTypesCompanion(id: Value('ct-2'), name: Value('Beans')));
    await db.into(db.cropFields).insert(CropFieldsCompanion.insert(
          id: 'cf-2',
          cropTypeId: 'ct-2',
          fieldId: field.id,
          variety: 'Local',
          areaPlanted: 2.0,
          season: '2026 Rain',
          plantingDate: DateTime(2026, 1, 5),
          expectedHarvestDate: DateTime(2026, 4, 5),
          createdAt: DateTime.now(),
        ));
    await db.into(db.activities).insert(ActivitiesCompanion.insert(
          id: 'a-1',
          activityType: 'Planting',
          date: DateTime(2026, 1, 5),
          fieldId: field.id,
          createdAt: DateTime.now(),
          cropFieldId: const Value('cf-2'),
        ));

    final detail = await repo.getField(field.id);
    expect(detail.name, 'East Field');
    expect(detail.allocatedArea, 2.0);
    expect(detail.crops, hasLength(1));
    expect(detail.crops.first.cropTypeName, 'Beans');
    expect(detail.recentActivities, hasLength(1));
    expect(detail.recentActivities.first.cropName, 'Beans');
  });

  test('getField(id) excludes harvested/archived crops from allocatedArea, '
      'but still lists them under crops', () async {
    final field = await repo.createField({
      'name': 'Mixed Field',
      'totalArea': '10',
      'cultivatableArea': '10',
      'soilType': 'Loam',
    });
    await db.into(db.cropTypes).insert(
        const CropTypesCompanion(id: Value('ct-3'), name: Value('Maize')));

    // Still growing — counts toward allocatedArea.
    await db.into(db.cropFields).insert(CropFieldsCompanion.insert(
          id: 'cf-active',
          cropTypeId: 'ct-3',
          fieldId: field.id,
          variety: 'DK8053',
          areaPlanted: 3.0,
          season: '2026 Rain',
          plantingDate: DateTime(2026, 1, 10),
          expectedHarvestDate: DateTime(2026, 5, 10),
          createdAt: DateTime.now(),
        ));
    // Marked harvested (not archived) — shouldn't count toward allocatedArea
    // anymore, but should still appear in the field's crop history.
    await db.into(db.cropFields).insert(CropFieldsCompanion.insert(
          id: 'cf-harvested',
          cropTypeId: 'ct-3',
          fieldId: field.id,
          variety: 'DK8053',
          areaPlanted: 4.0,
          season: '2025 Rain',
          plantingDate: DateTime(2025, 1, 10),
          expectedHarvestDate: DateTime(2025, 5, 10),
          createdAt: DateTime.now(),
          status: const Value('Harvested'),
        ));
    // Archived — same expectation.
    await db.into(db.cropFields).insert(CropFieldsCompanion.insert(
          id: 'cf-archived',
          cropTypeId: 'ct-3',
          fieldId: field.id,
          variety: 'DK8053',
          areaPlanted: 2.0,
          season: '2024 Rain',
          plantingDate: DateTime(2024, 1, 10),
          expectedHarvestDate: DateTime(2024, 5, 10),
          createdAt: DateTime.now(),
          isArchived: const Value(true),
        ));

    final detail = await repo.getField(field.id);
    expect(detail.allocatedArea, 3.0); // only the still-Active crop
    expect(detail.crops, hasLength(3)); // all three still show in history
  });

  test('getFields excludes harvested/archived crops from allocatedArea and crop tags',
      () async {
    final field = await repo.createField({
      'name': 'Mixed Field List',
      'totalArea': '10',
      'cultivatableArea': '10',
      'soilType': 'Loam',
    });
    await db.into(db.cropTypes).insert(
        const CropTypesCompanion(id: Value('ct-4'), name: Value('Beans')));
    await db.into(db.cropFields).insert(CropFieldsCompanion.insert(
          id: 'cf-h2',
          cropTypeId: 'ct-4',
          fieldId: field.id,
          variety: 'Local',
          areaPlanted: 5.0,
          season: '2025 Rain',
          plantingDate: DateTime(2025, 1, 10),
          expectedHarvestDate: DateTime(2025, 5, 10),
          createdAt: DateTime.now(),
          status: const Value('Harvested'),
        ));

    final fields = await repo.getFields();
    expect(fields.first.allocatedArea, 0);
    expect(fields.first.cropCount, 0);
    expect(fields.first.crops, isEmpty);
  });

  test('updateField patches only provided fields', () async {
    final field = await repo.createField({
      'name': 'West Field',
      'totalArea': '2',
      'cultivatableArea': '2',
      'soilType': 'Loam',
    });

    await repo.updateField(field.id, {'name': 'Renamed Field'});

    final fields = await repo.getFields();
    expect(fields.first.name, 'Renamed Field');
    expect(fields.first.soilType, 'Loam'); // untouched
  });

  test('deleteField removes the row', () async {
    final field = await repo.createField({
      'name': 'To Delete',
      'totalArea': '1',
      'cultivatableArea': '1',
      'soilType': 'Loam',
    });

    await repo.deleteField(field.id);

    expect(await repo.getFields(), isEmpty);
  });
}
