import 'dart:io';

import 'package:path_provider/path_provider.dart';
import '../../core/api/api_client.dart';
import '../../models/report_builder.dart';

class ReportBuilderRepository {
  Future<ReportBuilderData> getReportBuilder() async {
    final response = await ApiClient.get('/mobile/report-builder');
    return ReportBuilderData.fromJson(response.data as Map<String, dynamic>);
  }

  /// Downloads the mobile PDF export for the selected sections and saves it
  /// to a temp file, returning the path so it can be shared/opened.
  Future<String> exportPdf(List<String> sections) async {
    final response = await ApiClient.getBytes(
      '/mobile/reports/export',
      params: {'format': 'pdf', 'report': sections},
    );
    final dir = await getTemporaryDirectory();
    final date = DateTime.now().toIso8601String().split('T').first;
    final file = File('${dir.path}/agrivault-report-$date.pdf');
    await file.writeAsBytes(response.data ?? const []);
    return file.path;
  }
}
