import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/database_provider.dart';
import '../../models/employee.dart';
import 'employees_repository.dart';

final employeesRepositoryProvider = Provider<EmployeesRepository>(
  (ref) => EmployeesRepository(ref.read(databaseProvider)),
);

final employeesProvider = FutureProvider.autoDispose<List<EmployeeModel>>(
  (ref) => ref.read(employeesRepositoryProvider).getEmployees(),
);
