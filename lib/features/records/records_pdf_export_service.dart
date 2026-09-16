import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../shared/filters/report_record_filters.dart';
import '../../shared/utils/formatters.dart';
import 'records_repository.dart';

const _packTitles = {
  'loan': 'Loan readiness pack',
  'buyer': 'Buyer records pack',
  'audit': 'Audit file',
  'insurance': 'Insurance file',
};

const _maxRowsPerTable = 20;

/// On-device PDF for a Records evidence pack — built straight from the same
/// repositories the rest of the app uses, filtered the same way the screen's
/// filter bar shows.
Future<Uint8List> buildRecordsPdf({
  required String farmName,
  required String pack,
  required RecordsData data,
  required ReportRecordFilters filters,
  required Set<String> sections,
}) async {
  final doc = pw.Document();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Text(_packTitles[pack] ?? 'Farm records',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Farm: $farmName',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.Text('Generated: ${Fmt.date(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.Text('Filters: ${filters.summary}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.SizedBox(height: 16),
        if (sections.contains('fields')) ...[
          _sectionTitle('Fields and crops'),
          _table(
            ['Field', 'Total area', 'Cultivatable', 'Soil type', 'Active crops'],
            data.fields
                .map((f) => [
                      f.name,
                      '${f.totalArea.toStringAsFixed(2)} ha',
                      '${f.cultivatableArea.toStringAsFixed(2)} ha',
                      f.soilType,
                      f.crops.join(', '),
                    ])
                .toList(),
          ),
        ],
        if (sections.contains('activities')) ...[
          _sectionTitle('Activities and inputs'),
          _table(
            ['Date', 'Type', 'Field', 'Crop', 'Cost'],
            data.activities
                .map((a) => [
                      Fmt.dateShort(a.date),
                      a.activityType,
                      a.fieldName,
                      a.cropName ?? '—',
                      Fmt.mwk(a.totalCost),
                    ])
                .toList(),
          ),
        ],
        if (sections.contains('finance')) ...[
          _sectionTitle('Finance records'),
          _table(
            ['Date', 'Type', 'Category', 'Description', 'Amount'],
            data.transactions
                .map((t) => [
                      Fmt.dateShort(t.date),
                      t.type,
                      t.category,
                      t.description,
                      Fmt.mwk(t.amount),
                    ])
                .toList(),
          ),
        ],
        if (sections.contains('payroll')) ...[
          _sectionTitle('Payroll capacity'),
          _table(
            ['Name', 'Role', 'Pay rate', 'Status'],
            data.employees
                .map((e) => [
                      e.name,
                      e.role,
                      '${Fmt.mwk(e.payRate)} / ${e.payRateUnit}',
                      e.isActive ? 'Active' : 'Inactive',
                    ])
                .toList(),
          ),
        ],
        if (sections.contains('livestock')) ...[
          _sectionTitle('Livestock summary'),
          _table(
            ['Tag / name', 'Type', 'Sex', 'Status', 'Weight'],
            data.animals
                .map((a) => [
                      a.tag ?? a.name ?? '—',
                      a.livestockTypeName ?? '—',
                      a.sex,
                      a.status,
                      a.weight != null ? '${a.weight!.toStringAsFixed(1)} kg' : '—',
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
