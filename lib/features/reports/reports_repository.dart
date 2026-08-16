import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/report_aggregator.dart';
import '../../models/report.dart';
import '../../shared/filters/report_record_filters.dart';

class ReportsRepository {
  ReportsRepository(this._db);

  final AppDatabase _db;

  /// Only `season` and an explicit custom date range affect the fetch here.
  /// Crop/field/archive filtering (and the period presets) are applied
  /// client-side in `reports_screen.dart`'s `_applyLocalFilters`, matching
  /// the backend route this replaces — it only ever read `season`/`from`/`to`
  /// too, despite the filter bar exposing more options.
  Future<ReportData> getReport(ReportRecordFilters filters) async {
    final season = filters.season == 'All' ? null : filters.season;
    final from = filters.dateRange?.start;
    final to = filters.dateRange?.end;

    final txQuery = _db.select(_db.transactions);
    if (season != null) txQuery.where((t) => t.season.equals(season));
    if (from != null) txQuery.where((t) => t.date.isBiggerOrEqualValue(from));
    if (to != null) txQuery.where((t) => t.date.isSmallerOrEqualValue(to));
    final transactions = await txQuery.get();
    final totalIncome = transactions
        .where((t) => t.type == 'Income')
        .fold<double>(0, (s, t) => s + t.amount);

    final overheadQuery = _db.select(_db.overheadExpenses);
    if (from != null) {
      overheadQuery.where((t) => t.date.isBiggerOrEqualValue(from));
    }
    if (to != null) overheadQuery.where((t) => t.date.isSmallerOrEqualValue(to));
    final overhead = await overheadQuery.get();
    final totalOverheadCost = overhead.fold<double>(0, (s, r) => s + r.amount);

    final fields = await _db.select(_db.fields).get();

    final seasonAgg = <String, _SeasonAgg>{};
    final cropAgg = <String, _CropAgg>{};
    final employeeAgg = <String, _EmployeeAgg>{};
    final inputAgg = <String, _InputAgg>{};
    final yieldTypeAgg = <String, _YieldTypeAgg>{};
    final cropFieldDetail = <Map<String, dynamic>>[];
    final yieldRecords = <Map<String, dynamic>>[];
    final fieldReport = <Map<String, dynamic>>[];
    double totalActivityCost = 0;

    for (final field in fields) {
      final cropQuery = _db.select(_db.cropFields)
        ..where((t) => t.fieldId.equals(field.id));
      if (season != null) cropQuery.where((t) => t.season.equals(season));
      final crops = await cropQuery.get();

      double fieldLabour = 0, fieldInput = 0, fieldTotal = 0, fieldAreaPlanted = 0;
      final fieldCrops = <String>{};

      for (final crop in crops) {
        final cropType = await (_db.select(_db.cropTypes)
              ..where((t) => t.id.equals(crop.cropTypeId)))
            .getSingleOrNull();
        final cropName = cropType?.name ?? 'Crop';

        final activities = await (_db.select(_db.activities)
              ..where((t) => t.cropFieldId.equals(crop.id)))
            .get();
        if (from != null || to != null) {
          activities.removeWhere((a) =>
              (from != null && a.date.isBefore(from)) ||
              (to != null && a.date.isAfter(to)));
        }

        double inputCost = 0, labourCost = 0, otherCost = 0;
        for (final activity in activities) {
          final inputs = await (_db.select(_db.activityInputs)
                ..where((t) => t.activityId.equals(activity.id)))
              .get();
          final labour = await (_db.select(_db.activityLabourRecords)
                ..where((t) => t.activityId.equals(activity.id)))
              .get();
          final other = await (_db.select(_db.activityOtherCosts)
                ..where((t) => t.activityId.equals(activity.id)))
              .get();
          inputCost += inputs.fold<double>(0, (s, r) => s + r.totalCost);
          labourCost += labour.fold<double>(0, (s, r) => s + r.totalCost);
          otherCost += other.fold<double>(0, (s, r) => s + r.amount);

          for (final input in inputs) {
            final agg = inputAgg.putIfAbsent(
                input.inputName,
                () => _InputAgg(category: input.category, unit: input.unit));
            agg.totalQuantity += input.quantity;
            agg.usageCount += 1;
            agg.totalCost += input.totalCost;
          }
          for (final record in labour) {
            final employee = await (_db.select(_db.employees)
                  ..where((t) => t.id.equals(record.employeeId)))
                .getSingleOrNull();
            final agg = employeeAgg.putIfAbsent(
                record.employeeId,
                () => _EmployeeAgg(
                    name: employee?.name ?? 'Employee',
                    role: employee?.role ?? ''));
            agg.activities += 1;
            agg.totalDays += record.daysWorked;
            agg.totalHours += record.hoursWorked;
            agg.totalEarned += record.totalCost;
          }
        }

        final cropTotalCost = inputCost + labourCost + otherCost;
        totalActivityCost += cropTotalCost;
        fieldLabour += labourCost;
        fieldInput += inputCost;
        fieldTotal += cropTotalCost;
        fieldAreaPlanted += crop.areaPlanted;
        fieldCrops.add(cropName);

        final sAgg = seasonAgg.putIfAbsent(crop.season, () => _SeasonAgg());
        sAgg.fields.add(field.name);
        sAgg.crops.add(cropName);
        sAgg.totalArea += crop.areaPlanted;
        sAgg.cropCount += 1;
        sAgg.inputCost += inputCost;
        sAgg.labourCost += labourCost;
        sAgg.otherCost += otherCost;
        sAgg.totalCost += cropTotalCost;

        final cAgg = cropAgg.putIfAbsent(cropName, () => _CropAgg());
        cAgg.seasons.add(crop.season);
        cAgg.totalArea += crop.areaPlanted;
        cAgg.count += 1;
        cAgg.inputCost += inputCost;
        cAgg.labourCost += labourCost;
        cAgg.totalCost += cropTotalCost;

        cropFieldDetail.add({
          'id': crop.id,
          'cropName': cropName,
          'variety': crop.variety,
          'fieldName': field.name,
          'season': crop.season,
          'areaPlanted': crop.areaPlanted,
          'status': crop.status,
          'labour': labourCost,
          'inputs': inputCost,
          'other': otherCost,
          'totalCost': cropTotalCost,
          'costPerHectare':
              crop.areaPlanted > 0 ? cropTotalCost / crop.areaPlanted : 0,
        });

        final yields = await (_db.select(_db.harvestYields)
              ..where((t) => t.cropFieldId.equals(crop.id)))
            .get();
        if (from != null || to != null) {
          yields.removeWhere((y) =>
              (from != null && y.harvestDate.isBefore(from)) ||
              (to != null && y.harvestDate.isAfter(to)));
        }
        final totalYieldKg = yields.fold<double>(
            0, (s, y) => s + toKg(y.quantity, y.unit, y.unitWeight));

        final yAgg = yieldTypeAgg.putIfAbsent(cropName, () => _YieldTypeAgg());
        yAgg.records += yields.length;
        yAgg.totalAreaPlanted += crop.areaPlanted;
        yAgg.totalYieldKg += totalYieldKg;
        yAgg.totalCost += cropTotalCost;

        if (totalYieldKg > 0) {
          yieldRecords.add({
            'cropFieldId': crop.id,
            'cropName': cropName,
            'variety': crop.variety,
            'fieldName': field.name,
            'season': crop.season,
            'areaPlanted': crop.areaPlanted,
            'totalYieldKg': totalYieldKg,
            'totalCost': cropTotalCost,
            'costPerKg': totalYieldKg > 0 ? cropTotalCost / totalYieldKg : 0,
            'yieldPerHa':
                crop.areaPlanted > 0 ? totalYieldKg / crop.areaPlanted : 0,
          });
        }
      }

      fieldReport.add({
        'fieldId': field.id,
        'fieldName': field.name,
        'soilType': field.soilType,
        'totalArea': field.totalArea,
        'totalAreaPlanted': fieldAreaPlanted,
        'crops': fieldCrops.toList(),
        'labourCost': fieldLabour,
        'inputCost': fieldInput,
        'totalCost': fieldTotal,
        'costPerHectare': field.totalArea > 0 ? fieldTotal / field.totalArea : 0,
      });
    }

    final seasonReport = seasonAgg.entries.map((e) => e.value.toJson(e.key)).toList()
      ..sort((a, b) => (b['season'] as String).compareTo(a['season'] as String));
    final cropReport = cropAgg.entries.map((e) => e.value.toJson(e.key)).toList()
      ..sort((a, b) =>
          (b['totalCost'] as double).compareTo(a['totalCost'] as double));
    fieldReport.sort((a, b) =>
        (b['totalCost'] as double).compareTo(a['totalCost'] as double));
    final employeeReport =
        employeeAgg.entries.map((e) => e.value.toJson(e.key)).toList()
          ..sort((a, b) => (b['totalEarned'] as double)
              .compareTo(a['totalEarned'] as double));
    final inputReport = inputAgg.entries.map((e) => e.value.toJson(e.key)).toList()
      ..sort((a, b) =>
          (b['totalCost'] as double).compareTo(a['totalCost'] as double));
    final yieldByType =
        yieldTypeAgg.entries.map((e) => e.value.toJson(e.key)).toList()
          ..sort((a, b) => (b['totalYieldKg'] as double)
              .compareTo(a['totalYieldKg'] as double));

    return ReportData.fromJson({
      'financeSummary': {
        'totalIncome': totalIncome,
        'totalActivityCost': totalActivityCost,
        'totalOverheadCost': totalOverheadCost,
        'net': totalIncome - totalActivityCost - totalOverheadCost,
      },
      'seasonReport': seasonReport,
      'cropReport': cropReport,
      'fieldReport': fieldReport,
      'cropFieldDetail': cropFieldDetail,
      'employeeReport': employeeReport,
      'inputReport': inputReport,
      'yieldsReport': {'byType': yieldByType, 'records': yieldRecords},
    });
  }
}

