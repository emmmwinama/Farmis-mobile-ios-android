class ChecklistItem {
  final String key;
  final String label;
  final bool passed;
  final num value;

  const ChecklistItem({
    required this.key,
    required this.label,
    required this.passed,
    required this.value,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        key: json['key'] as String? ?? '',
        label: json['label'] as String? ?? '',
        passed: json['passed'] as bool? ?? false,
        value: json['value'] as num? ?? 0,
      );
}

class ComplianceLot {
  final String id;
  final String cropName;
  final String fieldName;
  final String season;
  final Map<String, bool> checklist;

  const ComplianceLot({
    required this.id,
    required this.cropName,
    required this.fieldName,
    required this.season,
    required this.checklist,
  });

  bool get allDone => checklist.values.every((v) => v);

  factory ComplianceLot.fromJson(Map<String, dynamic> json) {
    final raw = json['checklist'] as Map<String, dynamic>? ?? const {};
    return ComplianceLot(
      id: json['id'] as String,
      cropName: json['cropName'] as String? ?? '',
      fieldName: json['fieldName'] as String? ?? '',
      season: json['season'] as String? ?? '',
      checklist: raw.map((k, v) => MapEntry(k, v == true)),
    );
  }
}

class ComplianceData {
  final List<ChecklistItem> checklist;
  final List<ComplianceLot> lots;
  final double readinessPct;

  const ComplianceData({
    required this.checklist,
    required this.lots,
    required this.readinessPct,
  });

  factory ComplianceData.fromJson(Map<String, dynamic> json) =>
      ComplianceData(
        checklist: (json['checklist'] as List? ?? const [])
            .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        lots: (json['lots'] as List? ?? const [])
            .map((e) => ComplianceLot.fromJson(e as Map<String, dynamic>))
            .toList(),
        readinessPct: (json['readinessPct'] as num? ?? 0).toDouble(),
      );
}

class TraceabilityLot {
  final String id;
  final String lotId;
  final String cropName;
  final String variety;
  final String fieldName;
  final String season;
  final String status;
  final int activityCount;
  final int sprayRecordCount;
  final int harvestCount;
  final int saleCount;
  final double revenue;
  final Map<String, bool> checklist;

  const TraceabilityLot({
    required this.id,
    required this.lotId,
    required this.cropName,
    required this.variety,
    required this.fieldName,
    required this.season,
    required this.status,
    required this.activityCount,
    required this.sprayRecordCount,
    required this.harvestCount,
    required this.saleCount,
    required this.revenue,
    required this.checklist,
  });

  bool get buyerReady => checklist['buyerReady'] == true;

  factory TraceabilityLot.fromJson(Map<String, dynamic> json) {
    final raw = json['checklist'] as Map<String, dynamic>? ?? const {};
    return TraceabilityLot(
      id: json['id'] as String,
      lotId: json['lotId'] as String? ?? '',
      cropName: json['cropName'] as String? ?? '',
      variety: json['variety'] as String? ?? '',
      fieldName: json['fieldName'] as String? ?? '',
      season: json['season'] as String? ?? '',
      status: json['status'] as String? ?? '',
      activityCount: (json['activityCount'] as num? ?? 0).toInt(),
      sprayRecordCount: (json['sprayRecordCount'] as num? ?? 0).toInt(),
      harvestCount: (json['harvestCount'] as num? ?? 0).toInt(),
      saleCount: (json['saleCount'] as num? ?? 0).toInt(),
      revenue: (json['revenue'] as num? ?? 0).toDouble(),
      checklist: raw.map((k, v) => MapEntry(k, v == true)),
    );
  }
}

class CreditReadinessSummary {
  final int fields;
  final int crops;
  final int transactionCount;
  final int documents;
  final double income;
  final double expense;
  final double net;

  const CreditReadinessSummary({
    required this.fields,
    required this.crops,
    required this.transactionCount,
    required this.documents,
    required this.income,
    required this.expense,
    required this.net,
  });

  factory CreditReadinessSummary.fromJson(Map<String, dynamic> json) =>
      CreditReadinessSummary(
        fields: (json['fields'] as num? ?? 0).toInt(),
        crops: (json['crops'] as num? ?? 0).toInt(),
        transactionCount: (json['transactionCount'] as num? ?? 0).toInt(),
        documents: (json['documents'] as num? ?? 0).toInt(),
        income: (json['income'] as num? ?? 0).toDouble(),
        expense: (json['expense'] as num? ?? 0).toDouble(),
        net: (json['net'] as num? ?? 0).toDouble(),
      );
}

class CreditReadinessData {
  final double readinessScore;
  final String grade;
  final List<ChecklistItem> checks;
  final CreditReadinessSummary summary;

  const CreditReadinessData({
    required this.readinessScore,
    required this.grade,
    required this.checks,
    required this.summary,
  });

  factory CreditReadinessData.fromJson(Map<String, dynamic> json) =>
      CreditReadinessData(
        readinessScore: (json['readinessScore'] as num? ?? 0).toDouble(),
        grade: json['grade'] as String? ?? '-',
        checks: (json['checks'] as List? ?? const [])
            .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        summary: CreditReadinessSummary.fromJson(
            json['summary'] as Map<String, dynamic>? ?? const {}),
      );
}
