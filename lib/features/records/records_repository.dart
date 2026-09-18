import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/db/app_database.dart';
import '../../models/activity.dart';
import '../../models/field.dart';
import '../../models/livestock.dart';
import '../../models/employee.dart';
import '../../models/transaction.dart';
import '../../shared/filters/report_record_filters.dart';
import '../activities/activities_repository.dart';
import '../employees/employees_repository.dart';
import '../fields/fields_repository.dart';
import '../finance/finance_repository.dart';
import '../livestock/livestock_repository.dart';
import '../profile/farm_profile_repository.dart';
import 'records_csv_export_service.dart';
import 'records_pdf_export_service.dart';

/// Real data behind the Records screen's evidence packs — pulls straight
/// from the same repositories the rest of the app uses, so a pack always
/// reflects what's actually on the device.
class RecordsData {
  final List<FieldModel> fields;
  final List<ActivityModel> activities;
  final List<TransactionModel> transactions;
  final List<EmployeeModel> employees;
  final List<Animal> animals;

  const RecordsData({
    required this.fields,
    required this.activities,
    required this.transactions,
    required this.employees,
    required this.animals,
  });

  List<String> get crops => {
        ...activities.map((a) => a.cropName).whereType<String>(),
        ...transactions.map((t) => t.cropName).whereType<String>(),
      }.toList()
    ..sort();

  List<String> get seasons => {
        ...activities.map((a) => a.season).whereType<String>(),
        ...transactions.map((t) => t.season).whereType<String>(),
      }.toList()
    ..sort();

  List<String> get fieldNames => {
        ...fields.map((f) => f.name),
      }.toList()
    ..sort();
}

class RecordsRepository {
  RecordsRepository(AppDatabase db, Dio dio)
      : _fields = FieldsRepository(db, dio),
        _activities = ActivitiesRepository(db, dio),
        _finance = FinanceRepository(db),
        _employees = EmployeesRepository(db, dio),
        _livestock = LivestockRepository(db, dio),
        _profile = FarmProfileRepository(db);

  final FieldsRepository _fields;
  final ActivitiesRepository _activities;
  final FinanceRepository _finance;
  final EmployeesRepository _employees;
  final LivestockRepository _livestock;
  final FarmProfileRepository _profile;

  Future<RecordsData> getRecords() async {
    final fields = await _fields.getFields();
    final activitiesData = await _activities.getActivities();
    final financeData = await _finance.getTransactions();
    final employees = await _employees.getEmployees();
    final livestock = await _livestock.getLivestock();

    return RecordsData(
      fields: fields,
      activities: activitiesData.activities,
      transactions: financeData.transactions,
      employees: employees,
      animals: livestock.animals,
    );
  }

  /// Applies the record filter bar's crop/season/field/date-range selection
  /// in memory — the same fields matter here as in the report builder, but
  /// this filters raw rows instead of aggregated report tables.
  RecordsData applyFilters(RecordsData data, ReportRecordFilters filters) {
    final from = filters.dateRange?.start;
    final to = filters.dateRange?.end;

    bool inRange(DateTime date) {
      if (from != null && date.isBefore(from)) return false;
      if (to != null && date.isAfter(to)) return false;
      return true;
    }

    final fieldNameFilter =
        filters.field == 'All' ? null : filters.field;

    return RecordsData(
      fields: fieldNameFilter == null
          ? data.fields
          : data.fields.where((f) => f.name == fieldNameFilter).toList(),
      activities: data.activities.where((a) {
        if (filters.crop != 'All' && a.cropName != filters.crop) return false;
        if (filters.season != 'All' && a.season != filters.season) return false;
        if (fieldNameFilter != null && a.fieldName != fieldNameFilter) return false;
        return inRange(a.date);
      }).toList(),
      transactions: data.transactions.where((t) {
        if (filters.crop != 'All' && t.cropName != filters.crop) return false;
        if (filters.season != 'All' && t.season != filters.season) return false;
        if (fieldNameFilter != null && t.fieldName != fieldNameFilter) return false;
        return inRange(t.date);
      }).toList(),
      employees: data.employees,
      animals: data.animals,
    );
  }

  Future<String> exportPdf({
    required String pack,
    required ReportRecordFilters filters,
    required Set<String> sections,
  }) async {
    final data = applyFilters(await getRecords(), filters);
    final profile = await _profile.getProfile();

    final bytes = await buildRecordsPdf(
      farmName: profile?.name ?? 'My Farm',
      pack: pack,
      data: data,
      filters: filters,
      sections: sections,
    );

    final dir = await getTemporaryDirectory();
    final date = DateTime.now().toIso8601String().split('T').first;
    final file = File('${dir.path}/agrivault-records-$pack-$date.pdf');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<String> exportCsv({
    required String pack,
    required ReportRecordFilters filters,
    required Set<String> sections,
  }) async {
    final data = applyFilters(await getRecords(), filters);
    final csv = buildRecordsCsv(data: data, sections: sections);

    final dir = await getTemporaryDirectory();
    final date = DateTime.now().toIso8601String().split('T').first;
    final file = File('${dir.path}/agrivault-records-$pack-$date.csv');
    await file.writeAsString(csv);
    return file.path;
  }
}
