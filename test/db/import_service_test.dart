import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/core/migration/import_service.dart';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.dir);
  final Directory dir;

  @override
  Future<String?> getApplicationDocumentsPath() async => dir.path;
}

void main() {
  late AppDatabase db;
  late ImportService service;
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('import_service_test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir);
    db = AppDatabase(NativeDatabase.memory());
    service = ImportService(db);
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Map<String, dynamic> _basePayload() => {
        'farmProfile': {
          'id': 'farm-1',
          'name': 'Chikwawa Farm',
          'location': 'Chikwawa',
          'locationLat': null,
          'locationLng': null,
          'createdAt': DateTime(2024, 1, 1).toIso8601String(),
        },
        'fields': [
          {
            'id': 'field-1',
            'name': 'North Field',
            'totalArea': 10,
            'cultivatableArea': 9,
            'soilType': 'Loam',
            'locationLat': null,
            'locationLng': null,
            'notes': null,
            'createdAt': DateTime(2024, 1, 1).toIso8601String(),
          },
        ],
        'fieldBoundaries': [],
        'fieldZones': [],
        'farmMarkers': [],
        'cropTypes': [
          {'id': 'croptype-1', 'name': 'Maize', 'isCustom': false},
        ],
        'cropFields': [
          {
            'id': 'crop-1',
            'cropTypeId': 'croptype-1',
            'fieldId': 'field-1',
            'variety': 'DK8053',
            'areaPlanted': 3,
            'season': '2026 Rain',
            'plantingDate': DateTime(2026, 1, 1).toIso8601String(),
            'expectedHarvestDate': DateTime(2026, 5, 1).toIso8601String(),
            'status': 'Active',
            'isArchived': false,
            'createdAt': DateTime(2026, 1, 1).toIso8601String(),
          },
        ],
        'employees': [
          {
            'id': 'emp-1',
            'name': 'Grace Banda',
            'role': 'Planting crew',
            'payRate': 5000,
            'payRateUnit': 'day',
            'phone': null,
            'isActive': true,
          },
        ],
        'activities': [
          {
            'id': 'activity-1',
            'activityType': 'Planting',
            'date': DateTime(2026, 1, 15).toIso8601String(),
            'notes': null,
            'fieldId': 'field-1',
            'cropFieldId': 'crop-1',
            'createdAt': DateTime(2026, 1, 15).toIso8601String(),
          },
        ],
        'activityInputs': [
          {
            'id': 'input-1',
            'activityId': 'activity-1',
            'inputName': 'Certified seed',
            'category': 'Seed',
            'quantity': 20,
            'unit': 'kg',
            'unitCost': 2000,
            'totalCost': 40000,
          },
        ],
        'activityLabourRecords': [
          {
            'id': 'labour-1',
            'activityId': 'activity-1',
            'employeeId': 'emp-1',
            'hoursWorked': 8,
            'daysWorked': 1,
            'totalCost': 5000,
          },
        ],
        'activityOtherCosts': [],
        'transactions': [
          {
            'id': 'tx-1',
            'type': 'Income',
            'category': 'Crop sales',
            'amount': 200000,
            'date': DateTime(2026, 5, 5).toIso8601String(),
            'description': 'Maize sale',
            'season': '2026 Rain',
            'fieldId': null,
            'cropFieldId': 'crop-1',
            'harvestYieldId': null,
          },
        ],
        'overheadExpenses': [],
        'harvestYields': [
          {
            'id': 'yield-1',
            'cropFieldId': 'crop-1',
            'harvestDate': DateTime(2026, 5, 2).toIso8601String(),
            'quantity': 500,
            'unit': 'kg',
            'unitWeight': null,
            'notes': null,
            'createdAt': DateTime(2026, 5, 2).toIso8601String(),
          },
        ],
        'inventoryItems': [],
        'inventorySales': [],
        'farmDocuments': [
          {
            'id': 'doc-1',
            'name': 'Receipt',
            'type': 'receipt',
            'url': 'data:image/png;base64,${base64Encode([1, 2, 3, 4])}',
            'size': 4,
            'linkedTo': null,
            'linkedType': null,
            'notes': null,
            'uploadedAt': DateTime(2026, 5, 1).toIso8601String(),
          },
        ],
        'notifications': [],
        'livestockTypes': [
          {'id': 'old-cattle-id', 'name': 'Cattle', 'category': 'Cattle', 'icon': 'Cattle'},
          {'id': 'old-rabbit-id', 'name': 'Rabbits', 'category': 'Rabbits', 'icon': 'Rabbits'},
        ],
        'animals': [
          {
            'id': 'animal-1',
            'livestockTypeId': 'old-cattle-id',
            'tag': 'A-001',
            'name': null,
            'animalGroup': null,
            'sex': 'Female',
            'birthDate': null,
            'acquisitionDate': DateTime(2025, 1, 1).toIso8601String(),
            'acquisitionType': 'Born on farm',
            'acquisitionCost': null,
            'status': 'Active',
            'breed': null,
            'colour': null,
            'weight': null,
            'notes': null,
          },
          {
            'id': 'animal-2',
            'livestockTypeId': 'old-rabbit-id',
            'tag': 'R-001',
            'name': null,
            'animalGroup': null,
            'sex': 'Male',
            'birthDate': null,
            'acquisitionDate': DateTime(2025, 1, 1).toIso8601String(),
            'acquisitionType': 'Born on farm',
            'acquisitionCost': null,
            'status': 'Active',
            'breed': null,
            'colour': null,
            'weight': null,
            'notes': null,
          },
        ],
        'animalHealthRecords': [],
        'animalProductionRecords': [],
        'animalWeightRecords': [],
        'animalExpenseRecords': [],
        'animalSaleRecords': [],
      };

  test('importFromJson populates core tables and reports counts', () async {
    final summary = await service.importFromJson(_basePayload());

    expect(summary.counts['fields'], 1);
    expect(summary.counts['cropFields'], 1);
    expect(summary.counts['activities'], 1);
    expect(summary.counts['activityInputs'], 1);
    expect(summary.counts['transactions'], 1);

    final field = await (db.select(db.fields)).getSingle();
    expect(field.name, 'North Field');

    final profile = await (db.select(db.farmProfile)).getSingleOrNull();
    expect(profile!.name, 'Chikwawa Farm');
  });

  test('importFromJson updates an onboarding-created farm profile in place instead of duplicating it',
      () async {
    // Mirrors onboarding: a profile row already exists with a locally
    // generated id, which won't match the imported row's id.
    await db.into(db.farmProfile).insert(FarmProfileCompanion.insert(
          id: 'locally-generated-id',
          name: 'em',
          location: 'LILONGWE',
          createdAt: DateTime.now(),
        ));

    await service.importFromJson(_basePayload());

    final profiles = await db.select(db.farmProfile).get();
    expect(profiles, hasLength(1));
    expect(profiles.single.id, 'locally-generated-id');
    expect(profiles.single.name, 'Chikwawa Farm');
    expect(profiles.single.location, 'Chikwawa');
  });

  test('importFromJson decodes a base64 document into a real file', () async {
    await service.importFromJson(_basePayload());

    final doc = await (db.select(db.farmDocuments)).getSingle();
    expect(doc.url.startsWith('data:'), isFalse);
    final file = File(doc.url);
    expect(file.existsSync(), isTrue);
    expect(file.readAsBytesSync(), [1, 2, 3, 4]);
  });

  test('importFromJson remaps a livestock type onto the pre-seeded default with the same name',
      () async {
    final seeded = await (db.select(db.livestockTypes)
          ..where((t) => t.name.equals('Cattle')))
        .getSingle();

    await service.importFromJson(_basePayload());

    final allTypes = await db.select(db.livestockTypes).get();
    // No duplicate "Cattle" row was created for the imported one.
    expect(allTypes.where((t) => t.name == 'Cattle'), hasLength(1));

    final animals = await db.select(db.animals).get();
    final cattleAnimal = animals.firstWhere((a) => a.tag == 'A-001');
    expect(cattleAnimal.livestockTypeId, seeded.id);

    // "Rabbits" wasn't seeded by default, so it's imported as a new type
    // and the animal keeps pointing at it.
    final rabbitType =
        allTypes.firstWhere((t) => t.name == 'Rabbits', orElse: () => throw StateError('missing'));
    final rabbitAnimal = animals.firstWhere((a) => a.tag == 'R-001');
    expect(rabbitAnimal.livestockTypeId, rabbitType.id);
  });

  test('importFromJson is safe to run twice without duplicating rows', () async {
    await service.importFromJson(_basePayload());
    await service.importFromJson(_basePayload());

    final fields = await db.select(db.fields).get();
    expect(fields, hasLength(1));
    final activities = await db.select(db.activities).get();
    expect(activities, hasLength(1));
  });
}
