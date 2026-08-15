import '../../core/api/api_client.dart';
import '../../core/sync/offline_fallback.dart';
import '../../core/sync/sync_queue_provider.dart';
import '../../models/field.dart';
import '../../models/field_detail.dart';

class FieldsRepository {
  FieldsRepository(this._syncQueue);

  final SyncQueueNotifier _syncQueue;

  Future<List<FieldModel>> getFields() async {
    final response = await ApiClient.get('/mobile/fields');
    return (response.data as List)
        .map((e) => FieldModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FieldDetail> getField(String id) async {
    final response = await ApiClient.get('/mobile/fields/$id');
    return FieldDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FieldModel> createField(Map<String, dynamic> data) async {
    final response = await withOfflineFallback(
      request: () => ApiClient.post('/mobile/fields', data),
      syncQueue: _syncQueue,
      type: 'field',
      path: '/mobile/fields',
      payload: data,
    );
    return FieldModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> updateField(String id, Map<String, dynamic> data) async {
    await ApiClient.patch('/mobile/fields/$id', data);
  }

  Future<void> deleteField(String id) async {
    await ApiClient.delete('/mobile/fields/$id');
  }
}