class _SeasonAgg {
  final Set<String> fields = {};
  final Set<String> crops = {};
  int cropCount = 0;
  double totalArea = 0;
  double labourCost = 0;
  double inputCost = 0;
  double otherCost = 0;
  double totalCost = 0;

  Map<String, dynamic> toJson(String season) => {
        'season': season,
        'fields': fields.toList(),
        'crops': crops.toList(),
        'totalArea': totalArea,
        'cropCount': cropCount,
        'labourCost': labourCost,
        'inputCost': inputCost,
        'otherCost': otherCost,
        'totalCost': totalCost,
        'costPerHectare': totalArea > 0 ? totalCost / totalArea : 0,
      };
}

class _CropAgg {
  final Set<String> seasons = {};
  int count = 0;
  double totalArea = 0;
  double labourCost = 0;
  double inputCost = 0;
  double totalCost = 0;

  Map<String, dynamic> toJson(String cropName) => {
        'cropName': cropName,
        'seasons': seasons.toList(),
        'totalArea': totalArea,
        'count': count,
        'labourCost': labourCost,
        'inputCost': inputCost,
        'totalCost': totalCost,
        'costPerHectare': totalArea > 0 ? totalCost / totalArea : 0,
      };
}

class _EmployeeAgg {
  _EmployeeAgg({required this.name, required this.role});
  final String name;
  final String role;
  int activities = 0;
  double totalDays = 0;
  double totalHours = 0;
  double totalEarned = 0;

