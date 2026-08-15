import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'yields_repository.dart';
import '../../core/sync/sync_queue_provider.dart';
import '../../models/yield.dart';

final yieldsRepositoryProvider = Provider<YieldsRepository>(
      (ref) => YieldsRepository(ref.read(syncQueueProvider.notifier)),
);

final yieldsProvider =
FutureProvider.autoDispose<YieldsData>((ref) {
  return ref.read(yieldsRepositoryProvider).getYields();
});