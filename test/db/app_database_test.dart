import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/models/field.dart';
import 'package:farmio_mobile/models/employee.dart';

void main() {
  // Confirms the core migration strategy: drift table column names match
  // each model's fromJson JSON keys, and DateTime columns serialize as
  // ISO8601 strings (via driftRuntimeOptions.defaultSerializer, configured
  // in app_database.dart) so `Model.fromJson(row.toJson())` works unchanged.
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Fields row round-trips through FieldModel.fromJson(row.toJson())',
      () async {
    final createdAt = DateTime.utc(2026, 1, 15, 8, 30);
    await db.into(db.fields).insert(FieldsCompanion.insert(
          id: 'field-1',
          name: 'North Field',
          totalArea: 4.5,
          cultivatableArea: 4.0,
          soilType: 'Loam',
          createdAt: createdAt,
          locationLat: const Value(-13.96),
          locationLng: const Value(33.77),
        ));

    final row = await (db.select(db.fields)
          ..where((t) => t.id.equals('field-1')))
        .getSingle();

    // Fields' allocatedArea/cropCount/crops are computed from crop_fields in
    // the repository layer (Phase 1), not stored columns — supply them here
    // to exercise FieldModel.fromJson with a realistic full payload.
    final model = FieldModel.fromJson({
      ...row.toJson(),
      'allocatedArea': 0.0,
      'cropCount': 0,
      'crops': <String>[],
    });

    expect(model.id, 'field-1');
    expect(model.name, 'North Field');
    expect(model.totalArea, 4.5);
    expect(model.cultivatableArea, 4.0);
    expect(model.soilType, 'Loam');
    expect(model.locationLat, -13.96);
    expect(model.locationLng, 33.77);
    expect(model.createdAt, createdAt);
  });

  test('Employees row round-trips through EmployeeModel.fromJson(row.toJson())',
      () async {
    await db.into(db.employees).insert(EmployeesCompanion.insert(
          id: 'emp-1',
          name: 'Blessings Chibwe',
          role: 'Supervisor',
          payRate: 5000,
          payRateUnit: 'day',
          phone: const Value('+265991234567'),
        ));

    final row = await (db.select(db.employees)
          ..where((t) => t.id.equals('emp-1')))
        .getSingle();
    final model = EmployeeModel.fromJson(row.toJson());

    expect(model.id, 'emp-1');
    expect(model.name, 'Blessings Chibwe');
    expect(model.role, 'Supervisor');
    expect(model.payRate, 5000);
    expect(model.payRateUnit, 'day');
    expect(model.phone, '+265991234567');
    expect(model.isActive, true);
  });
}
