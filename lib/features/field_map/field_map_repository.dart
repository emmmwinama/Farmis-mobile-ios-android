import '../../core/api/api_client.dart';
import '../../core/sync/offline_fallback.dart';
import '../../core/sync/sync_queue_provider.dart';
import '../../models/field_boundary.dart';

class FieldMapRepository {
  FieldMapRepository(this._syncQueue);

  final SyncQueueNotifier _syncQueue;

  Future<FieldMapData> getFieldMap() async {
    final response = await ApiClient.get('/mobile/field-map');
    return FieldMapData.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FieldBoundary?> getBoundary(String fieldId) async {
    final response = await ApiClient.get('/mobile/fields/$fieldId/boundary');
    if (response.data == null) return null;
    return FieldBoundary.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FieldBoundary> saveBoundary(
    String fieldId,
    Map<String, dynamic> geoJson, {
    bool updateFieldArea = true,
  }) async {
    final data = {'geoJson': geoJson, 'updateFieldArea': updateFieldArea};
    final response = await withOfflineFallback(
      request: () =>
          ApiClient.post('/mobile/fields/$fieldId/boundary', data),
      syncQueue: _syncQueue,
      type: 'field_boundary',
      path: '/mobile/fields/$fieldId/boundary',
      payload: data,
    );
    return FieldBoundary.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteBoundary(String fieldId) async {
    await ApiClient.delete('/mobile/fields/$fieldId/boundary');
  }

  Future<List<FieldZone>> getZones(String fieldId) async {
    final response = await ApiClient.get('/mobile/fields/$fieldId/zones');
    final data = response.data as Map<String, dynamic>;
    return (data['zones'] as List)
        .map((e) => FieldZone.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FieldZone> createZone(
    String fieldId,
    Map<String, dynamic> data,
  ) async {
    final response = await withOfflineFallback(
      request: () => ApiClient.post('/mobile/fields/$fieldId/zones', data),
      syncQueue: _syncQueue,
      type: 'field_zone',
      path: '/mobile/fields/$fieldId/zones',
      payload: data,
    );
    return FieldZone.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FieldZone> updateZone(
    String fieldId,
    String zoneId,
    Map<String, dynamic> data,
  ) async {
    final response =
        await ApiClient.patch('/mobile/fields/$fieldId/zones/$zoneId', data);
    return FieldZone.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteZone(String fieldId, String zoneId) async {
    await ApiClient.delete('/mobile/fields/$fieldId/zones/$zoneId');
  }

  Future<List<FarmMarker>> getMarkers({String? fieldId}) async {
    final response = await ApiClient.get(
      '/mobile/markers',
      params: fieldId != null ? {'fieldId': fieldId} : null,
    );
    final data = response.data as Map<String, dynamic>;
    return (data['markers'] as List)
        .map((e) => FarmMarker.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FarmMarker> createMarker(Map<String, dynamic> data) async {
    final response = await withOfflineFallback(
      request: () => ApiClient.post('/mobile/markers', data),
      syncQueue: _syncQueue,
      type: 'farm_marker',
      path: '/mobile/markers',
      payload: data,
    );
    return FarmMarker.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FarmMarker> updateMarker(String id, Map<String, dynamic> data) async {
    final response = await ApiClient.patch('/mobile/markers/$id', data);
    return FarmMarker.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteMarker(String id) async {
    await ApiClient.delete('/mobile/markers/$id');
  }
}
