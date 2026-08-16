import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_repository.dart';
import '../../core/db/database_provider.dart';
import '../../models/dashboard_data.dart';
import '../../shared/filters/report_record_filters.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
      (ref) => DashboardRepository(ref.read(databaseProvider)),
);

final dashboardProvider = FutureProvider.autoDispose
    .family<DashboardData, ReportRecordFilters>((ref, filters) async {
  return ref.read(dashboardRepositoryProvider).getDashboard(filters);
});
