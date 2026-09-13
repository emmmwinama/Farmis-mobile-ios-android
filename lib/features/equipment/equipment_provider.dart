import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'equipment_repository.dart';
import '../../core/api/api_client.dart';
import '../../core/db/database_provider.dart';
import '../../models/equipment.dart';

final equipmentRepositoryProvider = Provider<EquipmentRepository>(
  (ref) => EquipmentRepository(
      ref.read(databaseProvider), ref.read(apiClientProvider)),
);

final equipmentProvider =
    FutureProvider.autoDispose<List<EquipmentModel>>((ref) {
  return ref.read(equipmentRepositoryProvider).getEquipment();
});

final equipmentDetailProvider =
    FutureProvider.autoDispose.family<EquipmentModel, String>((ref, id) {
  return ref.read(equipmentRepositoryProvider).getOne(id);
});

final equipmentLogsProvider =
    FutureProvider.autoDispose.family<List<EquipmentMaintenanceLog>, String>(
        (ref, equipmentId) {
  return ref.read(equipmentRepositoryProvider).getLogs(equipmentId);
});
