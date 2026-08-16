import 'package:drift/drift.dart';
import 'app_database.dart';

/// Mirrors the backend's `toKg()` conversion (kg passthrough, tonne x1000,
/// bag x unitWeight-or-50-default) so locally-computed totals match what
/// the server used to return.
double toKg(double quantity, String unit, double? unitWeight) {
  final u = unit.toLowerCase();
  if (u == 'kg') return quantity;
  if (u == 'tonne' || u == 'tonnes' || u == 't') return quantity * 1000;
  if (u.startsWith('bag')) return quantity * (unitWeight ?? 50);
  return quantity;
}

class ActivityCostBreakdown {
  final double inputCost;
  final double labourCost;
  final double otherCost;

  const ActivityCostBreakdown({
    required this.inputCost,
    required this.labourCost,
    required this.otherCost,
  });

  static const zero =
      ActivityCostBreakdown(inputCost: 0, labourCost: 0, otherCost: 0);

  double get total => inputCost + labourCost + otherCost;

  ActivityCostBreakdown operator +(ActivityCostBreakdown other) =>
      ActivityCostBreakdown(
        inputCost: inputCost + other.inputCost,
        labourCost: labourCost + other.labourCost,
        otherCost: otherCost + other.otherCost,
      );
}

/// Shared per-crop cost/revenue/yield primitives reused by the reports,
/// dashboard, and report-builder repositories — each of those screens
/// re-derives the same activity-cost/finance/yield aggregation the old
/// backend computed once per route.
class ReportAggregator {
  ReportAggregator(this._db);

  final AppDatabase _db;

  /// Activities linked to [cropFieldId], optionally restricted to a date
  /// window. Field-only activities (no cropFieldId) are intentionally
  /// excluded, matching the backend's `crop.activities` relation.
  Future<List<Activity>> activitiesForCrop(
    String cropFieldId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final query = _db.select(_db.activities)
      ..where((t) => t.cropFieldId.equals(cropFieldId));
    if (from != null) query.where((t) => t.date.isBiggerOrEqualValue(from));
    if (to != null) query.where((t) => t.date.isSmallerOrEqualValue(to));
    return query.get();
  }

  Future<ActivityCostBreakdown> activityCost(String activityId) async {
    final inputs = await (_db.select(_db.activityInputs)
          ..where((t) => t.activityId.equals(activityId)))
        .get();
    final labour = await (_db.select(_db.activityLabourRecords)
          ..where((t) => t.activityId.equals(activityId)))
        .get();
    final other = await (_db.select(_db.activityOtherCosts)
          ..where((t) => t.activityId.equals(activityId)))
        .get();
    return ActivityCostBreakdown(
      inputCost: inputs.fold<double>(0, (s, r) => s + r.totalCost),
      labourCost: labour.fold<double>(0, (s, r) => s + r.totalCost),
      otherCost: other.fold<double>(0, (s, r) => s + r.amount),
    );
  }

  /// Combined cost of every activity linked to [cropFieldId].
  Future<ActivityCostBreakdown> cropCost(
    String cropFieldId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final activities =
        await activitiesForCrop(cropFieldId, from: from, to: to);
    var total = ActivityCostBreakdown.zero;
    for (final activity in activities) {
      total = total + await activityCost(activity.id);
    }
    return total;
  }

  Future<double> cropRevenue(
    String cropFieldId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final query = _db.select(_db.transactions)
      ..where(
          (t) => t.cropFieldId.equals(cropFieldId) & t.type.equals('Income'));
    if (from != null) query.where((t) => t.date.isBiggerOrEqualValue(from));
    if (to != null) query.where((t) => t.date.isSmallerOrEqualValue(to));
    final rows = await query.get();
    return rows.fold<double>(0, (s, r) => s + r.amount);
  }

  Future<List<HarvestYield>> yieldsForCrop(
    String cropFieldId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final query = _db.select(_db.harvestYields)
      ..where((t) => t.cropFieldId.equals(cropFieldId));
    if (from != null) {
      query.where((t) => t.harvestDate.isBiggerOrEqualValue(from));
    }
    if (to != null) query.where((t) => t.harvestDate.isSmallerOrEqualValue(to));
    return query.get();
  }

  Future<double> cropYieldKg(
    String cropFieldId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final rows = await yieldsForCrop(cropFieldId, from: from, to: to);
    return rows.fold<double>(
        0, (s, r) => s + toKg(r.quantity, r.unit, r.unitWeight));
  }
}
