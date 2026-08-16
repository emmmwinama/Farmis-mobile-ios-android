import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/weather/weather_repository.dart';

Dio _fakeDio(Map<String, dynamic> json) {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
    handler.resolve(Response(requestOptions: options, data: json, statusCode: 200));
  }));
  return dio;
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  test('getWeather maps the Open-Meteo response into WeatherData', () async {
    final dio = _fakeDio({
      'current': {
        'temperature_2m': 24.6,
        'apparent_temperature': 26.1,
        'relative_humidity_2m': 55,
        'precipitation': 0,
        'wind_speed_10m': 12.3,
        'wind_direction_10m': 180,
        'weather_code': 1,
      },
      'daily': {
        'time': ['2026-08-16', '2026-08-17'],
        'weather_code': [1, 61],
        'temperature_2m_max': [28.0, 25.0],
        'temperature_2m_min': [15.0, 14.0],
        'precipitation_sum': [0, 4.2],
        'precipitation_probability_max': [10, 70],
        'wind_speed_10m_max': [18.0, 22.0],
      },
    });
    final repo = WeatherRepository(db, dio: dio);

    final data = await repo.getWeather();

    expect(data.source, 'provider');
    expect(data.current, isNotNull);
    expect(data.current!.temp, 25);
    expect(data.current!.feelsLike, 26);
    expect(data.daily, hasLength(2));
    expect(data.daily.first.tempMax, 28);
    expect(data.daily[1].code, 61);
    expect(data.guidance, isNotEmpty);
  });

  test('getWeather falls back gracefully when the request fails', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      handler.reject(DioException(requestOptions: options, error: 'offline'));
    }));
    final repo = WeatherRepository(db, dio: dio);

    final data = await repo.getWeather();

    expect(data.source, 'fallback');
    expect(data.current, isNull);
    expect(data.daily, isEmpty);
  });

  test('getWeather uses the farm profile name for city-based coordinates',
      () async {
    await db.into(db.farmProfile).insert(FarmProfileCompanion.insert(
          id: 'farm-1',
          name: 'Zomba Greens',
          location: 'Zomba',
          createdAt: DateTime.now(),
        ));
    Map<String, dynamic>? capturedQuery;
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      capturedQuery = options.queryParameters;
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'current': {
            'temperature_2m': 20,
            'apparent_temperature': 20,
            'relative_humidity_2m': 50,
            'precipitation': 0,
            'wind_speed_10m': 5,
            'wind_direction_10m': 90,
            'weather_code': 0,
          },
          'daily': {
            'time': [],
            'weather_code': [],
            'temperature_2m_max': [],
            'temperature_2m_min': [],
            'precipitation_sum': [],
            'precipitation_probability_max': [],
            'wind_speed_10m_max': [],
          },
        },
      ));
    }));
    final repo = WeatherRepository(db, dio: dio);

    final data = await repo.getWeather();

    expect(data.farmName, 'Zomba Greens');
    expect(capturedQuery!['latitude'], -15.3867);
    expect(capturedQuery!['longitude'], 35.3175);
  });
}
