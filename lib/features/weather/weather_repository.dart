import 'package:dio/dio.dart';
import '../../core/db/app_database.dart';
import '../../models/weather.dart';

/// Mirrors the backend's city-name lookup table, used when the farm profile
/// has no captured lat/lng yet (defaults to Lilongwe, matching the backend's
/// fallback for an unrecognised name).
({double lat, double lon}) _farmCoordinates(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('blantyre')) return (lat: -15.7861, lon: 35.0058);
  if (lower.contains('mzuzu')) return (lat: -11.4658, lon: 34.0154);
  if (lower.contains('zomba')) return (lat: -15.3867, lon: 35.3175);
  return (lat: -13.9626, lon: 33.7741);
}

const _planningGuidance = [
  'Check rainfall before spraying or applying fertiliser.',
  'Prioritise irrigation checks during hot, dry weeks.',
  'Avoid harvesting during heavy rain windows where possible.',
  'Use field notes and recent weather together for planting decisions.',
];

class WeatherRepository {
  WeatherRepository(this._db, {Dio? dio}) : _dio = dio ?? Dio();

  final AppDatabase _db;
  final Dio _dio;

  Future<WeatherData> getWeather() async {
    final profile = await _db.select(_db.farmProfile).getSingleOrNull();
    final farmName = profile?.name ?? 'My Farm';

    double lat, lon;
    if (profile?.locationLat != null && profile?.locationLng != null) {
      lat = profile!.locationLat!;
      lon = profile.locationLng!;
    } else {
      final coords = _farmCoordinates(farmName);
      lat = coords.lat;
      lon = coords.lon;
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current':
              'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m',
          'daily':
              'weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max,wind_speed_10m_max',
          'timezone': 'Africa/Blantyre',
          'forecast_days': 7,
        },
      );
      final body = response.data!;
      final current = body['current'] as Map<String, dynamic>;
      final daily = body['daily'] as Map<String, dynamic>;
      final dates = daily['time'] as List;

      return WeatherData.fromJson({
        'farmName': farmName,
        'current': {
          'temp': (current['temperature_2m'] as num).round(),
          'feelsLike': (current['apparent_temperature'] as num).round(),
          'humidity': current['relative_humidity_2m'],
          'precipitation': current['precipitation'],
          'windSpeed': (current['wind_speed_10m'] as num).round(),
          'windDirection': current['wind_direction_10m'],
          'code': current['weather_code'],
        },
        'daily': List.generate(dates.length, (i) {
          return {
            'date': dates[i],
            'code': (daily['weather_code'] as List)[i],
            'tempMax': ((daily['temperature_2m_max'] as List)[i] as num).round(),
            'tempMin': ((daily['temperature_2m_min'] as List)[i] as num).round(),
            'precipitation': (daily['precipitation_sum'] as List)[i],
            'precipProbability':
                (daily['precipitation_probability_max'] as List)[i],
            'windMax': ((daily['wind_speed_10m_max'] as List)[i] as num).round(),
          };
        }),
        'source': 'provider',
        'guidance': _planningGuidance,
      });
    } catch (_) {
      return WeatherData.fromJson({
        'farmName': farmName,
        'current': null,
        'daily': const [],
        'source': 'fallback',
        'guidance': _planningGuidance,
      });
    }
  }
}
