import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'weather_repository.dart';
import '../../models/weather.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>(
  (_) => WeatherRepository(),
);

final weatherProvider = FutureProvider.autoDispose<WeatherData>((ref) {
  return ref.read(weatherRepositoryProvider).getWeather();
});
