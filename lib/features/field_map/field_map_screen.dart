import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_theme.dart';
import '../../models/field_boundary.dart';
import 'field_boundary_editor_screen.dart';
import 'field_map_provider.dart';

const _defaultCenter = LatLng(-13.9626, 33.7741); // Lilongwe, Malawi

class FieldMapScreen extends ConsumerWidget {
  const FieldMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fieldMap = ref.watch(fieldMapProvider);

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Farm map',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(fieldMapProvider),
          ),
        ],
      ),
      body: fieldMap.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(fieldMapProvider),
        ),
        data: (data) => _MapBody(data: data),
      ),
    );
  }
}

class _MapBody extends StatelessWidget {
  final FieldMapData data;
  const _MapBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final polygons = <Polygon>[];
    final markers = <Marker>[];
    final centers = <LatLng>[];

    for (final field in data.fields) {
      final ring = field.boundary?.points ?? const [];
      if (ring.length >= 3) {
        final points = ring.map((p) => LatLng(p[0], p[1])).toList();
        polygons.add(Polygon(
          points: points,
          color: FarmioColors.primary.withValues(alpha: 0.18),
          borderColor: FarmioColors.primary,
          borderStrokeWidth: 2,
        ));
        centers.addAll(points);
      } else if (field.locationLat != null && field.locationLng != null) {
        final point = LatLng(field.locationLat!, field.locationLng!);
        centers.add(point);
        markers.add(Marker(
          point: point,
          width: 34,
          height: 34,
          child: const Icon(Icons.location_on,
              color: FarmioColors.primary, size: 30),
        ));
      }
    }

    for (final marker in data.markers) {
      final point = LatLng(marker.lat, marker.lng);
      centers.add(point);
      markers.add(Marker(
        point: point,
        width: 30,
        height: 30,
        child: Icon(_iconFor(marker.type),
            color: FarmioColors.info, size: 26),
      ));
    }

    return Column(
      children: [
        _ReadinessBar(readiness: data.readiness),
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 6,
              initialCameraFit: centers.isEmpty
                  ? null
                  : CameraFit.coordinates(
                      coordinates: centers,
                      padding: const EdgeInsets.all(40),
                      maxZoom: 17,
                    ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.farmio.mobile',
              ),
              PolygonLayer(polygons: polygons),
              MarkerLayer(markers: markers),
            ],
          ),
        ),
        _FieldReadinessList(fields: data.fields),
      ],
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'borehole':
        return Icons.water_drop_outlined;
      case 'irrigation':
        return Icons.water_outlined;
      case 'shed':
        return Icons.warehouse_outlined;
      case 'road':
        return Icons.route_outlined;
      case 'gate':
        return Icons.sensor_door_outlined;
      default:
        return Icons.place_outlined;
    }
  }
}

class _ReadinessBar extends StatelessWidget {
  final FieldMapReadiness readiness;
  const _ReadinessBar({required this.readiness});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: FarmioColors.surface,
      child: Row(
        children: [
          _Stat(label: 'Mapped', value: '${readiness.mappedPct.round()}%'),
          _Stat(
            label: 'Boundaries',
            value: '${readiness.fieldsWithBoundary}/${readiness.totalFields}',
          ),
          _Stat(label: 'Zones', value: '${readiness.totalZones}'),
          _Stat(label: 'Markers', value: '${readiness.totalMarkers}'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: FarmioColors.textPrimary,
              )),
          Text(label,
              style: const TextStyle(
                fontSize: 11,
                color: FarmioColors.textMuted,
              )),
        ],
      ),
    );
  }
}

class _FieldReadinessList extends StatelessWidget {
  final List<FieldMapField> fields;
  const _FieldReadinessList({required this.fields});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        scrollDirection: Axis.horizontal,
        itemCount: fields.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final field = fields[index];
          final hasBoundary = field.boundary != null;
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    FieldBoundaryEditorScreen(fieldId: field.id),
              ),
            ),
            child: Container(
              width: 168,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: FarmioColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: FarmioColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(field.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: FarmioColors.textPrimary,
                      )),
                  const SizedBox(height: 4),
                  Text('${field.cultivatableArea.toStringAsFixed(2)} ha',
                      style: const TextStyle(
                        fontSize: 12,
                        color: FarmioColors.textMuted,
                      )),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        hasBoundary
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 14,
                        color: hasBoundary
                            ? FarmioColors.success
                            : FarmioColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasBoundary ? 'Boundary set' : 'No boundary',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: hasBoundary
                              ? FarmioColors.success
                              : FarmioColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
            const Text('Could not load the farm map',
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
