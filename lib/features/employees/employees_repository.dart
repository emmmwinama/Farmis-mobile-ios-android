import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../models/employee.dart';

/// Employees live on Ulimi's mobile API now (`/api/mobile/employees`) —
/// same write-through pattern as FieldsRepository: reads pull the farm's
/// employees down into the local table first (falling back to cache when
/// offline), writes go straight to the API and mirror the result locally.
/// Employees aren't in the offline batch queue, so writes need a connection.
class EmployeesRepository {
  EmployeesRepository(this._db, this._dio);

  final AppDatabase _db;
  final Dio _dio;

  Future<List<EmployeeModel>> getEmployees() async {
    await _pullFromApi();
    final rows = await _db.select(_db.employees).get();
    return rows.map((r) => EmployeeModel.fromJson(r.toJson())).toList();
  }

  Future<void> _pullFromApi() async {
    try {
      final res = await _dio.get('/api/mobile/employees');
      final rows = ((res.data as Map)['data'] as List).cast<Map<String, dynamic>>();
      for (final row in rows) {
        await _upsertFromApi(row);
      }
    } catch (_) {
      // Offline or unreachable — fall back to whatever's cached locally.
    }
  }

  Future<void> _upsertFromApi(Map<String, dynamic> row) async {
    await _db.into(_db.employees).insertOnConflictUpdate(EmployeesCompanion.insert(
          id: row['id'] as String,
          name: row['name'] as String,
          role: row['role'] as String,
          payRate: asDouble(row['pay_rate']),
          payRateUnit: row['pay_rate_unit'] as String,
          phone: Value(asStringOrNull(row['phone'])),
          isActive: Value(_asBool(row['is_active'])),
        ));
  }

  bool _asBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return value?.toString() == '1' || value?.toString().toLowerCase() == 'true';
  }

  Map<String, dynamic> _apiBody(Map<String, dynamic> data, {required bool isActive}) => {
        'name': data['name'],
        'role': data['role'],
        'pay_rate': asDouble(data['payRate']),
        'pay_rate_unit': data['payRateUnit'],
        'phone': asStringOrNull(data['phone']),
        'is_active': isActive,
      };

  Future<EmployeeModel> createEmployee(Map<String, dynamic> data) async {
    final res = await _dio.post('/api/mobile/employees', data: _apiBody(data, isActive: true));
    final row = (res.data as Map)['data'] as Map<String, dynamic>;
    await _upsertFromApi(row);
    return EmployeeModel.fromJson({
      'id': row['id'],
      'name': row['name'],
      'role': row['role'],
      'payRate': asDouble(row['pay_rate']),
      'payRateUnit': row['pay_rate_unit'],
      'phone': asStringOrNull(row['phone']),
      'isActive': _asBool(row['is_active']),
    });
  }

  /// The API's `PUT` requires the full object, so this merges onto the
  /// current local row before sending — see FieldsRepository.updateField
  /// for the same reasoning.
  Future<void> updateEmployee(String id, Map<String, dynamic> data) async {
    final current =
        await (_db.select(_db.employees)..where((t) => t.id.equals(id))).getSingle();
    final merged = {
      'name': data.containsKey('name') ? data['name'] : current.name,
      'role': data.containsKey('role') ? data['role'] : current.role,
      'payRate': data.containsKey('payRate') ? data['payRate'] : current.payRate,
      'payRateUnit': data.containsKey('payRateUnit') ? data['payRateUnit'] : current.payRateUnit,
      'phone': data.containsKey('phone') ? data['phone'] : current.phone,
    };

    final res = await _dio.put('/api/mobile/employees/$id',
        data: _apiBody(merged, isActive: current.isActive));
    final row = (res.data as Map)['data'] as Map<String, dynamic>;
    await _upsertFromApi(row);
  }

  /// The server deactivates instead of deleting when the employee has
  /// labour records attached — the response's `data` is the updated
  /// employee row (still present) rather than `true` when that happens.
  Future<void> deleteEmployee(String id) async {
    final res = await _dio.post('/api/mobile/employees/$id/delete');
    final data = (res.data as Map)['data'];
    if (data is Map<String, dynamic>) {
      await _upsertFromApi(data);
    } else {
      await (_db.delete(_db.employees)..where((t) => t.id.equals(id))).go();
    }
  }
}
