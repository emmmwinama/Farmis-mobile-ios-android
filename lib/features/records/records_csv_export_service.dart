import '../../shared/utils/formatters.dart';
import 'records_repository.dart';

String _escape(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

String _row(List<String> cells) => cells.map(_escape).join(',');

/// Flat, section-by-section CSV for a Records evidence pack — one blank
/// line and a header row between sections so the file still opens cleanly
/// in a spreadsheet even though the sections have different columns.
String buildRecordsCsv({
  required RecordsData data,
  required Set<String> sections,
}) {
  final lines = <String>[];

  if (sections.contains('fields')) {
    lines.add(_row(['Field', 'Total area (ha)', 'Cultivatable (ha)', 'Soil type', 'Active crops']));
    for (final f in data.fields) {
      lines.add(_row([
        f.name,
        f.totalArea.toStringAsFixed(2),
        f.cultivatableArea.toStringAsFixed(2),
        f.soilType,
        f.crops.join('; '),
      ]));
    }
    lines.add('');
  }

  if (sections.contains('activities')) {
    lines.add(_row(['Date', 'Type', 'Field', 'Crop', 'Cost']));
    for (final a in data.activities) {
      lines.add(_row([
        Fmt.dateShort(a.date),
        a.activityType,
        a.fieldName,
        a.cropName ?? '',
        a.totalCost.toStringAsFixed(2),
      ]));
    }
    lines.add('');
  }

  if (sections.contains('finance')) {
    lines.add(_row(['Date', 'Type', 'Category', 'Description', 'Amount']));
    for (final t in data.transactions) {
      lines.add(_row([
        Fmt.dateShort(t.date),
        t.type,
        t.category,
        t.description,
        t.amount.toStringAsFixed(2),
      ]));
    }
    lines.add('');
  }

  if (sections.contains('payroll')) {
    lines.add(_row(['Name', 'Role', 'Pay rate', 'Pay rate unit', 'Status']));
    for (final e in data.employees) {
      lines.add(_row([
        e.name,
        e.role,
        e.payRate.toStringAsFixed(2),
        e.payRateUnit,
        e.isActive ? 'Active' : 'Inactive',
      ]));
    }
    lines.add('');
  }

  if (sections.contains('livestock')) {
    lines.add(_row(['Tag / name', 'Type', 'Sex', 'Status', 'Weight (kg)']));
    for (final a in data.animals) {
      lines.add(_row([
        a.tag ?? a.name ?? '',
        a.livestockTypeName ?? '',
        a.sex,
        a.status,
        a.weight?.toStringAsFixed(1) ?? '',
      ]));
    }
  }

  return lines.join('\n');
}