  Map<String, dynamic> toJson(String employeeId) => {
        'employeeId': employeeId,
        'name': name,
        'role': role,
        'activities': activities,
        'totalDays': totalDays,
        'totalHours': totalHours,
        'totalEarned': totalEarned,
      };
}

class _InputAgg {
  _InputAgg({required this.category, required this.unit});
  final String category;
  final String unit;
  double totalQuantity = 0;
  int usageCount = 0;
  double totalCost = 0;

  Map<String, dynamic> toJson(String inputName) => {
        'inputName': inputName,
        'category': category,
        'unit': unit,
        'totalQuantity': totalQuantity,
        'usageCount': usageCount,
        'totalCost': totalCost,
      };
}

class _YieldTypeAgg {
  int records = 0;
  double totalAreaPlanted = 0;
  double totalYieldKg = 0;
  double totalCost = 0;

  Map<String, dynamic> toJson(String cropName) => {
        'cropName': cropName,
        'records': records,
        'totalAreaPlanted': totalAreaPlanted,
        'totalYieldKg': totalYieldKg,
        'totalCost': totalCost,
        'yieldPerHa': totalAreaPlanted > 0 ? totalYieldKg / totalAreaPlanted : 0,
        'costPerKg': totalYieldKg > 0 ? totalCost / totalYieldKg : 0,
      };
}
