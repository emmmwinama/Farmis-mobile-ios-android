import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/employees/employees_repository.dart';

void main() {
  late AppDatabase db;
  late EmployeesRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = EmployeesRepository(db);
  });

  tearDown(() async => db.close());

  test('createEmployee then getEmployees lists it as active', () async {
    await repo.createEmployee({
      'name': 'Grace Banda',
      'role': 'Field worker',
      'payRate': '5000',
      'payRateUnit': 'day',
    });

    final employees = await repo.getEmployees();
    expect(employees, hasLength(1));
    expect(employees.first.name, 'Grace Banda');
    expect(employees.first.isActive, isTrue);
  });

  test('deleteEmployee removes the row', () async {
    await repo.createEmployee({
      'name': 'To Remove',
      'role': 'Field worker',
      'payRate': '5000',
      'payRateUnit': 'day',
    });
    final id = (await repo.getEmployees()).first.id;

    await repo.deleteEmployee(id);

    expect(await repo.getEmployees(), isEmpty);
  });
}
