import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/yields/yields_repository.dart';
import 'package:farmio_mobile/features/fields/fields_repository.dart';
import 'package:farmio_mobile/features/crops/crops_repository.dart';

void main() {
  late AppDatabase db;
  late YieldsRepository repo;
  late FieldsRepository fields;
  late CropsRepository crops;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = YieldsRepository(db);
    fields = FieldsRepository(db);
    crops = CropsRepository(db);
  });

  tearDown(() async => db.close());

  Future<String> _seedCrop() async {
    final field = await fields.createField({
      'name': 'North Field',
      'totalArea': '10',
      'cultivatableArea': '9',
      'soilType': 'Loam',
    });
    final cropType = await crops.createCropType('Maize');
    final crop = await crops.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': field.id,
      'variety': 'DK8053',
      'areaPlanted': '3',
      'season': '2026 Rain',
      'plantingDate': DateTime(2026, 1, 1).toIso8601String(),
      'expectedHarvestDate': DateTime(2026, 5, 1).toIso8601String(),
    });
    return crop.id;
  }

  test('createYield with kg unit then getYields computes totalKg directly',
      () async {
    final cropFieldId = await _seedCrop();

    await repo.createYield({
      'cropFieldId': cropFieldId,
      'harvestDate': DateTime(2026, 5, 2).toIso8601String(),
      'quantity': '500',
      'unit': 'kg',
    });

    final data = await repo.getYields();
    expect(data.yields, hasLength(1));
    expect(data.yields.first.totalKg, 500);
    expect(data.yields.first.cropTypeName, 'Maize');
    expect(data.yields.first.fieldName, 'North Field');
    expect(data.summary.totalRecords, 1);
    expect(data.summary.totalKg, 500);
    expect(data.summary.byCrop, hasLength(1));
    expect(data.summary.byCrop.first.totalKg, 500);
  });

  test('createYield with bags unit uses unitWeight, defaulting to 50kg',
      () async {
    final cropFieldId = await _seedCrop();

    await repo.createYield({
      'cropFieldId': cropFieldId,
      'harvestDate': DateTime(2026, 5, 2).toIso8601String(),
      'quantity': '10',
      'unit': 'bags',
      // no unitWeight supplied -> defaults to 50kg/bag
    });
    await repo.createYield({
      'cropFieldId': cropFieldId,
      'harvestDate': DateTime(2026, 5, 3).toIso8601String(),
      'quantity': '4',
      'unit': 'bags',
      'unitWeight': '90', // explicit 90kg bags
    });

    final data = await repo.getYields();
    expect(data.summary.totalKg, 500 + 360); // 10*50 + 4*90
  });

  test('getYields filters by cropFieldId', () async {
    final cropA = await _seedCrop();
    final cropB = await _seedCrop();

    await repo.createYield({
      'cropFieldId': cropA,
      'harvestDate': DateTime(2026, 5, 1).toIso8601String(),
      'quantity': '100',
      'unit': 'kg',
    });
    await repo.createYield({
      'cropFieldId': cropB,
      'harvestDate': DateTime(2026, 5, 1).toIso8601String(),
      'quantity': '200',
      'unit': 'kg',
    });

    final filtered = await repo.getYields(cropFieldId: cropA);
    expect(filtered.yields, hasLength(1));
    expect(filtered.yields.first.cropFieldId, cropA);
  });

  test('deleteYield removes the row', () async {
    final cropFieldId = await _seedCrop();
    await repo.createYield({
      'cropFieldId': cropFieldId,
      'harvestDate': DateTime(2026, 5, 1).toIso8601String(),
      'quantity': '100',
      'unit': 'kg',
    });
    final before = await repo.getYields();
    final id = before.yields.first.id;

    await repo.deleteYield(id);

    expect((await repo.getYields()).yields, isEmpty);
  });
}
