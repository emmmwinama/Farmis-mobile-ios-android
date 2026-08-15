class OverheadExpense {
  final String   id;
  final String   description;
  final String   category;
  final double   amount;
  final DateTime date;
  final bool     recurring;
  final String?  notes;

  const OverheadExpense({
    required this.id,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
    required this.recurring,
    this.notes,
  });

  factory OverheadExpense.fromJson(Map<String, dynamic> json) =>
      OverheadExpense(
        id:          json['id']          as String,
        description: json['description'] as String,
        category:    json['category']    as String,
        amount:      (json['amount']     as num).toDouble(),
        date:        DateTime.parse(json['date'] as String),
        recurring:   json['recurring']   as bool,
        notes:       json['notes']       as String?,
      );
}

class OverheadSummary {
  final double total;
  final double recurring;

  const OverheadSummary({
    required this.total,
    required this.recurring,
  });

  factory OverheadSummary.fromJson(Map<String, dynamic> json) =>
      OverheadSummary(
        total:     (json['total']     as num).toDouble(),
        recurring: (json['recurring'] as num).toDouble(),
      );
}

class OverheadData {
  final List<OverheadExpense> expenses;
  final OverheadSummary       summary;

  const OverheadData({
    required this.expenses,
    required this.summary,
  });

  factory OverheadData.fromJson(Map<String, dynamic> json) => OverheadData(
    expenses: (json['expenses'] as List)
        .map((e) =>
        OverheadExpense.fromJson(e as Map<String, dynamic>))
        .toList(),
    summary: OverheadSummary.fromJson(
        json['summary'] as Map<String, dynamic>),
  );
}