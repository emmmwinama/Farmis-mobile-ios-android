import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../models/yield.dart';

/// Mirrors the backend's `toKg()` conversion (kg passthrough, tonne x1000,
/// bag x unitWeight-or-50-default) so locally-computed totals match what
/// the server used to return.
double _toKg(double quantity, String unit, double? unitWeight) {
  final u = unit.toLowerCase();
  if (u == 'kg') return quantity;
  if (u == 'tonne') return quantity * 1000;
  if (u.startsWith('bag')) return quantity * (unitWeight ?? 50);
  return quantity;
}

class YieldsRepository {
  YieldsRepository(this._db);

  final AppDatabase _db;

  Future<YieldsData> getYields({String? cropFieldId}) async {
    final query = _db.select(_db.harvestYields)
      ..orderBy([(t) => OrderingTerm.desc(t.harvestDate)]);
    if (cropFieldId != null) {
      query.where((t) => t.cropFieldId.equals(cropFieldId));
    }
    final rows = await query.get();

    final yields = <Map<String, dynamic>>[];
    final byCrop = <String, _CropAgg>{};
    double totalKg = 0;

    for (final row in rows) {
      final crop = await (_db.select(_db.cropFields)
            ..where((t) => t.id.equals(row.cropFieldId)))
          .getSingleOrNull();
      String cropTypeName = 'Crop';
      String variety = '';
      String season = '';
      String fieldName = 'Field';
      if (crop != null) {
        final type = await (_db.select(_db.cropTypes)
              ..where((t) => t.id.equals(crop.cropTypeId)))
            .getSingleOrNull();
        cropTypeName = type?.name ?? 'Crop';
        variety = crop.variety;
        season = crop.season;
        final field = await (_db.select(_db.fields)
              ..where((t) => t.id.equals(crop.fieldId)))
            .getSingleOrNull();
        fieldName = field?.name ?? 'Field';
      }

      final kg = _toKg(row.quantity, row.unit, row.unitWeight);
      totalKg += kg;
      yields.add({
        ...row.toJson(),
        'totalKg': kg,
        'cropTypeName': cropTypeName,
        'variety': variety,
        'season': season,
        'fieldName': fieldName,
      });

      byCrop.putIfAbsent(cropTypeName, () => _CropAgg()).add(kg);
    }

    return YieldsData.fromJson({
      'yields': yields,
      'summary': {
        'totalRecords': rows.length,
        'totalKg': totalKg,
        'byCrop': byCrop.entries
            .map((e) => {
                  'crop': e.key,
                  'count': e.value.count,
                  'totalKg': e.value.totalKg,
                })
            .toList(),
      },
    });
  }

  Future<void> createYield(Map<String, dynamic> data) async {
    await _db.into(_db.harvestYields).insert(HarvestYieldsCompanion.insert(
          id: newId(),
          cropFieldId: data['cropFieldId'] as String,
          harvestDate: DateTime.parse(data['harvestDate'] as String),
          quantity: asDouble(data['quantity']),
          unit: data['unit'] as String,
          createdAt: DateTime.now(),
          unitWeight: Value(asDoubleOrNull(data['unitWeight'])),
          notes: Value(asStringOrNull(data['notes'])),
        ));
  }

  Future<void> deleteYield(String id) async {
    await (_db.delete(_db.harvestYields)..where((t) => t.id.equals(id))).go();
  }
}

class _CropAgg {
  int count = 0;
  double totalKg = 0;

  void add(double kg) {
    count++;
    totalKg += kg;
  }
}
