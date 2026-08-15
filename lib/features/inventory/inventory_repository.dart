import '../../core/api/api_client.dart';
import '../../core/sync/offline_fallback.dart';
import '../../core/sync/sync_queue_provider.dart';
import '../../models/inventory_item.dart';

class InventoryRepository {
  InventoryRepository(this._syncQueue);

  final SyncQueueNotifier _syncQueue;

  Future<List<InventoryItem>> getItems({String? category}) async {
    final response = await ApiClient.get(
      '/mobile/inventory',
      params: category != null ? {'category': category} : null,
    );
    final data = response.data as Map<String, dynamic>;
    return (data['items'] as List)
        .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createItem(Map<String, dynamic> data) async {
    await withOfflineFallback(
      request: () => ApiClient.post('/mobile/inventory', data),
      syncQueue: _syncQueue,
      type: 'inventory_item',
      path: '/mobile/inventory',
      payload: data,
    );
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    await ApiClient.patch('/mobile/inventory/$id', data);
  }

  Future<void> deleteItem(String id) async {
    await ApiClient.delete('/mobile/inventory/$id');
  }

  Future<void> createSale(Map<String, dynamic> data) async {
    await withOfflineFallback(
      request: () => ApiClient.post('/mobile/inventory/sales', data),
      syncQueue: _syncQueue,
      type: 'inventory_sale',
      path: '/mobile/inventory/sales',
      payload: data,
    );
  }
}
