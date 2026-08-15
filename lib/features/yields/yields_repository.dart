import '../../core/api/api_client.dart';
import '../../core/sync/offline_fallback.dart';
import '../../core/sync/sync_queue_provider.dart';
import '../../models/yield.dart';

class YieldsRepository {
  YieldsRepository(this._syncQueue);

  final SyncQueueNotifier _syncQueue;

  Future<YieldsData> getYields({String? cropFieldId}) async {
    final response = await ApiClient.get(
      '/mobile/yields',
      params: cropFieldId != null
          ? {'cropFieldId': cropFieldId}
          : null,
    );
    return YieldsData.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<void> createYield(Map<String, dynamic> data) async {
    await withOfflineFallback(
      request: () => ApiClient.post('/mobile/yields', data),
      syncQueue: _syncQueue,
      type: 'yield',
      path: '/mobile/yields',
      payload: data,
    );
  }

  Future<void> deleteYield(String id) async {
    await ApiClient.delete('/mobile/yields/$id');
  }
}
