import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/db/database_provider.dart';
import 'records_repository.dart';

final recordsRepositoryProvider = Provider<RecordsRepository>(
  (ref) => RecordsRepository(ref.read(databaseProvider), ref.read(apiClientProvider)),
);

final recordsDataProvider = FutureProvider.autoDispose<RecordsData>((ref) {
  return ref.read(recordsRepositoryProvider).getRecords();
});
