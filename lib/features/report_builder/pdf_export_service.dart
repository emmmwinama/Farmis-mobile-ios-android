import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/report.dart';
import '../../shared/filters/report_record_filters.dart';
import '../../shared/utils/formatters.dart';

const _reportLabels = {
  'season': 'Season P&L',
  'crop': 'Crop costs',
  'field': 'Field costs',
  'cropField': 'Crop-field detail',
  'labour': 'Labour',
  'inputs': 'Input efficiency',
  'yields': 'Yields',
};

const _maxRowsPerTable = 12;
final _numberFormat = NumberFormat('#,##0.##', 'en');

String _number(num value, [String suffix = '']) =>
    '${_numberFormat.format(value)}$suffix';

/// On-device replacement for the backend's `reports/export` PDF route —
/// same table structure and section selection, built locally from data
/// already fetched via [ReportsRepository.getReport].
Future<Uint8List> buildReportPdf({
  required String farmName,
  required ReportData data,
  required ReportRecordFilters filters,
  required Set<String> sections,
}) async {
  final doc = pw.Document();
  final generatedAt = DateTime.now();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Text('Farmio Farm Report',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Farm: $farmName',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.Text('Generated: ${Fmt.date(generatedAt)}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.Text('Filters: ${filters.summary}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.Text(
          'Sections: ${sections.map((k) => _reportLabels[k] ?? k).join(', ')}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 16),
        _sectionTitle('Financial summary'),
        _table(
          ['Metric', 'Value'],
          [
            ['Income', Fmt.mwk(data.financeSummary.totalIncome)],
            ['Activity costs', Fmt.mwk(data.financeSummary.totalActivityCost)],
            ['Overhead costs', Fmt.mwk(data.financeSummary.totalOverheadCost)],
            ['Net', Fmt.mwk(data.financeSummary.net)],
          ],
        ),
        if (sections.contains('season')) ...[
          _sectionTitle('Season P&L'),
          _table(
            ['Season', 'Area', 'Crops', 'Cost/ha'],
            data.seasonReport
                .map((r) => [
                      r.season,
                      _number(r.totalArea, ' ha'),
                      '${r.cropCount}',
                      Fmt.mwk(r.costPerHectare),
                    ])
                .toList(),
          ),
        ],
        if (sections.contains('crop')) ...[
          _sectionTitle('Crop costs'),
          _table(
            ['Crop', 'Area', 'Cost', 'Cost/ha'],
            data.cropReport
                .map((r) => [
                      r.cropName,
                      _number(r.totalArea, ' ha'),
                      Fmt.mwk(r.totalCost),
                      Fmt.mwk(r.costPerHectare),
                    ])
                .toList(),
          ),
        ],
        if (sections.contains('field')) ...[
          _sectionTitle('Field costs'),
          _table(
            ['Field', 'Area', 'Crops', 'Cost'],
            data.fieldReport
                .map((r) => [
                      r.fieldName,
                      _number(r.totalArea, ' ha'),
                      r.crops.join(', '),
                      Fmt.mwk(r.totalCost),
                    ])
                .toList(),
          ),
        ],
        if (sections.contains('cropField')) ...[
          _sectionTitle('Crop-field detail'),
          _table(
            ['Crop', 'Field', 'Season', 'Cost'],
            data.cropFieldDetail
                .map((r) => [
                      '${r.cropName} ${r.variety}'.trim(),
                      r.fieldName,
                      r.season,
                      Fmt.mwk(r.totalCost),
                    ])
                .toList(),
          ),
        ],
        if (sections.contains('labour')) ...[
          _sectionTitle('Labour'),
          _table(
            ['Employee', 'Role', 'Activities', 'Earned'],
            data.employeeReport
                .map((r) => [
                      r.name,
                      r.role,
                      '${r.activities}',
                      Fmt.mwk(r.totalEarned),
                    ])
                .toList(),
          ),
        ],
        if (sections.contains('inputs')) ...[
          _sectionTitle('Input efficiency'),
          _table(
            ['Input', 'Category', 'Qty', 'Cost'],
            data.inputReport
                .map((r) => [
                      r.inputName,
                      r.category,
                      _number(r.totalQuantity, ' ${r.unit}'),
                      Fmt.mwk(r.totalCost),
                    ])
                .toList(),
          ),
        ],
        if (sections.contains('yields')) ...[
          _sectionTitle('Yields'),
          _table(
            ['Crop', 'Yield kg', 'Cost/kg', 'Yield/ha'],
            data.yieldsReport.records
                .map((r) => [
                      r.cropName,
                      _number(r.totalYieldKg),
                      Fmt.mwk(r.costPerKg),
                      _number(r.yieldPerHa, ' kg/ha'),
                    ])
                .toList(),
          ),
        ],
      ],
    ),
  );

  return doc.save();
}

pw.Widget _sectionTitle(String title) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 16, bottom: 4),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('#0284c7'),
        ),
      ),
    );

pw.Widget _table(List<String> headers, List<List<String>> rows) {
  if (rows.isEmpty) {
    return pw.Text('No records for the selected filters.',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700));
  }
  final shown = rows.take(_maxRowsPerTable).toList();
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Table.fromTextArray(
        headers: headers,
        data: shown,
        headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        cellStyle: const pw.TextStyle(fontSize: 8),
        cellAlignment: pw.Alignment.centerLeft,
      ),
      if (rows.length > _maxRowsPerTable)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Text(
            'Showing first $_maxRowsPerTable of ${rows.length} rows. Narrow the filters for a shorter PDF.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ),
    ],
  );
}
