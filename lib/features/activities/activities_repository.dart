import '../../core/api/api_client.dart';
import '../../core/sync/offline_fallback.dart';
import '../../core/sync/sync_queue_provider.dart';
import '../../models/activity.dart';
import '../../models/activity_detail.dart';

class ActivitiesRepository {
  ActivitiesRepository(this._syncQueue);

  final SyncQueueNotifier _syncQueue;

  Future<ActivitiesData> getActivities({
    String? fieldId,
    String? cropFieldId,
  }) async {
    final response = await ApiClient.get(
      '/mobile/activities',
      params: {
        if (fieldId     != null) 'fieldId':     fieldId,
        if (cropFieldId != null) 'cropFieldId': cropFieldId,
      },
    );
    return ActivitiesData.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<ActivityDetail> getActivity(String id) async {
    final response = await ApiClient.get('/mobile/activities/$id');
    return ActivityDetail.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<String> createActivity(Map<String, dynamic> data) async {
    final response = await withOfflineFallback(
      request: () => ApiClient.post('/mobile/activities', data),
      syncQueue: _syncQueue,
      type: 'activity',
      path: '/mobile/activities',
      payload: data,
    );
    return response.data['id'] as String;
  }

  Future<void> deleteActivity(String id) async {
    await ApiClient.delete('/mobile/activities/$id');
  }
}
