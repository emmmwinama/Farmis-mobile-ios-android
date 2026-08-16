import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'equipment_repository.dart';
import '../../core/db/database_provider.dart';

final equipmentRepositoryProvider = Provider<EquipmentRepository>(
  (ref) => EquipmentRepository(ref.read(databaseProvider)),
);

final equipmentProvider = FutureProvider.autoDispose<EquipmentData>((ref) {
  return ref.read(equipmentRepositoryProvider).getEquipment();
});
