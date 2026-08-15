import '../../core/api/api_client.dart';
import '../../core/sync/offline_fallback.dart';
import '../../core/sync/sync_queue_provider.dart';
import '../../models/transaction.dart';
import '../../models/overhead.dart';

class FinanceRepository {
  FinanceRepository(this._syncQueue);

  final SyncQueueNotifier _syncQueue;

  Future<FinanceData> getTransactions({
    String? season,
    String? type,
  }) async {
    final response = await ApiClient.get(
      '/mobile/finance',
      params: {
        if (season != null) 'season': season,
        if (type   != null) 'type':   type,
      },
    );
    return FinanceData.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<void> createTransaction(Map<String, dynamic> data) async {
    await withOfflineFallback(
      request: () => ApiClient.post('/mobile/finance', data),
      syncQueue: _syncQueue,
      type: 'finance',
      path: '/mobile/finance',
      payload: data,
    );
  }

  Future<void> deleteTransaction(String id) async {
    await ApiClient.delete('/mobile/finance/$id');
  }

  Future<OverheadData> getOverhead() async {
    final response = await ApiClient.get('/mobile/overhead');
    return OverheadData.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<void> createOverhead(Map<String, dynamic> data) async {
    await withOfflineFallback(
      request: () => ApiClient.post('/mobile/overhead', data),
      syncQueue: _syncQueue,
      type: 'finance',
      path: '/mobile/overhead',
      payload: data,
    );
  }

  Future<void> deleteOverhead(String id) async {
    await ApiClient.delete('/mobile/overhead/$id');
  }
}
