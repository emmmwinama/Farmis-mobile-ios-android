import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'weather_repository.dart';
import '../../core/db/database_provider.dart';
import '../../models/weather.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>(
  (ref) => WeatherRepository(ref.read(databaseProvider)),
);

final weatherProvider = FutureProvider.autoDispose<WeatherData>((ref) {
  return ref.read(weatherRepositoryProvider).getWeather();
});
