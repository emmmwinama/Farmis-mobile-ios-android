import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'finance_repository.dart';
import '../../core/db/database_provider.dart';
import '../../models/transaction.dart';
import '../../models/overhead.dart';
import '../../shared/filters/report_record_filters.dart';

final financeRepositoryProvider = Provider<FinanceRepository>(
      (ref) => FinanceRepository(ref.read(databaseProvider)),
);

final financeProvider =
FutureProvider.autoDispose<FinanceData>((ref) {
  return ref.read(financeRepositoryProvider).getTransactions();
});

final overheadProvider =
FutureProvider.autoDispose<OverheadData>((ref) {
  return ref.read(financeRepositoryProvider).getOverhead();
});

final activityCostProvider = FutureProvider.autoDispose
    .family<ActivityCostSummary, ReportRecordFilters>((ref, filters) {
  return ref.read(financeRepositoryProvider).getActivityCosts(filters);
});