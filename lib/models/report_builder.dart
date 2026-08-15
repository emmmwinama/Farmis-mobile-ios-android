class ReportBuilderCropRow {
  final String cropName;
  final String variety;
  final String fieldName;
  final String season;
  final double revenue;
  final double totalCost;
  final double netProfit;
  final double inputCost;
  final double? costPerKg;

  const ReportBuilderCropRow({
    required this.cropName,
    required this.variety,
    required this.fieldName,
    required this.season,
    required this.revenue,
    required this.totalCost,
    required this.netProfit,
    required this.inputCost,
    this.costPerKg,
  });

  factory ReportBuilderCropRow.fromJson(Map<String, dynamic> json) =>
      ReportBuilderCropRow(
        cropName: json['cropName'] as String? ?? '',
        variety: json['variety'] as String? ?? '',
        fieldName: json['fieldName'] as String? ?? '',
        season: json['season'] as String? ?? '',
        revenue: (json['revenue'] as num? ?? 0).toDouble(),
        totalCost: (json['totalCost'] as num? ?? 0).toDouble(),
        netProfit: (json['netProfit'] as num? ?? 0).toDouble(),
        inputCost: (json['inputCost'] as num? ?? 0).toDouble(),
        costPerKg: (json['costPerKg'] as num?)?.toDouble(),
      );
}

class ReportBuilderFieldRow {
  final String name;
  final double area;
  final double cultivatableArea;
  final int crops;

  const ReportBuilderFieldRow({
    required this.name,
    required this.area,
    required this.cultivatableArea,
    required this.crops,
  });

  factory ReportBuilderFieldRow.fromJson(Map<String, dynamic> json) =>
      ReportBuilderFieldRow(
        name: json['name'] as String? ?? '',
        area: (json['area'] as num? ?? 0).toDouble(),
        cultivatableArea: (json['cultivatableArea'] as num? ?? 0).toDouble(),
        crops: (json['crops'] as num? ?? 0).toInt(),
      );
}

class ReportBuilderData {
  final List<ReportBuilderCropRow> cropProfitability;
  final List<ReportBuilderFieldRow> fields;

  const ReportBuilderData({
    required this.cropProfitability,
    required this.fields,
  });

  factory ReportBuilderData.fromJson(Map<String, dynamic> json) {
    final sections = json['sections'] as Map<String, dynamic>? ?? const {};
    return ReportBuilderData(
      cropProfitability: (sections['cropProfitability'] as List? ?? const [])
          .map((e) => ReportBuilderCropRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      fields: (sections['fields'] as List? ?? const [])
          .map((e) => ReportBuilderFieldRow.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

const reportBuilderSections = [
  'season',
  'crop',
  'field',
  'cropField',
  'labour',
  'inputs',
  'yields',
];
