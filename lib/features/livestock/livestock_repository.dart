import '../../core/api/api_client.dart';
import '../../core/sync/offline_fallback.dart';
import '../../core/sync/sync_queue_provider.dart';
import '../../models/livestock.dart';

class LivestockRepository {
  LivestockRepository(this._syncQueue);

  final SyncQueueNotifier _syncQueue;

  Future<LivestockData> getLivestock() async {
    final response = await ApiClient.get('/mobile/livestock');
    return LivestockData.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Animal> getAnimal(String id) async {
    final response = await ApiClient.get('/mobile/livestock/$id');
    return Animal.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> createAnimal(Map<String, dynamic> data) async {
    await withOfflineFallback(
      request: () => ApiClient.post('/mobile/livestock', data),
      syncQueue: _syncQueue,
      type: 'livestock_animal',
      path: '/mobile/livestock',
      payload: data,
    );
  }

  Future<void> updateAnimal(String id, Map<String, dynamic> data) async {
    await ApiClient.patch('/mobile/livestock/$id', data);
  }

  Future<void> deleteAnimal(String id) async {
    await ApiClient.delete('/mobile/livestock/$id');
  }

  Future<void> addRecord(Map<String, dynamic> data) async {
    await withOfflineFallback(
      request: () => ApiClient.post('/mobile/livestock/records', data),
      syncQueue: _syncQueue,
      type: 'livestock_record',
      path: '/mobile/livestock/records',
      payload: data,
    );
  }
}
