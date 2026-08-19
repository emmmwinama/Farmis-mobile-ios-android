import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../models/transaction.dart';
import '../../models/overhead.dart';
import '../../shared/filters/report_record_filters.dart';

class FinanceRepository {
  FinanceRepository(this._db);

  final AppDatabase _db;

  /// Labour + input + other costs logged against field activities, matching
  /// the dashboard's "complete" P&L definition (ALL activities in range,
  /// including field-only ones with no crop attached) — not just the
  /// crop-tied subset the Reports screen sums. These costs never appear in
  /// `transactions`, so Finance's own totals miss them unless folded in here.
  Future<ActivityCostSummary> getActivityCosts(
      ReportRecordFilters filters) async {
    final range = filters.resolveRange();
    final season = filters.season == 'All' ? null : filters.season;
    final cropName = filters.crop == 'All' ? null : filters.crop;
    final fieldName = filters.field == 'All' ? null : filters.field;

    final query = _db.select(_db.activities)
      ..where((t) =>
          t.date.isBiggerOrEqualValue(range.start) &
          t.date.isSmallerOrEqualValue(range.end));
    final activities = await query.get();

    double labourCost = 0, inputCost = 0, otherCost = 0;
    for (final activity in activities) {
      if (fieldName != null) {
        final field = await (_db.select(_db.fields)
              ..where((t) => t.id.equals(activity.fieldId)))
            .getSingleOrNull();
        if (field?.name != fieldName) continue;
      }

      if (season != null || cropName != null) {
        final cropFieldId = activity.cropFieldId;
        if (cropFieldId == null) continue;
        final crop = await (_db.select(_db.cropFields)
              ..where((t) => t.id.equals(cropFieldId)))
            .getSingleOrNull();
        if (crop == null) continue;
        if (season != null && crop.season != season) continue;
        if (cropName != null) {
          final cropType = await (_db.select(_db.cropTypes)
                ..where((t) => t.id.equals(crop.cropTypeId)))
              .getSingleOrNull();
          if (cropType?.name != cropName) continue;
        }
      }

      final inputs = await (_db.select(_db.activityInputs)
            ..where((t) => t.activityId.equals(activity.id)))
          .get();
      final labour = await (_db.select(_db.activityLabourRecords)
            ..where((t) => t.activityId.equals(activity.id)))
          .get();
      final other = await (_db.select(_db.activityOtherCosts)
            ..where((t) => t.activityId.equals(activity.id)))
          .get();
      inputCost += inputs.fold<double>(0, (s, r) => s + r.totalCost);
      labourCost += labour.fold<double>(0, (s, r) => s + r.totalCost);
      otherCost += other.fold<double>(0, (s, r) => s + r.amount);
    }

    return ActivityCostSummary(
      labourCost: labourCost,
      inputCost: inputCost,
      otherCost: otherCost,
    );
  }

  Future<FinanceData> getTransactions({
    String? season,
    String? type,
  }) async {
    final query = _db.select(_db.transactions)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    if (season != null) query.where((t) => t.season.equals(season));
    if (type != null) query.where((t) => t.type.equals(type));
    final rows = await query.get();

    final transactions = <Map<String, dynamic>>[];
    double income = 0, expense = 0;
    final byCategory = <String, _CategoryAgg>{};

    for (final row in rows) {
      String? fieldName, cropName;
      final fieldId = row.fieldId;
      if (fieldId != null) {
        final field = await (_db.select(_db.fields)
              ..where((t) => t.id.equals(fieldId)))
            .getSingleOrNull();
        fieldName = field?.name;
      }
      final cropFieldId = row.cropFieldId;
      if (cropFieldId != null) {
        final crop = await (_db.select(_db.cropFields)
              ..where((t) => t.id.equals(cropFieldId)))
            .getSingleOrNull();
        if (crop != null) {
          final cropType = await (_db.select(_db.cropTypes)
                ..where((t) => t.id.equals(crop.cropTypeId)))
              .getSingleOrNull();
          cropName = cropType?.name;
        }
      }

      transactions.add({
        ...row.toJson(),
        'fieldName': fieldName,
        'cropName': cropName,
      });

      final isIncome = row.type == 'Income';
      if (isIncome) {
        income += row.amount;
      } else {
        expense += row.amount;
      }
      final agg = byCategory.putIfAbsent(row.category, () => _CategoryAgg());
      if (isIncome) {
        agg.income += row.amount;
      } else {
        agg.expense += row.amount;
      }
    }

    return FinanceData.fromJson({
      'transactions': transactions,
      'summary': {
        'income': income,
        'expense': expense,
        'net': income - expense,
        'byCategory': byCategory.entries
            .map((e) => {
                  'category': e.key,
                  'income': e.value.income,
                  'expense': e.value.expense,
                  'net': e.value.income - e.value.expense,
                })
            .toList(),
      },
    });
  }

  Future<void> createTransaction(Map<String, dynamic> data) async {
    await _db.into(_db.transactions).insert(TransactionsCompanion.insert(
          id: newId(),
          type: data['type'] as String,
          category: data['category'] as String,
          amount: asDouble(data['amount']),
          date: DateTime.parse(data['date'] as String),
          description: data['description'] as String,
          season: Value(asStringOrNull(data['season'])),
          fieldId: Value(asStringOrNull(data['fieldId'])),
          cropFieldId: Value(asStringOrNull(data['cropFieldId'])),
        ));
  }

  Future<void> deleteTransaction(String id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  Future<OverheadData> getOverhead() async {
    final rows = await (_db.select(_db.overheadExpenses)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();

    final total = rows.fold<double>(0, (s, r) => s + r.amount);
    final recurring = rows
        .where((r) => r.recurring)
        .fold<double>(0, (s, r) => s + r.amount);

    return OverheadData.fromJson({
      'expenses': rows.map((r) => r.toJson()).toList(),
      'summary': {'total': total, 'recurring': recurring},
    });
  }

  Future<void> createOverhead(Map<String, dynamic> data) async {
    await _db.into(_db.overheadExpenses).insert(
          OverheadExpensesCompanion.insert(
            id: newId(),
            description: data['description'] as String,
            category: data['category'] as String,
            amount: asDouble(data['amount']),
            date: DateTime.parse(data['date'] as String),
            recurring: Value(asBool(data['recurring'])),
            notes: Value(asStringOrNull(data['notes'])),
          ),
        );
  }

  Future<void> deleteOverhead(String id) async {
    await (_db.delete(_db.overheadExpenses)..where((t) => t.id.equals(id)))
        .go();
  }
}

class _CategoryAgg {
  double income = 0;
  double expense = 0;
}
