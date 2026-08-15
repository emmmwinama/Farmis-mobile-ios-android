import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'field_map_repository.dart';
import '../../core/sync/sync_queue_provider.dart';
import '../../models/field_boundary.dart';

final fieldMapRepositoryProvider = Provider<FieldMapRepository>(
  (ref) => FieldMapRepository(ref.read(syncQueueProvider.notifier)),
);

final fieldMapProvider = FutureProvider.autoDispose<FieldMapData>((ref) {
  return ref.read(fieldMapRepositoryProvider).getFieldMap();
});

final fieldBoundaryProvider =
    FutureProvider.autoDispose.family<FieldBoundary?, String>((ref, fieldId) {
  return ref.read(fieldMapRepositoryProvider).getBoundary(fieldId);
});

final fieldZonesProvider =
    FutureProvider.autoDispose.family<List<FieldZone>, String>((ref, fieldId) {
  return ref.read(fieldMapRepositoryProvider).getZones(fieldId);
});

final farmMarkersProvider =
    FutureProvider.autoDispose<List<FarmMarker>>((ref) {
  return ref.read(fieldMapRepositoryProvider).getMarkers();
});
