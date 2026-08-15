import '../../core/api/api_client.dart';

class MobileOperationsRepository {
  Future<Object?> getFieldMap() async {
    final response = await ApiClient.get('/mobile/field-map');
    return response.data;
  }

  Future<Map<String, dynamic>> getFieldBoundary(String fieldId) async {
    final response = await ApiClient.get('/mobile/fields/$fieldId/boundary');
    return _map(response.data);
  }

  Future<void> saveFieldBoundary(
    String fieldId,
    Map<String, dynamic> payload,
  ) async {
    await ApiClient.post('/mobile/fields/$fieldId/boundary', payload);
  }

  Future<void> deleteFieldBoundary(String fieldId) async {
    await ApiClient.delete('/mobile/fields/$fieldId/boundary');
  }

  Future<List<Map<String, dynamic>>> getFieldZones(String fieldId) async {
    final response = await ApiClient.get('/mobile/fields/$fieldId/zones');
    return _list(response.data);
  }

  Future<void> createFieldZone(
    String fieldId,
    Map<String, dynamic> payload,
  ) async {
    await ApiClient.post('/mobile/fields/$fieldId/zones', payload);
  }

  Future<void> updateFieldZone(
    String fieldId,
    String zoneId,
    Map<String, dynamic> payload,
  ) async {
    await ApiClient.patch('/mobile/fields/$fieldId/zones/$zoneId', payload);
  }

  Future<void> deleteFieldZone(String fieldId, String zoneId) async {
    await ApiClient.delete('/mobile/fields/$fieldId/zones/$zoneId');
  }

  Future<List<Map<String, dynamic>>> getMarkers() async {
    final response = await ApiClient.get('/mobile/markers');
    return _list(response.data);
  }

  Future<void> createMarker(Map<String, dynamic> payload) async {
    await ApiClient.post('/mobile/markers', payload);
  }

  Future<void> updateMarker(String markerId, Map<String, dynamic> payload) async {
    await ApiClient.patch('/mobile/markers/$markerId', payload);
  }

  Future<void> deleteMarker(String markerId) async {
    await ApiClient.delete('/mobile/markers/$markerId');
  }

  Future<Object?> getSeasons() async {
    final response = await ApiClient.get('/mobile/seasons');
    return response.data;
  }

  Future<Object?> compareSeasons({
    String? currentSeasonId,
    String? comparisonSeasonId,
  }) async {
    final response = await ApiClient.get('/mobile/seasons/compare', params: {
      if (currentSeasonId != null) 'currentSeasonId': currentSeasonId,
      if (comparisonSeasonId != null) 'comparisonSeasonId': comparisonSeasonId,
    });
    return response.data;
  }

  Future<Object?> getWeather() async {
    final response = await ApiClient.get('/mobile/weather');
    return response.data;
  }

  Future<Object?> getCreditReadiness() async {
    final response = await ApiClient.get('/mobile/credit-readiness');
    return response.data;
  }

  Future<Object?> getCompliance() async {
    final response = await ApiClient.get('/mobile/compliance');
    return response.data;
  }

  Future<Object?> getTeam() async {
    final response = await ApiClient.get('/mobile/team');
    return response.data;
  }

  Future<void> saveTeamMember(Map<String, dynamic> payload) async {
    await ApiClient.post('/mobile/team', payload);
  }

  Future<Object?> getGraphCatalog() async {
    final response = await ApiClient.get('/mobile/graph-catalog');
    return response.data;
  }

  Future<Map<String, dynamic>> getAnimal(String id) async {
    final response = await ApiClient.get('/mobile/livestock/$id');
    return _map(response.data);
  }

  Future<void> updateAnimal(String id, Map<String, dynamic> payload) async {
    await ApiClient.patch('/mobile/livestock/$id', payload);
  }

  Future<void> deleteAnimal(String id) async {
    await ApiClient.delete('/mobile/livestock/$id');
  }

  Future<Map<String, dynamic>> getInventoryItem(String id) async {
    final response = await ApiClient.get('/mobile/inventory/$id');
    return _map(response.data);
  }

  Future<void> updateInventoryItem(
    String id,
    Map<String, dynamic> payload,
  ) async {
    await ApiClient.patch('/mobile/inventory/$id', payload);
  }

  Future<void> deleteInventoryItem(String id) async {
    await ApiClient.delete('/mobile/inventory/$id');
  }

  Future<void> updateInventorySale(
    String id,
    Map<String, dynamic> payload,
  ) async {
    await ApiClient.patch('/mobile/inventory/sales/$id', payload);
  }

  Future<void> deleteInventorySale(String id) async {
    await ApiClient.delete('/mobile/inventory/sales/$id');
  }

  List<Map<String, dynamic>> _list(Object? value) {
    if (value is List) {
      return value.whereType<Map>().map((item) => _map(item)).toList();
    }
    final map = _map(value);
    for (final key in ['items', 'rows', 'data', 'markers', 'zones']) {
      final nested = map[key];
      if (nested is List) return _list(nested);
    }
    return const [];
  }

  Map<String, dynamic> _map(Object? value) {
    if (value is Map) {
      return <String, dynamic>{
        for (final entry in value.entries) '${entry.key}': entry.value,
      };
    }
    return const {};
  }
}
