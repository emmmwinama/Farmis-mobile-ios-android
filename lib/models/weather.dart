class WeatherCurrent {
  final double temp;
  final double feelsLike;
  final double humidity;
  final double precipitation;
  final double windSpeed;
  final double windDirection;
  final int code;

  const WeatherCurrent({
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.precipitation,
    required this.windSpeed,
    required this.windDirection,
    required this.code,
  });

  factory WeatherCurrent.fromJson(Map<String, dynamic> json) =>
      WeatherCurrent(
        temp: (json['temp'] as num? ?? 0).toDouble(),
        feelsLike: (json['feelsLike'] as num? ?? 0).toDouble(),
        humidity: (json['humidity'] as num? ?? 0).toDouble(),
        precipitation: (json['precipitation'] as num? ?? 0).toDouble(),
        windSpeed: (json['windSpeed'] as num? ?? 0).toDouble(),
        windDirection: (json['windDirection'] as num? ?? 0).toDouble(),
        code: (json['code'] as num? ?? 0).toInt(),
      );
}

class WeatherDay {
  final DateTime date;
  final int code;
  final double tempMax;
  final double tempMin;
  final double precipitation;
  final double precipProbability;
  final double windMax;

  const WeatherDay({
    required this.date,
    required this.code,
    required this.tempMax,
    required this.tempMin,
    required this.precipitation,
    required this.precipProbability,
    required this.windMax,
  });

  factory WeatherDay.fromJson(Map<String, dynamic> json) => WeatherDay(
        date: DateTime.tryParse(json['date'] as String? ?? '') ??
            DateTime.now(),
        code: (json['code'] as num? ?? 0).toInt(),
        tempMax: (json['tempMax'] as num? ?? 0).toDouble(),
        tempMin: (json['tempMin'] as num? ?? 0).toDouble(),
        precipitation: (json['precipitation'] as num? ?? 0).toDouble(),
        precipProbability:
            (json['precipProbability'] as num? ?? 0).toDouble(),
        windMax: (json['windMax'] as num? ?? 0).toDouble(),
      );
}

class WeatherData {
  final String farmName;
  final WeatherCurrent? current;
  final List<WeatherDay> daily;
  final String source;
  final List<String> guidance;

  const WeatherData({
    required this.farmName,
    this.current,
    required this.daily,
    required this.source,
    required this.guidance,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
        farmName: json['farmName'] as String? ?? 'Farm',
        current: json['current'] != null
            ? WeatherCurrent.fromJson(json['current'] as Map<String, dynamic>)
            : null,
        daily: (json['daily'] as List? ?? const [])
            .map((e) => WeatherDay.fromJson(e as Map<String, dynamic>))
            .toList(),
        source: json['source'] as String? ?? 'fallback',
        guidance: List<String>.from(json['guidance'] as List? ?? const []),
      );
}

/// Maps Open-Meteo WMO weather codes to a description and Material icon
/// name-free representation (callers pick the icon), grouped coarsely.
String weatherCodeLabel(int code) {
  if (code == 0) return 'Clear sky';
  if (code <= 2) return 'Partly cloudy';
  if (code == 3) return 'Overcast';
  if (code == 45 || code == 48) return 'Fog';
  if (code >= 51 && code <= 57) return 'Drizzle';
  if (code >= 61 && code <= 67) return 'Rain';
  if (code >= 71 && code <= 77) return 'Snow';
  if (code >= 80 && code <= 82) return 'Rain showers';
  if (code >= 85 && code <= 86) return 'Snow showers';
  if (code >= 95) return 'Thunderstorm';
  return 'Unsettled';
}
