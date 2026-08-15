import '../../core/api/api_client.dart';
import '../../models/dashboard_data.dart';
import '../../shared/filters/report_record_filters.dart';

class DashboardRepository {
  Future<DashboardData> getDashboard(ReportRecordFilters filters) async {
    final response = await ApiClient.get(
      '/mobile/dashboard',
      params: filters.toQuery(),
    );
    return DashboardData.fromJson(
        response.data as Map<String, dynamic>);
  }
}
