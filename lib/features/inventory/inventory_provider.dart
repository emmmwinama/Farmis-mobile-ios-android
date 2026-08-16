import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'inventory_repository.dart';
import '../../core/db/database_provider.dart';
import '../../models/inventory_item.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>(
  (ref) => InventoryRepository(ref.read(databaseProvider)),
);

final inventoryItemsProvider =
    FutureProvider.autoDispose<List<InventoryItem>>((ref) {
  return ref.read(inventoryRepositoryProvider).getItems();
});
