class TransactionModel {
  final String   id;
  final String   type;
  final String   category;
  final double   amount;
  final DateTime date;
  final String   description;
  final String?  season;
  final String?  fieldName;
  final String?  cropName;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
    this.season,
    this.fieldName,
    this.cropName,
  });

  bool get isIncome => type == 'Income';

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id:          json['id']          as String,
        type:        json['type']        as String,
        category:    json['category']    as String,
        amount:      (json['amount']     as num).toDouble(),
        date:        DateTime.parse(json['date'] as String),
        description: json['description'] as String,
        season:      json['season']      as String?,
        fieldName:   json['fieldName']   as String?,
        cropName:    json['cropName']    as String?,
      );
}

class CategoryBreakdown {
  final String category;
  final double income;
  final double expense;
  final double net;

  const CategoryBreakdown({
    required this.category,
    required this.income,
    required this.expense,
    required this.net,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) =>
      CategoryBreakdown(
        category: json['category'] as String,
        income:   (json['income']  as num).toDouble(),
        expense:  (json['expense'] as num).toDouble(),
        net:      (json['net']     as num).toDouble(),
      );
}

class FinanceSummary {
  final double income;
  final double expense;
  final double net;
  final List<CategoryBreakdown> byCategory;

  const FinanceSummary({
    required this.income,
    required this.expense,
    required this.net,
    required this.byCategory,
  });

  factory FinanceSummary.fromJson(Map<String, dynamic> json) =>
      FinanceSummary(
        income:  (json['income']  as num).toDouble(),
        expense: (json['expense'] as num).toDouble(),
        net:     (json['net']     as num).toDouble(),
        byCategory: (json['byCategory'] as List)
            .map((e) =>
            CategoryBreakdown.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Labour/input/other costs logged against field activities — kept separate
/// from [FinanceSummary] (which only ever reflects the `transactions` table)
/// so the Finance screen can show where the two combine into a true P&L.
class ActivityCostSummary {
  final double labourCost;
  final double inputCost;
  final double otherCost;

  const ActivityCostSummary({
    required this.labourCost,
    required this.inputCost,
    required this.otherCost,
  });

  static const zero =
      ActivityCostSummary(labourCost: 0, inputCost: 0, otherCost: 0);

  double get total => labourCost + inputCost + otherCost;

  factory ActivityCostSummary.fromJson(Map<String, dynamic> json) =>
      ActivityCostSummary(
        labourCost: (json['labourCost'] as num? ?? 0).toDouble(),
        inputCost:  (json['inputCost']  as num? ?? 0).toDouble(),
        otherCost:  (json['otherCost']  as num? ?? 0).toDouble(),
      );
}

class FinanceData {
  final List<TransactionModel> transactions;
  final FinanceSummary         summary;

  const FinanceData({
    required this.transactions,
    required this.summary,
  });

  factory FinanceData.fromJson(Map<String, dynamic> json) => FinanceData(
    transactions: (json['transactions'] as List)
        .map((e) =>
        TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    summary: FinanceSummary.fromJson(
        json['summary'] as Map<String, dynamic>),
  );
}