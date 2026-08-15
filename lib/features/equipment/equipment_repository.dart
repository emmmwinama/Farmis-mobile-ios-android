import '../../core/api/api_client.dart';
import '../../core/sync/offline_fallback.dart';
import '../../core/sync/sync_queue_provider.dart';
import '../../models/equipment_item.dart';
import '../../models/overhead.dart';

class EquipmentData {
  final List<EquipmentItem> equipment;
  final List<OverheadExpense> costs;

  const EquipmentData({required this.equipment, required this.costs});

  factory EquipmentData.fromJson(Map<String, dynamic> json) => EquipmentData(
        equipment: (json['equipment'] as List? ?? const [])
            .map((e) => EquipmentItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        costs: (json['costs'] as List? ?? const [])
            .map((e) => OverheadExpense.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class EquipmentRepository {
  EquipmentRepository(this._syncQueue);

  final SyncQueueNotifier _syncQueue;

  Future<EquipmentData> getEquipment() async {
    final response = await ApiClient.get('/mobile/equipment');
    return EquipmentData.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> addEquipment(Map<String, dynamic> data) async {
    await withOfflineFallback(
      request: () => ApiClient.post('/mobile/equipment', data),
      syncQueue: _syncQueue,
      type: 'equipment_item',
      path: '/mobile/equipment',
      payload: data,
    );
  }

  Future<void> addCost(Map<String, dynamic> data) async {
    final payload = {...data, 'kind': 'cost'};
    await withOfflineFallback(
      request: () => ApiClient.post('/mobile/equipment', payload),
      syncQueue: _syncQueue,
      type: 'equipment_cost',
      path: '/mobile/equipment',
      payload: payload,
    );
  }
}
