class RecentActivity {
  final String   id;
  final String   activityType;
  final String   fieldName;
  final String?  cropName;
  final DateTime date;

  const RecentActivity({
    required this.id,
    required this.activityType,
    required this.fieldName,
    this.cropName,
    required this.date,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) => RecentActivity(
    id:           json['id']           as String? ?? '',
    activityType: json['activityType'] as String? ?? 'Activity',
    fieldName:    json['fieldName']    as String? ??
        json['field'] as String? ??
        'Field',
    cropName:     json['cropName']     as String?,
    date:         DateTime.tryParse(json['date'] as String? ?? '') ??
        DateTime.now(),
  );
}

class FieldLandUse {
  final String name;
  final double cultivatableArea;
  final double allocated;

  const FieldLandUse({
    required this.name,
    required this.cultivatableArea,
    required this.allocated,
  });

  factory FieldLandUse.fromJson(Map<String, dynamic> json) => FieldLandUse(
    name:             json['name'] as String? ?? 'Field',
    cultivatableArea: (json['cultivatableArea'] as num? ??
            json['cultivatable'] as num? ??
            json['totalArea'] as num? ??
            0)
        .toDouble(),
    allocated:        (json['allocated'] as num? ??
            json['allocatedArea'] as num? ??
            json['used'] as num? ??
            0)
        .toDouble(),
  );

  double get available => cultivatableArea - allocated;
}

class ExpenseBreakdownItem {
  final String label;
  final double amount;

  const ExpenseBreakdownItem({
    required this.label,
    required this.amount,
  });

  factory ExpenseBreakdownItem.fromJson(Map<String, dynamic> json) =>
      ExpenseBreakdownItem(
        label: json['label'] as String? ??
            json['category'] as String? ??
            json['type'] as String? ??
            'Expense',
        amount: (json['amount'] as num? ??
                json['total'] as num? ??
                json['value'] as num? ??
                0)
            .toDouble(),
      );
}

class DashboardData {
  final String   farmName;
  final String?  userName;
  final int      totalFields;
  final double   totalArea;
  final int      activeCrops;
  final int      activeEmployees;
  final int      totalEmployees;
  final List<String> seasons;
  final double   income;
  final double   expense;
  final double   net;
  final List<ExpenseBreakdownItem> expenseBreakdown;
  final List<FieldLandUse>   fieldLandUse;
  final List<RecentActivity> recentActivities;

  const DashboardData({
    required this.farmName,
    required this.userName,
    required this.totalFields,
    required this.totalArea,
    required this.activeCrops,
    required this.activeEmployees,
    required this.totalEmployees,
    required this.seasons,
    required this.income,
    required this.expense,
    required this.net,
    required this.expenseBreakdown,
    required this.fieldLandUse,
    required this.recentActivities,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
    farmName:       json['farmName'] as String? ??
        json['farm'] as String? ??
        'Farm',
    userName:       json['userName'] as String?,
    totalFields:    (json['totalFields'] as num? ?? 0).toInt(),
    totalArea:      (json['totalArea']     as num? ?? 0).toDouble(),
    activeCrops:    (json['activeCrops']    as num? ?? 0).toInt(),
    activeEmployees:(json['activeEmployees']as num? ?? 0).toInt(),
    totalEmployees: (json['totalEmployees'] as num? ??
            json['activeEmployees'] as num? ??
            0)
        .toInt(),
    seasons:        List<String>.from(json['seasons'] as List? ?? const []),
    income:         (json['income']        as num? ?? 0).toDouble(),
    expense:        (json['expense']       as num? ?? 0).toDouble(),
    net:            (json['net']           as num? ?? 0).toDouble(),
    expenseBreakdown: (json['expenseBreakdown'] as List? ??
            json['expensesBreakdown'] as List? ??
            json['costBreakdown'] as List? ??
            const [])
        .map((e) => ExpenseBreakdownItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    fieldLandUse: (json['fieldLandUse'] as List? ?? const [])
        .map((e) => FieldLandUse.fromJson(e as Map<String, dynamic>))
        .toList(),
    recentActivities: (json['recentActivities'] as List? ?? const [])
        .map((e) => RecentActivity.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
