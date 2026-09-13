import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../models/equipment.dart';

/// Equipment lives on Ulimi's mobile API now (`/api/mobile/equipment`) —
/// same write-through pattern as the other ported entities. This replaces
/// the previous local-only stand-in, which faked equipment out of
/// inventory items and maintenance costs out of farm-wide overhead
/// expenses matched by name — the server has real dedicated tables for
/// both, so the local schema now mirrors them.
class EquipmentRepository {
  EquipmentRepository(this._db, this._dio);

  final AppDatabase _db;
  final Dio _dio;

  Future<List<EquipmentModel>> getEquipment() async {
    await _pullFromApi();

    final rows = await (_db.select(_db.equipment)
          ..orderBy([(t) => OrderingTerm.asc(t.status), (t) => OrderingTerm.asc(t.name)]))
        .get();
    final result = <EquipmentModel>[];
    for (final row in rows) {
      result.add(await _hydrate(row));
    }
    return result;
  }

  Future<EquipmentModel> getOne(String id) async {
    try {
      final res = await _dio.get('/api/mobile/equipment/$id');
      await _upsertFromApi((res.data as Map)['data'] as Map<String, dynamic>);
    } catch (_) {
      // Offline or unreachable — fall back to whatever's cached locally.
    }

    final row =
        await (_db.select(_db.equipment)..where((t) => t.id.equals(id)))
            .getSingle();
    return _hydrate(row);
  }

  Future<EquipmentModel> _hydrate(EquipmentRow row) async {
    final logs = await (_db.select(_db.equipmentMaintenanceLogs)
          ..where((t) => t.equipmentId.equals(row.id)))
        .get();
    final maintenanceCost = logs.fold(0.0, (s, l) => s + l.cost);
    return EquipmentModel.fromJson({
      ...row.toJson(),
      'logCount': logs.length,
      'maintenanceCost': maintenanceCost,
    });
  }

  Future<void> _pullFromApi() async {
    try {
      final res = await _dio.get('/api/mobile/equipment');
      final rows =
          ((res.data as Map)['data'] as List).cast<Map<String, dynamic>>();
      for (final row in rows) {
        await _upsertFromApi(row);
      }
    } catch (_) {
      // Offline or unreachable — fall back to whatever's cached locally.
    }
  }

  Future<void> _upsertFromApi(Map<String, dynamic> row) async {
    await _db.into(_db.equipment).insertOnConflictUpdate(
          EquipmentCompanion.insert(
            id: row['id'] as String,
            name: row['name'] as String,
            category: row['category'] as String? ?? 'other',
            status: Value(row['status'] as String? ?? 'active'),
            acquisitionDate: Value(row['acquisition_date'] != null
                ? DateTime.tryParse(row['acquisition_date'] as String)
                : null),
            acquisitionCost: Value(asDoubleOrNull(row['acquisition_cost'])),
            notes: Value(asStringOrNull(row['notes'])),
          ),
        );
  }

  Map<String, dynamic> _apiBody(Map<String, dynamic> data) => {
        'name': data['name'],
        'category': data['category'] ?? 'other',
        'status': data['status'] ?? 'active',
        'acquisition_date': data['acquisitionDate'] != null
            ? (data['acquisitionDate'] as String).split('T').first
            : null,
        'acquisition_cost': asDoubleOrNull(data['acquisitionCost']),
        'notes': asStringOrNull(data['notes']),
      };

  Future<void> addEquipment(Map<String, dynamic> data) async {
    final res =
        await _dio.post('/api/mobile/equipment', data: _apiBody(data));
    await _upsertFromApi((res.data as Map)['data'] as Map<String, dynamic>);
  }

