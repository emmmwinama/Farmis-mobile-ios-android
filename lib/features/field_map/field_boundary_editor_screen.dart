import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_theme.dart';
import '../../models/field_boundary.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'field_map_provider.dart';

const _defaultCenter = LatLng(-13.9626, 33.7741);

class FieldBoundaryEditorScreen extends ConsumerStatefulWidget {
  final String fieldId;
  const FieldBoundaryEditorScreen({super.key, required this.fieldId});

  @override
  ConsumerState<FieldBoundaryEditorScreen> createState() =>
      _FieldBoundaryEditorScreenState();
}

class _FieldBoundaryEditorScreenState
    extends ConsumerState<FieldBoundaryEditorScreen> {
  List<LatLng> _points = [];
  bool _loaded = false;
  bool _saving = false;
  String? _error;

  void _seedFromExisting(List<List<double>> ring) {
    if (_loaded) return;
    _loaded = true;
    if (ring.isNotEmpty) {
      _points = ring.map((p) => LatLng(p[0], p[1])).toList();
    }
  }

  Future<void> _save() async {
    if (_points.length < 3) {
      setState(() => _error = 'A boundary needs at least 3 points.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    final ring = [
      ..._points.map((p) => [p.longitude, p.latitude]),
      [_points.first.longitude, _points.first.latitude],
    ];
    final geoJson = {
      'type': 'Polygon',
      'coordinates': [ring],
    };

    try {
      await ref
          .read(fieldMapRepositoryProvider)
          .saveBoundary(widget.fieldId, geoJson);
      ref.invalidate(fieldBoundaryProvider(widget.fieldId));
      ref.invalidate(fieldMapProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Failed to save boundary.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final boundary = ref.watch(fieldBoundaryProvider(widget.fieldId));
    final zones = ref.watch(fieldZonesProvider(widget.fieldId));

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Field boundary',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Remove last point',
            onPressed: _points.isEmpty
                ? null
                : () => setState(() => _points.removeLast()),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Clear points',
            onPressed: _points.isEmpty
                ? null
                : () => setState(() => _points = []),
          ),
        ],
      ),
      body: boundary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Failed to load boundary: $error'),
        ),
        data: (existing) {
          _seedFromExisting(existing?.points ?? const []);
          final center = _points.isNotEmpty
              ? _points.first
              : (existing?.centroidLat != null
                  ? LatLng(existing!.centroidLat!, existing.centroidLng!)
                  : _defaultCenter);

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: FarmioColors.infoBg,
                child: const Text(
                  'Tap the map to place boundary points, then save. '
                  'Undo removes the last point.',
                  style: TextStyle(fontSize: 12, color: FarmioColors.info),
                ),
              ),
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 16,
                    onTap: (_, point) =>
                        setState(() => _points = [..._points, point]),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.farmio.mobile',
                    ),
                    if (_points.length >= 3)
                      PolygonLayer(polygons: [
                        Polygon(
                          points: _points,
                          color: FarmioColors.primary.withValues(alpha: 0.2),
                          borderColor: FarmioColors.primary,
                          borderStrokeWidth: 2,
                        ),
                      ]),
                    MarkerLayer(
                      markers: _points
                          .map((p) => Marker(
                                point: p,
                                width: 14,
                                height: 14,
                                child: const DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: FarmioColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              zones.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (list) => list.isEmpty
                    ? const SizedBox.shrink()
                    : _ZonesStrip(zones: list),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: FarmioErrorBanner(message: _error!),
                ),
              SafeArea(
                minimum: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text('Save boundary (${_points.length} points)'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ZonesStrip extends StatelessWidget {
  final List<FieldZone> zones;
  const _ZonesStrip({required this.zones});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: zones.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final zone = zones[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: FarmioColors.slate100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(zone.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 12)),
                Text(zone.type,
                    style: const TextStyle(
                        fontSize: 10, color: FarmioColors.textMuted)),
              ],
            ),
          );
        },
      ),
    );
  }
}
