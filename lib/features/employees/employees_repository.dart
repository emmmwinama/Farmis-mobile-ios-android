import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../models/employee.dart';

class EmployeesRepository {
  EmployeesRepository(this._db);

  final AppDatabase _db;

  Future<List<EmployeeModel>> getEmployees() async {
    final rows = await _db.select(_db.employees).get();
    return rows.map((r) => EmployeeModel.fromJson(r.toJson())).toList();
  }

  Future<EmployeeModel> createEmployee(Map<String, dynamic> data) async {
    final id = newId();
    await _db.into(_db.employees).insert(EmployeesCompanion.insert(
          id: id,
          name: data['name'] as String,
          role: data['role'] as String,
          payRate: asDouble(data['payRate']),
          payRateUnit: data['payRateUnit'] as String,
          phone: Value(asStringOrNull(data['phone'])),
        ));
    return EmployeeModel.fromJson({
      'id': id,
      'name': data['name'],
      'role': data['role'],
      'payRate': asDouble(data['payRate']),
      'payRateUnit': data['payRateUnit'],
      'phone': asStringOrNull(data['phone']),
      'isActive': true,
    });
  }

  Future<void> deleteEmployee(String id) async {
    await (_db.delete(_db.employees)..where((t) => t.id.equals(id))).go();
  }
}
