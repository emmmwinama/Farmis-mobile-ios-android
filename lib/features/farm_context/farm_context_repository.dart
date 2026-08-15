import '../../core/api/api_client.dart';
import '../../core/auth/secure_storage.dart';
import '../../models/farm_context.dart';

class FarmContextRepository {
  Future<FarmContext> getFarmContext() async {
    final response = await ApiClient.get('/mobile/farm-context');
    return FarmContext.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FarmContext> switchFarm(String farmId) async {
    final response = await ApiClient.post('/mobile/farm-context', {
      'farmId': farmId,
    });
    final context = FarmContext.fromJson(response.data as Map<String, dynamic>);
    if (context.token != null) {
      await SecureStorage.saveToken(context.token!);
    }
    await SecureStorage.saveFarmId(farmId);
    return context;
  }
}
