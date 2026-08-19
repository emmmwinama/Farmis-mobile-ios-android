import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../models/dashboard_data.dart';
import '../../shared/filters/report_record_filters.dart';

class DashboardRepository {
  DashboardRepository(this._db);

  final AppDatabase _db;

  /// Mirrors the backend's `periodRange()`: an explicit custom date range
  /// wins, otherwise the period preset maps to a fixed lookback window.
  /// ("This year" is 365 trailing days rather than the calendar year — a
  /// quirk of the original route, preserved for behavioural parity.)
  (DateTime, DateTime) _periodRange(ReportRecordFilters filters) {
    final now = DateTime.now();
    final range = filters.dateRange;
    if (range != null) {
      final to = DateTime(
          range.end.year, range.end.month, range.end.day, 23, 59, 59, 999);
      return (range.start, to);
    }

    DateTime from;
    switch (filters.period) {
      case 'Today':
        from = DateTime(now.year, now.month, now.day);
        break;
      case 'This week':
        final weekday = now.weekday; // Monday = 1 .. Sunday = 7
        from = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: weekday - 1));
        break;
      case 'This year':
        from = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 365));
        break;
      case 'This season':
        from = DateTime(now.year, 1, 1);
        break;
      default:
        from = DateTime(now.year, now.month, 1);
    }
    return (from, now);
  }

  Future<DashboardData> getDashboard(ReportRecordFilters filters) async {
    final (from, to) = _periodRange(filters);
    final crop = filters.crop == 'All' ? null : filters.crop;
    final season = filters.season == 'All' ? null : filters.season;
    final hasCropFieldFilter = crop != null || season != null;

    final profile = await _db.select(_db.farmProfile).getSingleOrNull();
    final allFields = await _db.select(_db.fields).get();
    final allCropFields = await _db.select(_db.cropFields).get();

    final cropTypeNames = <String, String>{};
    for (final type in await _db.select(_db.cropTypes).get()) {
      cropTypeNames[type.id] = type.name;
    }

    final selectedCropFields = allCropFields.where((c) {
      if (crop != null && cropTypeNames[c.cropTypeId] != crop) return false;
      if (season != null && c.season != season) return false;
      return true;
    }).toList();

    final selectedFieldIds = selectedCropFields.map((c) => c.fieldId).toSet();
    final selectedFields = hasCropFieldFilter
        ? allFields.where((f) => selectedFieldIds.contains(f.id)).toList()
        : allFields;
    final selectedCropFieldIds = selectedCropFields.map((c) => c.id).toSet();

    final txQuery = _db.select(_db.transactions)
      ..where((t) =>
          t.date.isBiggerOrEqualValue(from) & t.date.isSmallerOrEqualValue(to));
    if (season != null) txQuery.where((t) => t.season.equals(season));
    final transactions = await txQuery.get();
    if (hasCropFieldFilter) {
      transactions.removeWhere(
          (t) => !selectedCropFieldIds.contains(t.cropFieldId));
    }

    final farmFieldIds = allFields.map((f) => f.id).toSet();
    final activityQuery = _db.select(_db.activities)
      ..where((t) =>
          t.date.isBiggerOrEqualValue(from) & t.date.isSmallerOrEqualValue(to));
    var activities = await activityQuery.get();
    activities = activities.where((a) => farmFieldIds.contains(a.fieldId)).toList();
    if (hasCropFieldFilter) {
      activities = activities
          .where((a) => selectedCropFieldIds.contains(a.cropFieldId))
          .toList();
    }

    double labourExpense = 0, inputExpense = 0, otherActivityExpense = 0;
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
      inputExpense += inputs.fold<double>(0, (s, r) => s + r.totalCost);
      labourExpense += labour.fold<double>(0, (s, r) => s + r.totalCost);
      otherActivityExpense += other.fold<double>(0, (s, r) => s + r.amount);
    }

    final overhead = await (_db.select(_db.overheadExpenses)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(from) &
              t.date.isSmallerOrEqualValue(to)))
        .get();
    final overheadExpense = overhead.fold<double>(0, (s, r) => s + r.amount);

    final income = transactions
        .where((t) => t.type == 'Income')
        .fold<double>(0, (s, t) => s + t.amount);
    final transactionExpense = transactions
        .where((t) => t.type == 'Expense')
        .fold<double>(0, (s, t) => s + t.amount);
    final expense = transactionExpense +
        labourExpense +
        inputExpense +
        otherActivityExpense +
        overheadExpense;

    final employees = await _db.select(_db.employees).get();

    final seasons = allCropFields.map((c) => c.season).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    final recentActivityRows = await (_db.select(_db.activities)
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(5))
        .get();
    final recentActivities = <Map<String, dynamic>>[];
    for (final activity in recentActivityRows) {
      final field = await (_db.select(_db.fields)
            ..where((t) => t.id.equals(activity.fieldId)))
          .getSingleOrNull();
      String? cropName;
      final cropFieldId = activity.cropFieldId;
      if (cropFieldId != null) {
        final crop = await (_db.select(_db.cropFields)
              ..where((t) => t.id.equals(cropFieldId)))
            .getSingleOrNull();
        if (crop != null) cropName = cropTypeNames[crop.cropTypeId];
      }
      recentActivities.add({
        'id': activity.id,
        'activityType': activity.activityType,
        'fieldName': field?.name ?? 'Field',
        'cropName': cropName,
        'date': activity.date.toIso8601String(),
      });
    }

    return DashboardData.fromJson({
      'farmName': profile?.name ?? 'My Farm',
      'userName': profile?.ownerName,
      'totalFields': selectedFields.length,
      'totalArea': selectedFields.fold<double>(0, (s, f) => s + f.totalArea),
      'activeCrops':
          selectedCropFields.where((c) => c.status == 'Active').length,
      'activeEmployees': employees.where((e) => e.isActive).length,
      'totalEmployees': employees.length,
      'seasons': seasons,
      'income': income,
      'expense': expense,
      'net': income - expense,
      'expenseBreakdown': [
        {'label': 'Finance transactions', 'amount': transactionExpense},
        {'label': 'Labour', 'amount': labourExpense},
        {'label': 'Inputs', 'amount': inputExpense},
        {'label': 'Other activity costs', 'amount': otherActivityExpense},
        {'label': 'Overhead', 'amount': overheadExpense},
      ],
      'fieldLandUse': selectedFields.map((field) {
        final allocated = allCropFields
            .where((c) => c.fieldId == field.id && c.status == 'Active')
            .fold<double>(0, (s, c) => s + c.areaPlanted);
        return {
          'name': field.name,
          'cultivatableArea': field.cultivatableArea,
          'allocated': allocated,
        };
      }).toList(),
      'recentActivities': recentActivities,
    });
  }
}
