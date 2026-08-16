import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../models/season.dart';

/// Mirrors the backend's `toKg()` conversion (kg passthrough, tonne x1000,
/// bag x unitWeight-or-50-default) so locally-computed totals match what
/// the server used to return.
double _toKg(double quantity, String unit, double? unitWeight) {
  final u = unit.toLowerCase();
  if (u == 'kg') return quantity;
  if (u == 'tonne' || u == 'tonnes' || u == 't') return quantity * 1000;
  if (u.startsWith('bag')) return quantity * (unitWeight ?? 50);
  return quantity;
}

class SeasonsRepository {
  SeasonsRepository(this._db);

  final AppDatabase _db;

  Future<double> _cropCost(String cropFieldId) async {
    final activities = await (_db.select(_db.activities)
          ..where((t) => t.cropFieldId.equals(cropFieldId)))
        .get();
    double cost = 0;
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
      cost += inputs.fold<double>(0, (s, r) => s + r.totalCost);
      cost += labour.fold<double>(0, (s, r) => s + r.totalCost);
      cost += other.fold<double>(0, (s, r) => s + r.amount);
    }
    return cost;
  }

  Future<double> _cropRevenue(String cropFieldId) async {
    final rows = await (_db.select(_db.transactions)
          ..where((t) =>
              t.cropFieldId.equals(cropFieldId) & t.type.equals('Income')))
        .get();
    return rows.fold<double>(0, (s, r) => s + r.amount);
  }

  Future<double> _cropYieldKg(String cropFieldId) async {
    final rows = await (_db.select(_db.harvestYields)
          ..where((t) => t.cropFieldId.equals(cropFieldId)))
        .get();
    return rows.fold<double>(
        0, (s, r) => s + _toKg(r.quantity, r.unit, r.unitWeight));
  }

  Future<int> _activityCount(String cropFieldId) async {
    final rows = await (_db.select(_db.activities)
          ..where((t) => t.cropFieldId.equals(cropFieldId)))
        .get();
    return rows.length;
  }

  Future<SeasonsData> getSeasons({String? season}) async {
    final query = _db.select(_db.cropFields);
    if (season != null) query.where((t) => t.season.equals(season));
    final crops = await query.get();

    final seasons = <String, _SeasonAgg>{};
    for (final crop in crops) {
      final field = await (_db.select(_db.fields)
            ..where((t) => t.id.equals(crop.fieldId)))
          .getSingleOrNull();
      final cropType = await (_db.select(_db.cropTypes)
            ..where((t) => t.id.equals(crop.cropTypeId)))
          .getSingleOrNull();
      final fieldName = field?.name ?? 'Field';
      final cropName = cropType?.name ?? 'Crop';

      final cost = await _cropCost(crop.id);
      final revenue = await _cropRevenue(crop.id);
      final yieldKg = await _cropYieldKg(crop.id);
      final activityCount = await _activityCount(crop.id);
      final archived = crop.isArchived || crop.status == 'Archived';

      final agg = seasons.putIfAbsent(crop.season, () => _SeasonAgg());
      agg.fields.add(fieldName);
      agg.crops.add(cropName);
      agg.cropCount += 1;
      agg.totalArea += crop.areaPlanted;
      agg.totalCost += cost;
      agg.revenue += revenue;
      agg.totalYieldKg += yieldKg;
      agg.activityCount += activityCount;
      if (archived) {
        agg.archivedCrops += 1;
      } else {
        agg.activeCrops += 1;
      }
      agg.cropRows.add({
        'id': crop.id,
        'cropName': cropName,
        'variety': crop.variety,
        'fieldName': fieldName,
        'status': crop.status,
        'areaPlanted': crop.areaPlanted,
        'totalCost': cost,
        'revenue': revenue,
        'totalYieldKg': yieldKg,
      });
    }

    final rows = seasons.entries.map((e) => e.value.toJson(e.key)).toList()
      ..sort((a, b) => (b['season'] as String).compareTo(a['season'] as String));

    return SeasonsData.fromJson({
      'allSeasons': rows.map((r) => r['season']).toList(),
      'seasons': rows,
      'selectedSeason': season,
    });
  }

  Future<SeasonCompareData> compareSeasons(String a, String b) async {
    final allSeasonRows = await (_db.selectOnly(_db.cropFields, distinct: true)
          ..addColumns([_db.cropFields.season])
          ..orderBy([OrderingTerm.desc(_db.cropFields.season)]))
        .get();
    final allSeasons =
        allSeasonRows.map((r) => r.read(_db.cropFields.season)!).toList();

    final sideA = await _seasonSide(a);
    final sideB = await _seasonSide(b);

    return SeasonCompareData.fromJson({
      'allSeasons': allSeasons,
      'seasonA': sideA,
      'seasonB': sideB,
      'comparison': {
        'crops': _diff(
            (sideA['cropCount'] as int).toDouble(), (sideB['cropCount'] as int).toDouble()),
        'area': _diff(sideA['totalArea'] as double, sideB['totalArea'] as double),
        'totalCost': _diff(sideA['totalCost'] as double, sideB['totalCost'] as double,
            higherIsBetter: false),
        'revenue': _diff(sideA['revenue'] as double, sideB['revenue'] as double),
        'netProfit': _diff(sideA['netProfit'] as double, sideB['netProfit'] as double),
        'totalYieldKg':
            _diff(sideA['totalYieldKg'] as double, sideB['totalYieldKg'] as double),
        'yieldPerHa':
            _diff(sideA['yieldPerHa'] as double, sideB['yieldPerHa'] as double),
        'costPerHa': _diff(sideA['costPerHa'] as double, sideB['costPerHa'] as double,
            higherIsBetter: false),
        'costPerKg': sideA['costPerKg'] != null && sideB['costPerKg'] != null
            ? _diff(sideA['costPerKg'] as double, sideB['costPerKg'] as double,
                higherIsBetter: false)
            : null,
      },
    });
  }

  Future<Map<String, dynamic>> _seasonSide(String season) async {
    final crops = await (_db.select(_db.cropFields)
          ..where((t) => t.season.equals(season)))
        .get();

    double totalCost = 0, totalYieldKg = 0, revenue = 0, totalArea = 0;
    final cropTypes = <String>{};
    final rows = <Map<String, dynamic>>[];

    for (final crop in crops) {
      final field = await (_db.select(_db.fields)
            ..where((t) => t.id.equals(crop.fieldId)))
          .getSingleOrNull();
      final cropType = await (_db.select(_db.cropTypes)
            ..where((t) => t.id.equals(crop.cropTypeId)))
          .getSingleOrNull();
      final cropName = cropType?.name ?? 'Crop';
      cropTypes.add(cropName);
      totalArea += crop.areaPlanted;
      totalCost += await _cropCost(crop.id);
      totalYieldKg += await _cropYieldKg(crop.id);
      revenue += await _cropRevenue(crop.id);
      rows.add({
        'id': crop.id,
        'cropName': cropName,
        'fieldName': field?.name ?? 'Field',
        'variety': crop.variety,
        'areaPlanted': crop.areaPlanted,
        'status': crop.status,
      });
    }

    return {
      'season': season,
      'cropCount': crops.length,
      'cropTypes': cropTypes.toList(),
      'totalArea': totalArea,
      'totalCost': totalCost,
      'revenue': revenue,
      'netProfit': revenue - totalCost,
      'totalYieldKg': totalYieldKg,
      'yieldPerHa': totalArea > 0 ? totalYieldKg / totalArea : 0.0,
      'costPerHa': totalArea > 0 ? totalCost / totalArea : 0.0,
      'costPerKg': totalYieldKg > 0 ? totalCost / totalYieldKg : null,
      'rows': rows,
    };
  }

  Map<String, dynamic> _diff(double a, double b, {bool higherIsBetter = true}) {
    final value = a - b;
    final pct = b != 0 ? (value / b.abs()) * 100 : null;
    final improved =
        value.abs() < 0.0001 ? null : (higherIsBetter ? value > 0 : value < 0);
    return {'value': value, 'pct': pct, 'improved': improved};
  }
}

class _SeasonAgg {
  final Set<String> fields = {};
  final Set<String> crops = {};
  final List<Map<String, dynamic>> cropRows = [];
  int cropCount = 0;
  double totalArea = 0;
  double totalCost = 0;
  double revenue = 0;
  double totalYieldKg = 0;
  int activeCrops = 0;
  int archivedCrops = 0;
  int activityCount = 0;

  Map<String, dynamic> toJson(String season) => {
        'season': season,
        'fields': fields.toList(),
        'crops': crops.toList(),
        'cropRows': cropRows,
        'cropCount': cropCount,
        'totalArea': totalArea,
        'totalCost': totalCost,
        'revenue': revenue,
        'totalYieldKg': totalYieldKg,
        'activeCrops': activeCrops,
        'archivedCrops': archivedCrops,
        'activityCount': activityCount,
        'netProfit': revenue - totalCost,
        'yieldPerHa': totalArea > 0 ? totalYieldKg / totalArea : 0.0,
        'costPerHa': totalArea > 0 ? totalCost / totalArea : 0.0,
        'costPerKg': totalYieldKg > 0 ? totalCost / totalYieldKg : null,
      };
}
