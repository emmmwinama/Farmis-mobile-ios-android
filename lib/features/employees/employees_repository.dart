import '../../core/api/api_client.dart';
import '../../core/sync/offline_fallback.dart';
import '../../core/sync/sync_queue_provider.dart';
import '../../models/employee.dart';

class EmployeesRepository {
  EmployeesRepository(this._syncQueue);

  final SyncQueueNotifier _syncQueue;

  Future<List<EmployeeModel>> getEmployees() async {
    final response = await ApiClient.get('/mobile/employees');
    return (response.data as List)
        .map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EmployeeModel> createEmployee(Map<String, dynamic> data) async {
    final response = await withOfflineFallback(
      request: () => ApiClient.post('/mobile/employees', data),
      syncQueue: _syncQueue,
      type: 'employee',
      path: '/mobile/employees',
      payload: data,
    );
    return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
  }
}
