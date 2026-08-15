import '../../core/api/api_client.dart';
import '../../models/report.dart';
import '../../shared/filters/report_record_filters.dart';

class ReportsRepository {
  Future<ReportData> getReport(ReportRecordFilters filters) async {
    final response = await ApiClient.get(
      '/mobile/reports',
      params: filters.toQuery(),
    );
    return ReportData.fromJson(
        response.data as Map<String, dynamic>);
  }
}
