import 'package:dio/dio.dart';
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

/// Harvest yields live on Ulimi's mobile API now (`/api/mobile/yields`) —
/// same write-through pattern as FieldsRepository. Storage/drying/loss
/// records stay local-only for now — the app has no screen for them yet
/// (see YieldFormScreen's "storage" note), so there's nothing to port.
class YieldsRepository {
  YieldsRepository(this._db, this._dio);

  final AppDatabase _db;
  final Dio _dio;

  Future<YieldsData> getYields({String? cropFieldId}) async {
    await _pullFromApi();

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

  Future<void> _pullFromApi() async {
    try {
      final res = await _dio.get('/api/mobile/yields');
      final rows = ((res.data as Map)['data'] as List).cast<Map<String, dynamic>>();
      for (final row in rows) {
        await _upsertFromApi(row);
      }
    } catch (_) {
      // Offline or unreachable — fall back to whatever's cached locally.
    }
  }

  Future<void> _upsertFromApi(Map<String, dynamic> row) async {
    await _db.into(_db.harvestYields).insertOnConflictUpdate(HarvestYieldsCompanion.insert(
          id: row['id'] as String,
          cropFieldId: row['crop_field_id'] as String,
          harvestDate: DateTime.parse(row['harvest_date'] as String),
          quantity: asDouble(row['quantity']),
          unit: row['unit'] as String,
          createdAt:
              DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
          unitWeight: Value(asDoubleOrNull(row['unit_weight'])),
          notes: Value(asStringOrNull(row['notes'])),
        ));
  }

  Map<String, dynamic> _apiBody(Map<String, dynamic> data) => {
        'crop_field_id': data['cropFieldId'],
        'harvest_date': (data['harvestDate'] as String).split('T').first,
        'quantity': asDouble(data['quantity']),
        'unit': data['unit'],
        'unit_weight': asDoubleOrNull(data['unitWeight']),
        'notes': asStringOrNull(data['notes']),
      };

  Future<void> createYield(Map<String, dynamic> data) async {
    final res = await _dio.post('/api/mobile/yields', data: _apiBody(data));
    await _upsertFromApi((res.data as Map)['data'] as Map<String, dynamic>);
  }

  /// The API's `PUT` requires the full object (crop_field_id included, even
  /// though it can't actually be changed after creation — the server just
  /// ignores it there), so this merges onto the current local row first.
  Future<void> updateYield(String id, Map<String, dynamic> data) async {
    final current =
        await (_db.select(_db.harvestYields)..where((t) => t.id.equals(id))).getSingle();
    final merged = {
      'cropFieldId': current.cropFieldId,
      'harvestDate': data.containsKey('harvestDate')
          ? data['harvestDate']
          : current.harvestDate.toIso8601String(),
      'quantity': data.containsKey('quantity') ? data['quantity'] : current.quantity,
      'unit': data.containsKey('unit') ? data['unit'] : current.unit,
      'unitWeight': data.containsKey('unitWeight') ? data['unitWeight'] : current.unitWeight,
      'notes': data.containsKey('notes') ? data['notes'] : current.notes,
    };

    final res = await _dio.put('/api/mobile/yields/$id', data: _apiBody(merged));
    await _upsertFromApi((res.data as Map)['data'] as Map<String, dynamic>);
  }

  Future<void> deleteYield(String id) async {
    await _dio.post('/api/mobile/yields/$id/delete');
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
