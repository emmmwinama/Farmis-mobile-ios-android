import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/seasons/seasons_repository.dart';
import 'package:farmio_mobile/features/fields/fields_repository.dart';
import 'package:farmio_mobile/features/crops/crops_repository.dart';
import 'package:farmio_mobile/features/finance/finance_repository.dart';
import 'package:farmio_mobile/features/yields/yields_repository.dart';

void main() {
  late AppDatabase db;
  late SeasonsRepository repo;
  late FieldsRepository fields;
  late CropsRepository crops;
  late FinanceRepository finance;
  late YieldsRepository yields;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SeasonsRepository(db);
    fields = FieldsRepository(db);
    crops = CropsRepository(db);
    finance = FinanceRepository(db);
    yields = YieldsRepository(db);
  });

  tearDown(() async => db.close());

  Future<String> _seedCrop({
    required String season,
    required double areaPlanted,
    required double revenue,
    required double yieldKg,
  }) async {
    final field = await fields.createField({
      'name': 'Field ${DateTime.now().microsecondsSinceEpoch}',
      'totalArea': '10',
      'cultivatableArea': '9',
      'soilType': 'Loam',
    });
    final cropType = await crops.createCropType('Maize');
    final crop = await crops.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': field.id,
      'variety': 'DK8053',
      'areaPlanted': areaPlanted.toString(),
      'season': season,
      'plantingDate': DateTime(2026, 1, 1).toIso8601String(),
      'expectedHarvestDate': DateTime(2026, 5, 1).toIso8601String(),
    });
    await finance.createTransaction({
      'type': 'Income',
      'category': 'Crop sales',
      'amount': revenue.toString(),
      'date': DateTime(2026, 5, 5).toIso8601String(),
      'description': 'Sale',
      'cropFieldId': crop.id,
    });
    await yields.createYield({
      'cropFieldId': crop.id,
      'harvestDate': DateTime(2026, 5, 2).toIso8601String(),
      'quantity': yieldKg.toString(),
      'unit': 'kg',
    });
    return crop.id;
  }

  test('getSeasons aggregates area, revenue and yield across crops in the same season',
      () async {
    await _seedCrop(
        season: '2026 Rain', areaPlanted: 2, revenue: 100000, yieldKg: 500);
    await _seedCrop(
        season: '2026 Rain', areaPlanted: 3, revenue: 150000, yieldKg: 700);
    await _seedCrop(
        season: '2025 Rain', areaPlanted: 1, revenue: 50000, yieldKg: 200);

    final data = await repo.getSeasons();
    expect(data.allSeasons, containsAll(['2026 Rain', '2025 Rain']));

    final rain2026 =
        data.seasons.firstWhere((s) => s.season == '2026 Rain');
    expect(rain2026.cropCount, 2);
    expect(rain2026.totalArea, 5);
    expect(rain2026.revenue, 250000);
    expect(rain2026.totalYieldKg, 1200);
    expect(rain2026.yieldPerHa, 1200 / 5);
  });

  test('compareSeasons computes netProfit deltas with the higher season improved',
      () async {
    await _seedCrop(
        season: '2026 Rain', areaPlanted: 2, revenue: 200000, yieldKg: 500);
    await _seedCrop(
        season: '2025 Rain', areaPlanted: 2, revenue: 100000, yieldKg: 500);

    final data = await repo.compareSeasons('2026 Rain', '2025 Rain');
    expect(data.seasonA.revenue, 200000);
    expect(data.seasonB.revenue, 100000);
    expect(data.comparison.revenue.improved, isTrue);
    expect(data.comparison.netProfit.value, 100000);
  });
}
