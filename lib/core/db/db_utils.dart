import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generates a new local-row ID. Matches the opaque-string shape of
/// Prisma's cuid()s closely enough that migrated rows (which keep their
/// original cuid as the local primary key) and freshly-created local rows
/// are indistinguishable to model code.
String newId() => _uuid.v4();

/// Form screens across the app send numeric fields as raw text-controller
/// strings (e.g. `'totalArea': _totalCtrl.text.trim()`) since that's what
/// the old JSON-over-HTTP backend expected too. Local repositories accept
/// either a String or a num for the same fields.
double asDouble(Object? value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? fallback;
  return fallback;
}

double? asDoubleOrNull(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }
  return null;
}

int asInt(Object? value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? fallback;
  return fallback;
}

bool asBool(Object? value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return fallback;
}

String? asStringOrNull(Object? value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}
