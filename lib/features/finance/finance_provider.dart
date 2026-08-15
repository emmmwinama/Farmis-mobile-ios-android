import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'finance_repository.dart';
import '../../core/sync/sync_queue_provider.dart';
import '../../models/transaction.dart';
import '../../models/overhead.dart';

final financeRepositoryProvider = Provider<FinanceRepository>(
      (ref) => FinanceRepository(ref.read(syncQueueProvider.notifier)),
);

final financeProvider =
FutureProvider.autoDispose<FinanceData>((ref) {
  return ref.read(financeRepositoryProvider).getTransactions();
});

final overheadProvider =
FutureProvider.autoDispose<OverheadData>((ref) {
  return ref.read(financeRepositoryProvider).getOverhead();
});