import '../../core/api/api_client.dart';
import '../../models/weather.dart';

class WeatherRepository {
  Future<WeatherData> getWeather() async {
    final response = await ApiClient.get('/mobile/weather');
    return WeatherData.fromJson(response.data as Map<String, dynamic>);
  }
}
