import 'dart:io';

import 'package:path_provider/path_provider.dart';
import '../../core/db/app_database.dart';
import '../../core/db/report_aggregator.dart';
import '../../models/report_builder.dart';
import '../../shared/filters/report_record_filters.dart';
import '../reports/reports_repository.dart';
import 'pdf_export_service.dart';

class ReportBuilderRepository {
  ReportBuilderRepository(this._db)
      : _agg = ReportAggregator(_db),
        _reports = ReportsRepository(_db);

  final AppDatabase _db;
  final ReportAggregator _agg;
  final ReportsRepository _reports;

  Future<ReportBuilderData> getReportBuilder() async {
    final fields = await _db.select(_db.fields).get();

    final cropProfitability = <Map<String, dynamic>>[];
    final fieldRows = <Map<String, dynamic>>[];

    for (final field in fields) {
      final crops = await (_db.select(_db.cropFields)
            ..where((t) => t.fieldId.equals(field.id)))
          .get();

      for (final crop in crops) {
        final cropType = await (_db.select(_db.cropTypes)
              ..where((t) => t.id.equals(crop.cropTypeId)))
            .getSingleOrNull();
        final cost = await _agg.cropCost(crop.id);
        final revenue = await _agg.cropRevenue(crop.id);
        final yields = await _agg.yieldsForCrop(crop.id);
        // Mirrors the backend's raw quantity sum here (unlike the toKg-based
        // total used elsewhere) — a quirk of the original route, preserved.
        final totalYieldQuantity =
            yields.fold<double>(0, (s, y) => s + y.quantity);

        cropProfitability.add({
          'cropName': cropType?.name ?? 'Crop',
          'variety': crop.variety,
          'fieldName': field.name,
          'season': crop.season,
          'revenue': revenue,
          'totalCost': cost.total,
          'netProfit': revenue - cost.total,
          'inputCost': cost.inputCost,
          'costPerKg':
              totalYieldQuantity > 0 ? cost.inputCost / totalYieldQuantity : 0,
        });
      }

      fieldRows.add({
        'name': field.name,
        'area': field.totalArea,
        'cultivatableArea': field.cultivatableArea,
        'crops': crops.length,
      });
    }

    cropProfitability.sort((a, b) =>
        (b['netProfit'] as double).compareTo(a['netProfit'] as double));

    return ReportBuilderData.fromJson({
      'sections': {
        'cropProfitability': cropProfitability,
        'fields': fieldRows,
      },
    });
  }

  /// Builds the PDF on-device (replacing the old backend download) and
  /// saves it to a temp file, returning the path so it can be shared.
  Future<String> exportPdf(
    List<String> sections, {
    ReportRecordFilters filters = const ReportRecordFilters(),
  }) async {
    final data = await _reports.getReport(filters);
    final profile = await _db.select(_db.farmProfile).getSingleOrNull();

    final bytes = await buildReportPdf(
      farmName: profile?.name ?? 'My Farm',
      data: data,
      filters: filters,
      sections: sections.toSet(),
    );

    final dir = await getTemporaryDirectory();
    final date = DateTime.now().toIso8601String().split('T').first;
    final file = File('${dir.path}/agrivault-report-$date.pdf');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
