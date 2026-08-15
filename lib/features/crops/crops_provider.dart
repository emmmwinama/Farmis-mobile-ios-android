import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'crops_repository.dart';
import '../../core/sync/sync_queue_provider.dart';
import '../../models/crop_field.dart';
import '../../models/crop_detail.dart';
import '../../models/crop_type.dart';

final cropsRepositoryProvider = Provider<CropsRepository>(
      (ref) => CropsRepository(ref.read(syncQueueProvider.notifier)),
);

// Filter: 'active', 'archived', 'all'
final cropFilterProvider = StateProvider<String>((_) => 'active');

final cropsProvider =
FutureProvider.autoDispose<List<CropFieldModel>>((ref) {
  final filter = ref.watch(cropFilterProvider);
  final repo   = ref.read(cropsRepositoryProvider);

  switch (filter) {
    case 'archived': return repo.getCrops(archived: 'true');
    case 'all':      return repo.getCrops();
    default:         return repo.getCrops(archived: 'false');
  }
});

final cropDetailProvider =
FutureProvider.autoDispose.family<CropDetail, String>((ref, id) {
  return ref.read(cropsRepositoryProvider).getCrop(id);
});

final cropTypesProvider =
FutureProvider.autoDispose<List<CropType>>((ref) {
  return ref.read(cropsRepositoryProvider).getCropTypes();
});

final allCropsProvider =
FutureProvider.autoDispose<List<CropFieldModel>>((ref) {
  return ref.read(cropsRepositoryProvider).getCrops();
});