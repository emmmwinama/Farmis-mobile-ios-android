import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'reports_repository.dart';
import '../../models/report.dart';
import '../../shared/filters/report_record_filters.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>(
      (_) => ReportsRepository(),
);

final reportsProvider = FutureProvider.autoDispose
    .family<ReportData, ReportRecordFilters>((ref, filters) {
  return ref.read(reportsRepositoryProvider).getReport(filters);
});
