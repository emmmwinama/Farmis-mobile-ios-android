import '../../core/api/api_client.dart';
import '../../core/sync/offline_fallback.dart';
import '../../core/sync/sync_queue_provider.dart';
import '../../models/crop_field.dart';
import '../../models/crop_detail.dart';
import '../../models/crop_type.dart';

class CropsRepository {
  CropsRepository(this._syncQueue);

  final SyncQueueNotifier _syncQueue;

  Future<List<CropFieldModel>> getCrops({String? archived}) async {
    final response = await ApiClient.get(
      '/mobile/crops',
      params: archived != null ? {'archived': archived} : null,
    );
    return (response.data as List)
        .map((e) => CropFieldModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CropDetail> getCrop(String id) async {
    final response = await ApiClient.get('/mobile/crops/$id');
    return CropDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CropFieldModel> createCrop(Map<String, dynamic> data) async {
    final response = await withOfflineFallback(
      request: () => ApiClient.post('/mobile/crops', data),
      syncQueue: _syncQueue,
      type: 'crop',
      path: '/mobile/crops',
      payload: data,
    );
    return CropFieldModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> archiveCrop(String id) async {
    await ApiClient.patch('/mobile/crops/$id', {'action': 'archive'});
  }

  Future<void> restoreCrop(String id) async {
    await ApiClient.patch('/mobile/crops/$id', {'action': 'restore'});
  }

  Future<void> deleteCrop(String id) async {
    await ApiClient.delete('/mobile/crops/$id');
  }

  Future<List<CropType>> getCropTypes() async {
    final response = await ApiClient.get('/mobile/crop_types');
    return (response.data as List)
        .map((e) => CropType.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CropType> createCropType(String name) async {
    final response = await ApiClient.post('/mobile/crop_types', {'name': name});
    return CropType.fromJson(response.data as Map<String, dynamic>);
  }
}
