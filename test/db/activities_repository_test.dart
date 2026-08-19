import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/activities/activities_repository.dart';
import 'package:farmio_mobile/features/fields/fields_repository.dart';
import 'package:farmio_mobile/features/crops/crops_repository.dart';
import 'package:farmio_mobile/features/employees/employees_repository.dart';

void main() {
  late AppDatabase db;
  late ActivitiesRepository repo;
  late FieldsRepository fields;
  late CropsRepository crops;
  late EmployeesRepository employees;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ActivitiesRepository(db);
    fields = FieldsRepository(db);
    crops = CropsRepository(db);
    employees = EmployeesRepository(db);
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

  test('createActivity persists inputs/otherCosts and getActivities computes totals',
      () async {
    final fieldId = await _seedField();

    final id = await repo.createActivity({
      'fieldId': fieldId,
      'cropFieldId': null,
      'activityType': 'Land preparation',
      'date': DateTime(2026, 1, 5).toIso8601String(),
      'notes': 'Ploughed the north end',
      'inputs': [
        {
          'inputName': 'Diesel',
          'category': 'Fuel',
          'quantity': '20',
          'unit': 'L',
          'unitCost': '1500',
        },
      ],
      'otherCosts': [
        {'description': 'Tractor hire', 'amount': '30000'},
      ],
    });

    final data = await repo.getActivities();
    expect(data.activities, hasLength(1));
    final activity = data.activities.first;
    expect(activity.id, id);
    expect(activity.activityType, 'Land preparation');
    expect(activity.fieldName, 'North Field');
    expect(activity.totalInputCost, 30000); // 20 * 1500
    expect(activity.totalOtherCost, 30000);
    expect(activity.totalCost, 60000);
    expect(activity.inputCount, 1);
    expect(data.byType, hasLength(1));
    expect(data.byType.first.totalCost, 60000);
  });

  test('getActivity(id) returns full nested detail with cost breakdown',
      () async {
    final fieldId = await _seedField();
    final cropType = await crops.createCropType('Maize');
    final crop = await crops.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': fieldId,
      'variety': 'DK8053',
      'areaPlanted': '2',
      'season': '2026 Rain',
      'plantingDate': DateTime(2026, 1, 1).toIso8601String(),
      'expectedHarvestDate': DateTime(2026, 5, 1).toIso8601String(),
    });

    final id = await repo.createActivity({
      'fieldId': fieldId,
      'cropFieldId': crop.id,
      'activityType': 'Fertilizing',
      'date': DateTime(2026, 2, 1).toIso8601String(),
      'inputs': [
        {
          'inputName': 'NPK',
          'category': 'Fertilizer',
          'quantity': '5',
          'unit': 'bags',
          'unitCost': '20000',
        },
      ],
      'otherCosts': const [],
    });

    final detail = await repo.getActivity(id);
    expect(detail.activityType, 'Fertilizing');
    expect(detail.fieldName, 'North Field');
    expect(detail.cropName, 'Maize');
    expect(detail.costs.inputs, 100000); // 5 * 20000
    expect(detail.costs.total, 100000);
    expect(detail.inputs, hasLength(1));
    expect(detail.inputs.first.inputName, 'NPK');
  });

  test('createActivity persists labour records and getActivity includes them in the cost breakdown',
      () async {
    final fieldId = await _seedField();
    final worker = await employees.createEmployee({
      'name': 'Grace Banda',
      'role': 'Planting crew',
      'payRate': '5000',
      'payRateUnit': 'day',
    });

    final id = await repo.createActivity({
      'fieldId': fieldId,
      'activityType': 'Planting',
      'date': DateTime(2026, 1, 10).toIso8601String(),
      'inputs': const [],
      'otherCosts': const [],
      'labour': [
        {
          'employeeId': worker.id,
          'hoursWorked': '8',
          'daysWorked': '1',
          'totalCost': '5000',
        },
      ],
    });

    final detail = await repo.getActivity(id);
    expect(detail.costs.labour, 5000);
    expect(detail.costs.total, 5000);
    expect(detail.labourRecords, hasLength(1));

    final data = await repo.getActivities();
    expect(data.activities.first.totalLabourCost, 5000);
    expect(data.activities.first.labourCount, 1);
  });

  test('deleteActivity removes the activity and its children', () async {
    final fieldId = await _seedField();
    final id = await repo.createActivity({
      'fieldId': fieldId,
      'activityType': 'Weeding',
      'date': DateTime(2026, 1, 1).toIso8601String(),
      'inputs': const [],
      'otherCosts': [
        {'description': 'Labour hire', 'amount': '5000'},
      ],
    });

    await repo.deleteActivity(id);

    final data = await repo.getActivities();
    expect(data.activities, isEmpty);
    expect(await (db.select(db.activityOtherCosts)).get(), isEmpty);
  });
}
