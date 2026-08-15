class SeasonalActivityTemplate {
  final String activityType;
  final String timing;
  final String notes;
  final List<String> inputs;

  const SeasonalActivityTemplate({
    required this.activityType,
    required this.timing,
    required this.notes,
    required this.inputs,
  });

  factory SeasonalActivityTemplate.fromJson(Map<String, dynamic> json) =>
      SeasonalActivityTemplate(
        activityType: json['activityType'] as String,
        timing: json['timing'] as String,
        notes: json['notes'] as String,
        inputs: List<String>.from(json['inputs'] as List? ?? const []),
      );
}

class SeasonalPayrollTemplate {
  final String role;
  final String payRateUnit;
  final String notes;

  const SeasonalPayrollTemplate({
    required this.role,
    required this.payRateUnit,
    required this.notes,
  });

  factory SeasonalPayrollTemplate.fromJson(Map<String, dynamic> json) =>
      SeasonalPayrollTemplate(
        role: json['role'] as String,
        payRateUnit: json['payRateUnit'] as String,
        notes: json['notes'] as String,
      );
}

class SeasonalSalesTemplate {
  final String category;
  final String description;
  final List<String> evidence;

  const SeasonalSalesTemplate({
    required this.category,
    required this.description,
    required this.evidence,
  });

  factory SeasonalSalesTemplate.fromJson(Map<String, dynamic> json) =>
      SeasonalSalesTemplate(
        category: json['category'] as String,
        description: json['description'] as String,
        evidence: List<String>.from(json['evidence'] as List? ?? const []),
      );
}

class SeasonalTemplate {
  final String id;
  final String name;
  final String crop;
  final String season;
  final String description;
  final List<SeasonalActivityTemplate> activities;
  final List<SeasonalPayrollTemplate> payroll;
  final List<SeasonalSalesTemplate> sales;
  final List<String> recordPackHints;

  const SeasonalTemplate({
    required this.id,
    required this.name,
    required this.crop,
    required this.season,
    required this.description,
    required this.activities,
    required this.payroll,
    required this.sales,
    required this.recordPackHints,
  });

  factory SeasonalTemplate.fromJson(Map<String, dynamic> json) =>
      SeasonalTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        crop: json['crop'] as String,
        season: json['season'] as String,
        description: json['description'] as String,
        activities: (json['activities'] as List? ?? const [])
            .map((e) => SeasonalActivityTemplate.fromJson(
                e as Map<String, dynamic>))
            .toList(),
        payroll: (json['payroll'] as List? ?? const [])
            .map((e) =>
                SeasonalPayrollTemplate.fromJson(e as Map<String, dynamic>))
            .toList(),
        sales: (json['sales'] as List? ?? const [])
            .map((e) =>
                SeasonalSalesTemplate.fromJson(e as Map<String, dynamic>))
            .toList(),
        recordPackHints:
            List<String>.from(json['recordPackHints'] as List? ?? const []),
      );
}
