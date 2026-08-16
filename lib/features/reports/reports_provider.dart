import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'reports_repository.dart';
import '../../core/db/database_provider.dart';
import '../../models/report.dart';
import '../../shared/filters/report_record_filters.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>(
      (ref) => ReportsRepository(ref.read(databaseProvider)),
);

final reportsProvider = FutureProvider.autoDispose
    .family<ReportData, ReportRecordFilters>((ref, filters) {
  return ref.read(reportsRepositoryProvider).getReport(filters);
});