  /// The API's `PUT` requires the full object, so this merges onto the
  /// current local row first.
  Future<void> updateEquipment(String id, Map<String, dynamic> data) async {
    final current = await (_db.select(_db.equipment)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    final merged = {
      'name': data.containsKey('name') ? data['name'] : current.name,
      'category':
          data.containsKey('category') ? data['category'] : current.category,
      'status': data.containsKey('status') ? data['status'] : current.status,
      'acquisitionDate': data.containsKey('acquisitionDate')
          ? data['acquisitionDate']
          : current.acquisitionDate?.toIso8601String(),
      'acquisitionCost': data.containsKey('acquisitionCost')
          ? data['acquisitionCost']
          : current.acquisitionCost,
      'notes': data.containsKey('notes') ? data['notes'] : current.notes,
    };

    final res = await _dio.put('/api/mobile/equipment/$id',
        data: _apiBody(merged));
    await _upsertFromApi((res.data as Map)['data'] as Map<String, dynamic>);
  }

  Future<void> deleteEquipment(String id) async {
    await _dio.post('/api/mobile/equipment/$id/delete');
    await (_db.delete(_db.equipment)..where((t) => t.id.equals(id))).go();
    await (_db.delete(_db.equipmentMaintenanceLogs)
          ..where((t) => t.equipmentId.equals(id)))
        .go();
  }

  /* -------------------------------------------------- maintenance logs */

  Future<List<EquipmentMaintenanceLog>> getLogs(String equipmentId) async {
    await _pullLogsFromApi(equipmentId);

    final rows = await (_db.select(_db.equipmentMaintenanceLogs)
          ..where((t) => t.equipmentId.equals(equipmentId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
    return rows.map((r) => EquipmentMaintenanceLog.fromJson(r.toJson())).toList();
  }

  Future<void> _pullLogsFromApi(String equipmentId) async {
    try {
      final res = await _dio.get('/api/mobile/equipment/$equipmentId/logs');
      final rows =
          ((res.data as Map)['data'] as List).cast<Map<String, dynamic>>();
      for (final row in rows) {
        await _upsertLogFromApi(equipmentId, row);
      }
    } catch (_) {
      // Offline or unreachable — fall back to whatever's cached locally.
    }
  }

  Future<void> _upsertLogFromApi(
      String equipmentId, Map<String, dynamic> row) async {
    await _db.into(_db.equipmentMaintenanceLogs).insertOnConflictUpdate(
          EquipmentMaintenanceLogsCompanion.insert(
            id: row['id'] as String,
            equipmentId: equipmentId,
            date: DateTime.parse(row['date'] as String),
            description: row['description'] as String,
            cost: Value(asDouble(row['cost'])),
            hoursUsed: Value(asDoubleOrNull(row['hours_used'])),
            notes: Value(asStringOrNull(row['notes'])),
          ),
        );
  }

  Future<void> addLog(String equipmentId, Map<String, dynamic> data) async {
    final date = (data['date'] as String).split('T').first;
    final res = await _dio.post('/api/mobile/equipment/$equipmentId/logs', data: {
      'date': date,
      'description': data['description'],
      'cost': asDouble(data['cost']),
      'hours_used': asDoubleOrNull(data['hoursUsed']),
      'notes': asStringOrNull(data['notes']),
    });
    final logId = ((res.data as Map)['data'] as Map)['id'] as String;
    await _db.into(_db.equipmentMaintenanceLogs).insert(
          EquipmentMaintenanceLogsCompanion.insert(
            id: logId,
            equipmentId: equipmentId,
            date: DateTime.parse(data['date'] as String),
            description: data['description'] as String,
            cost: Value(asDouble(data['cost'])),
            hoursUsed: Value(asDoubleOrNull(data['hoursUsed'])),
            notes: Value(asStringOrNull(data['notes'])),
          ),
        );
  }

  Future<void> deleteLog(String equipmentId, String logId) async {
    await _dio.post('/api/mobile/equipment/$equipmentId/logs/$logId/delete');
    await (_db.delete(_db.equipmentMaintenanceLogs)
          ..where((t) => t.id.equals(logId)))
        .go();
  }
}
