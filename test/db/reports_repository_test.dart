import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/core/db/db_utils.dart';
import 'package:farmio_mobile/features/reports/reports_repository.dart';
import 'package:farmio_mobile/features/fields/fields_repository.dart';
import 'package:farmio_mobile/features/crops/crops_repository.dart';
import 'package:farmio_mobile/features/activities/activities_repository.dart';
import 'package:farmio_mobile/features/finance/finance_repository.dart';
import 'package:farmio_mobile/features/employees/employees_repository.dart';
import 'package:farmio_mobile/features/yields/yields_repository.dart';
import 'package:farmio_mobile/shared/filters/report_record_filters.dart';

void main() {
  late AppDatabase db;
  late ReportsRepository repo;
  late FieldsRepository fields;
  late CropsRepository crops;
  late ActivitiesRepository activities;
  late FinanceRepository finance;
  late EmployeesRepository employees;
  late YieldsRepository yields;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ReportsRepository(db);
    fields = FieldsRepository(db);
    crops = CropsRepository(db);
    activities = ActivitiesRepository(db);
    finance = FinanceRepository(db);
    employees = EmployeesRepository(db);
    yields = YieldsRepository(db);
  });

  tearDown(() async => db.close());

  test('getReport aggregates cost across two crops on the same field and season',
      () async {
    final field = await fields.createField({
      'name': 'North Field',
      'totalArea': '10',
      'cultivatableArea': '9',
      'soilType': 'Loam',
    });
    final cropType = await crops.createCropType('Maize');
    final maize = await crops.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': field.id,
      'variety': 'DK8053',
      'areaPlanted': '3',
      'season': '2026 Rain',
      'plantingDate': DateTime(2026, 1, 1).toIso8601String(),
      'expectedHarvestDate': DateTime(2026, 5, 1).toIso8601String(),
    });
    final employee = await employees.createEmployee({
      'name': 'Grace Banda',
      'role': 'Planting crew',
      'payRate': '5000',
      'payRateUnit': 'day',
    });

    final activityId = await activities.createActivity({
      'activityType': 'Planting',
      'fieldId': field.id,
      'cropFieldId': maize.id,
      'date': DateTime(2026, 1, 15).toIso8601String(),
      'inputs': [
        {
          'inputName': 'Certified seed',
          'category': 'Seed',
          'quantity': '20',
          'unit': 'kg',
          'unitCost': '2000',
        },
      ],
      'otherCosts': [],
    });
    // activities_repository.dart's createActivity doesn't create labour
    // records (the create-activity form never collected hours/days), so
    // insert one directly to exercise the reports aggregator's labour
    // cost/employee-report logic against the schema it's built for.
    await db.into(db.activityLabourRecords).insert(
          ActivityLabourRecordsCompanion.insert(
            id: newId(),
            activityId: activityId,
            employeeId: employee.id,
            hoursWorked: 8,
            daysWorked: 1,
            totalCost: 5000,
          ),
        );

    await yields.createYield({
      'cropFieldId': maize.id,
      'harvestDate': DateTime(2026, 5, 2).toIso8601String(),
      'quantity': '500',
      'unit': 'kg',
    });
    await finance.createTransaction({
      'type': 'Income',
      'category': 'Crop sales',
      'amount': '200000',
      'date': DateTime(2026, 5, 5).toIso8601String(),
      'description': 'Maize sale',
      'season': '2026 Rain',
    });

    final data = await repo.getReport(const ReportRecordFilters());

    expect(data.financeSummary.totalIncome, 200000);
    expect(data.financeSummary.totalActivityCost, 45000);
    expect(data.financeSummary.net, 200000 - 45000);

    expect(data.seasonReport, hasLength(1));
    expect(data.seasonReport.first.totalCost, 45000);
    expect(data.seasonReport.first.cropCount, 1);

    expect(data.cropReport, hasLength(1));
    expect(data.cropReport.first.cropName, 'Maize');
    expect(data.cropReport.first.totalCost, 45000);

    expect(data.fieldReport, hasLength(1));
    expect(data.fieldReport.first.fieldName, 'North Field');
    expect(data.fieldReport.first.totalCost, 45000);

    expect(data.cropFieldDetail, hasLength(1));
    expect(data.cropFieldDetail.first.inputs, 40000);
    expect(data.cropFieldDetail.first.labour, 5000);

    expect(data.employeeReport, hasLength(1));
    expect(data.employeeReport.first.name, 'Grace Banda');
    expect(data.employeeReport.first.totalEarned, 5000);

    expect(data.inputReport, hasLength(1));
    expect(data.inputReport.first.inputName, 'Certified seed');
    expect(data.inputReport.first.totalCost, 40000);

    expect(data.yieldsReport.byType, hasLength(1));
    expect(data.yieldsReport.byType.first.totalYieldKg, 500);
    expect(data.yieldsReport.records, hasLength(1));
  });

  test('getReport includes fields with no crops this season at zero cost',
      () async {
    await fields.createField({
      'name': 'Empty Field',
      'totalArea': '5',
      'cultivatableArea': '4',
      'soilType': 'Clay',
    });

    final data = await repo.getReport(const ReportRecordFilters());

    expect(data.fieldReport, hasLength(1));
    expect(data.fieldReport.first.totalCost, 0);
    expect(data.fieldReport.first.crops, isEmpty);
  });

  test('getReport filters by season', () async {
    final field = await fields.createField({
      'name': 'Field A',
      'totalArea': '10',
      'cultivatableArea': '9',
      'soilType': 'Loam',
    });
    final cropType = await crops.createCropType('Soya');
    await crops.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': field.id,
      'variety': 'V1',
      'areaPlanted': '2',
      'season': '2025 Rain',
      'plantingDate': DateTime(2025, 1, 1).toIso8601String(),
      'expectedHarvestDate': DateTime(2025, 5, 1).toIso8601String(),
    });
    await crops.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': field.id,
      'variety': 'V2',
      'areaPlanted': '3',
      'season': '2026 Rain',
      'plantingDate': DateTime(2026, 1, 1).toIso8601String(),
      'expectedHarvestDate': DateTime(2026, 5, 1).toIso8601String(),
    });

    final data = await repo.getReport(
        const ReportRecordFilters(season: '2026 Rain'));

    expect(data.cropFieldDetail, hasLength(1));
    expect(data.cropFieldDetail.first.season, '2026 Rain');
  });
}
