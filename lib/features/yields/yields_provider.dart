import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'yields_repository.dart';
import '../../core/db/database_provider.dart';
import '../../models/yield.dart';

final yieldsRepositoryProvider = Provider<YieldsRepository>(
      (ref) => YieldsRepository(ref.read(databaseProvider)),
);

final yieldsProvider =
FutureProvider.autoDispose<YieldsData>((ref) {
  return ref.read(yieldsRepositoryProvider).getYields();
});