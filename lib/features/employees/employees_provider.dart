import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/sync/sync_queue_provider.dart';
import '../../models/employee.dart';
import 'employees_repository.dart';

final employeesRepositoryProvider = Provider<EmployeesRepository>(
  (ref) => EmployeesRepository(ref.read(syncQueueProvider.notifier)),
);

final employeesProvider = FutureProvider.autoDispose<List<EmployeeModel>>(
  (ref) => ref.read(employeesRepositoryProvider).getEmployees(),
);
