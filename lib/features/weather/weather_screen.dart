import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/weather.dart';
import 'weather_provider.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider);

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Weather',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(weatherProvider),
          ),
        ],
      ),
      body: weather.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(weatherProvider),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(weatherProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              if (data.current != null) _CurrentCard(data: data),
              const SizedBox(height: 16),
              const Text('7-day forecast',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: FarmioColors.textPrimary)),
              const SizedBox(height: 8),
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: data.daily.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) =>
                      _DayCard(day: data.daily[index]),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Field guidance',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: FarmioColors.textPrimary)),
              const SizedBox(height: 8),
              ...data.guidance.map((tip) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: FarmioColors.infoBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.tips_and_updates_outlined,
                            size: 16, color: FarmioColors.info),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(tip,
                              style: const TextStyle(
                                  fontSize: 13, color: FarmioColors.info)),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentCard extends StatelessWidget {
  final WeatherData data;
  const _CurrentCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final current = data.current!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [FarmioColors.primaryDark, FarmioColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.farmName,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text('${current.temp.round()}°C',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w900,
              )),
          Text(weatherCodeLabel(current.code),
              style: const TextStyle(color: Colors.white, fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            children: [
              _CurrentStat(
                  icon: Icons.thermostat_outlined,
                  label: 'Feels like',
                  value: '${current.feelsLike.round()}°C'),
              _CurrentStat(
                  icon: Icons.water_drop_outlined,
                  label: 'Humidity',
                  value: '${current.humidity.round()}%'),
              _CurrentStat(
                  icon: Icons.air_outlined,
                  label: 'Wind',
                  value: '${current.windSpeed.round()} km/h'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrentStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CurrentStat(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final WeatherDay day;
  const _DayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Container(
      width: 84,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: FarmioColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FarmioColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(weekdays[day.date.weekday - 1],
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800)),
          const Icon(Icons.cloud_outlined,
              color: FarmioColors.info, size: 22),
          Text('${day.tempMax.round()}° / ${day.tempMin.round()}°',
              style: const TextStyle(fontSize: 11)),
          if (day.precipProbability > 0)
            Text('${day.precipProbability.round()}%',
                style: const TextStyle(
                    fontSize: 10, color: FarmioColors.info)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load weather',
                style: TextStyle(
                    color: FarmioColors.textPrimary,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: FarmioColors.textMuted)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
