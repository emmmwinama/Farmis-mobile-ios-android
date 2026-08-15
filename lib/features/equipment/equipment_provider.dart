import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'equipment_repository.dart';
import '../../core/sync/sync_queue_provider.dart';

final equipmentRepositoryProvider = Provider<EquipmentRepository>(
  (ref) => EquipmentRepository(ref.read(syncQueueProvider.notifier)),
);

final equipmentProvider = FutureProvider.autoDispose<EquipmentData>((ref) {
  return ref.read(equipmentRepositoryProvider).getEquipment();
});
