import 'package:dio/dio.dart';
import 'farm_context_models.dart';

class FarmContextRepository {
  final Dio _dio;
  const FarmContextRepository(this._dio);

  Future<FarmContext> fetch() async {
    final res = await _dio.get('/api/mobile/farm-context');
    return FarmContext.fromJson(res.data as Map<String, dynamic>);
  }
}
