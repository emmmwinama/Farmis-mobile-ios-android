import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/dashboard/dashboard_repository.dart';
import 'package:farmio_mobile/features/fields/fields_repository.dart';
import 'package:farmio_mobile/features/crops/crops_repository.dart';
import 'package:farmio_mobile/features/finance/finance_repository.dart';
import 'package:farmio_mobile/features/employees/employees_repository.dart';
import 'package:farmio_mobile/shared/filters/report_record_filters.dart';

void main() {
  late AppDatabase db;
  late DashboardRepository repo;
  late FieldsRepository fields;
  late CropsRepository crops;
  late FinanceRepository finance;
  late EmployeesRepository employees;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DashboardRepository(db);
    fields = FieldsRepository(db);
    crops = CropsRepository(db);
    finance = FinanceRepository(db);
    employees = EmployeesRepository(db);
  });

  tearDown(() async => db.close());

  test('getDashboard computes income/expense/net within the custom date range',
      () async {
    final now = DateTime.now();
    await finance.createTransaction({
      'type': 'Income',
      'category': 'Crop sales',
      'amount': '100000',
      'date': now.toIso8601String(),
      'description': 'Sale',
    });
    await finance.createTransaction({
      'type': 'Expense',
      'category': 'Inputs',
      'amount': '20000',
      'date': now.toIso8601String(),
      'description': 'Fertiliser',
    });
    // Outside the custom range below -- must not be counted.
    await finance.createTransaction({
      'type': 'Income',
      'category': 'Crop sales',
      'amount': '999999',
      'date': DateTime(2020, 1, 1).toIso8601String(),
      'description': 'Old sale',
    });

    final data = await repo.getDashboard(ReportRecordFilters(
      period: 'Custom',
      dateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 1)),
        end: now.add(const Duration(days: 1)),
      ),
    ));

    expect(data.income, 100000);
    expect(data.expense, 20000);
    expect(data.net, 80000);
  });

  test('getDashboard counts active employees and active crops', () async {
    await employees.createEmployee({
      'name': 'Active Worker',
      'role': 'Field hand',
      'payRate': '5000',
      'payRateUnit': 'day',
    });

    final field = await fields.createField({
      'name': 'Field A',
      'totalArea': '10',
      'cultivatableArea': '9',
      'soilType': 'Loam',
    });
    final cropType = await crops.createCropType('Maize');
    await crops.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': field.id,
      'variety': 'V1',
      'areaPlanted': '3',
      'season': '2026 Rain',
      'plantingDate': DateTime(2026, 1, 1).toIso8601String(),
      'expectedHarvestDate': DateTime(2026, 5, 1).toIso8601String(),
    });

    final data = await repo.getDashboard(const ReportRecordFilters());

    expect(data.activeEmployees, 1);
    expect(data.totalEmployees, 1);
    expect(data.activeCrops, 1);
    expect(data.totalFields, 1);
  });

  test('getDashboard fieldLandUse sums active crop area planted per field',
      () async {
    final field = await fields.createField({
      'name': 'Field A',
      'totalArea': '10',
      'cultivatableArea': '9',
      'soilType': 'Loam',
    });
    final cropType = await crops.createCropType('Maize');
    await crops.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': field.id,
      'variety': 'V1',
      'areaPlanted': '3',
      'season': '2026 Rain',
      'plantingDate': DateTime(2026, 1, 1).toIso8601String(),
      'expectedHarvestDate': DateTime(2026, 5, 1).toIso8601String(),
    });
    await crops.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': field.id,
      'variety': 'V2',
      'areaPlanted': '2',
      'season': '2026 Rain',
      'plantingDate': DateTime(2026, 1, 1).toIso8601String(),
      'expectedHarvestDate': DateTime(2026, 5, 1).toIso8601String(),
    });

    final data = await repo.getDashboard(const ReportRecordFilters());

    expect(data.fieldLandUse, hasLength(1));
    expect(data.fieldLandUse.first.allocated, 5);
    expect(data.fieldLandUse.first.cultivatableArea, 9);
  });

  test('getDashboard filters selected fields by crop and season', () async {
    final fieldA = await fields.createField({
      'name': 'Field A',
      'totalArea': '10',
      'cultivatableArea': '9',
      'soilType': 'Loam',
    });
    final fieldB = await fields.createField({
      'name': 'Field B',
      'totalArea': '5',
      'cultivatableArea': '4',
      'soilType': 'Clay',
    });
    final maize = await crops.createCropType('Maize');
    final soya = await crops.createCropType('Soya');
    await crops.createCrop({
      'cropTypeId': maize.id,
      'fieldId': fieldA.id,
      'variety': 'V1',
      'areaPlanted': '3',
      'season': '2026 Rain',
      'plantingDate': DateTime(2026, 1, 1).toIso8601String(),
      'expectedHarvestDate': DateTime(2026, 5, 1).toIso8601String(),
    });
    await crops.createCrop({
      'cropTypeId': soya.id,
      'fieldId': fieldB.id,
      'variety': 'V2',
      'areaPlanted': '2',
      'season': '2026 Rain',
      'plantingDate': DateTime(2026, 1, 1).toIso8601String(),
      'expectedHarvestDate': DateTime(2026, 5, 1).toIso8601String(),
    });

    final data =
        await repo.getDashboard(const ReportRecordFilters(crop: 'Maize'));

    expect(data.totalFields, 1);
    expect(data.fieldLandUse.first.name, 'Field A');
  });
}
