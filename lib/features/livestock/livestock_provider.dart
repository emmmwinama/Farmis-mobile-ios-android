import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'livestock_repository.dart';
import '../../core/db/database_provider.dart';
import '../../models/livestock.dart';

final livestockRepositoryProvider = Provider<LivestockRepository>(
  (ref) => LivestockRepository(ref.read(databaseProvider)),
);

final livestockProvider = FutureProvider.autoDispose<LivestockData>((ref) {
  return ref.read(livestockRepositoryProvider).getLivestock();
});

final animalDetailProvider =
    FutureProvider.autoDispose.family<Animal, String>((ref, id) {
  return ref.read(livestockRepositoryProvider).getAnimal(id);
});
