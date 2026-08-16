import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/compliance/compliance_repository.dart';
import 'package:farmio_mobile/features/fields/fields_repository.dart';
import 'package:farmio_mobile/features/crops/crops_repository.dart';
import 'package:farmio_mobile/features/activities/activities_repository.dart';
import 'package:farmio_mobile/features/yields/yields_repository.dart';
import 'package:farmio_mobile/features/inventory/inventory_repository.dart';
import 'package:farmio_mobile/features/finance/finance_repository.dart';

void main() {
  late AppDatabase db;
  late ComplianceRepository repo;
  late FieldsRepository fields;
  late CropsRepository crops;
  late ActivitiesRepository activities;
  late YieldsRepository yields;
  late InventoryRepository inventory;
  late FinanceRepository finance;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ComplianceRepository(db);
    fields = FieldsRepository(db);
    crops = CropsRepository(db);
    activities = ActivitiesRepository(db);
    yields = YieldsRepository(db);
    inventory = InventoryRepository(db);
    finance = FinanceRepository(db);
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

  test('getCompliance reports a lot as not buyer-ready with no activity',
      () async {
    await _seedCrop();

    final data = await repo.getCompliance();

    expect(data.lots, hasLength(1));
    expect(data.lots.first.checklist['activitiesRecorded'], isFalse);
    expect(data.lots.first.checklist['harvestRecorded'], isFalse);
  });

  test('getCompliance marks activitiesRecorded/harvestRecorded/salesLinked true once populated',
      () async {
    final cropFieldId = await _seedCrop();

    await activities.createActivity({
      'activityType': 'Planting',
      'fieldId': (await fields.getFields()).first.id,
      'cropFieldId': cropFieldId,
      'date': DateTime(2026, 1, 15).toIso8601String(),
      'inputs': [],
      'otherCosts': [],
    });
    await yields.createYield({
      'cropFieldId': cropFieldId,
      'harvestDate': DateTime(2026, 5, 2).toIso8601String(),
      'quantity': '500',
      'unit': 'kg',
    });
    await inventory.createItem({
      'name': 'Maize grain',
      'category': 'Produce',
      'unit': 'kg',
      'quantity': '500',
      'cropFieldId': cropFieldId,
    });
    final itemId = (await inventory.getItems()).first.id;
    await inventory.createSale({
      'inventoryItemId': itemId,
      'quantitySold': '100',
      'pricePerUnit': '300',
      'saleDate': DateTime(2026, 5, 10).toIso8601String(),
    });

    final data = await repo.getCompliance();

    final lot = data.lots.first;
    expect(lot.checklist['activitiesRecorded'], isTrue);
    expect(lot.checklist['harvestRecorded'], isTrue);
    expect(lot.checklist['salesLinked'], isTrue);
  });

  test('getTraceability computes lotId, sprayRecordCount and revenue', () async {
    final cropFieldId = await _seedCrop();
    final field = (await fields.getFields()).first;

    await activities.createActivity({
      'activityType': 'Spraying',
      'fieldId': field.id,
      'cropFieldId': cropFieldId,
      'date': DateTime(2026, 2, 1).toIso8601String(),
      'inputs': [],
      'otherCosts': [],
    });
    await inventory.createItem({
      'name': 'Maize grain',
      'category': 'Produce',
      'unit': 'kg',
      'quantity': '500',
      'cropFieldId': cropFieldId,
    });
    final itemId = (await inventory.getItems()).first.id;
    await inventory.createSale({
      'inventoryItemId': itemId,
      'quantitySold': '100',
      'pricePerUnit': '300',
      'saleDate': DateTime(2026, 5, 10).toIso8601String(),
    });

    final lots = await repo.getTraceability();

    expect(lots, hasLength(1));
    expect(lots.first.lotId, contains('2026 Rain'));
    expect(lots.first.sprayRecordCount, 1);
    expect(lots.first.revenue, 30000);
  });

  test('getCreditReadiness grades based on the fraction of checks passed',
      () async {
    await _seedCrop();
    await finance.createTransaction({
      'type': 'Income',
      'category': 'Crop sales',
      'amount': '100000',
      'date': DateTime(2026, 5, 1).toIso8601String(),
      'description': 'Sale 1',
    });
    await finance.createTransaction({
      'type': 'Income',
      'category': 'Crop sales',
      'amount': '50000',
      'date': DateTime(2026, 5, 2).toIso8601String(),
      'description': 'Sale 2',
    });
    await finance.createTransaction({
      'type': 'Income',
      'category': 'Crop sales',
      'amount': '20000',
      'date': DateTime(2026, 5, 3).toIso8601String(),
      'description': 'Sale 3',
    });

    final data = await repo.getCreditReadiness();

    // fields(pass) + crops(pass) + transactions>=3(pass) + documents(fail) + profitability(pass) = 4/5
    expect(data.readinessScore, 80);
    expect(data.grade, 'A');
    expect(data.summary.income, 170000);
  });
}
