class SubscriptionTier {
  final String id;
  final String name;
  final String? description;
  final double priceMonthly;
  final double priceAnnual;
  final bool isFeatured;
  final int maxFields;
  final int maxCrops;
  final int maxActivities;
  final int maxTransactions;
  final int maxEmployees;
  final int maxFarms;
  final int maxTeamMembers;
  final List<String> features;

  const SubscriptionTier({
    required this.id,
    required this.name,
    required this.description,
    required this.priceMonthly,
    required this.priceAnnual,
    required this.isFeatured,
    required this.maxFields,
    required this.maxCrops,
    required this.maxActivities,
    required this.maxTransactions,
    required this.maxEmployees,
    required this.maxFarms,
    required this.maxTeamMembers,
    required this.features,
  });

  factory SubscriptionTier.fromJson(Map<String, dynamic> json) {
    final features = <String>[
      if (json['seasonAnalytics'] == true) 'Season analytics',
      if (json['yieldSuggestions'] == true) 'Yield suggestions',
      if (json['costPerHectare'] == true) 'Cost per hectare',
      if (json['payrollTracking'] == true) 'Payroll tracking',
      if (json['multipleFarms'] == true) 'Multiple farms',
      if (json['teamAccounts'] == true) 'Team accounts',
      if (json['customReports'] == true) 'Custom reports',
      if (json['apiAccess'] == true) 'API access',
      if (json['dataRetentionLifetime'] == true) 'Lifetime data retention',
    ];

    return SubscriptionTier(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      priceMonthly: (json['priceMonthly'] as num).toDouble(),
      priceAnnual: (json['priceAnnual'] as num).toDouble(),
      isFeatured: json['isFeatured'] as bool? ?? false,
      maxFields: json['maxFields'] as int? ?? 0,
      maxCrops: json['maxCrops'] as int? ?? 0,
      maxActivities: json['maxActivities'] as int? ?? 0,
      maxTransactions: json['maxTransactions'] as int? ?? 0,
      maxEmployees: json['maxEmployees'] as int? ?? 0,
      maxFarms: json['maxFarms'] as int? ?? 0,
      maxTeamMembers: json['maxTeamMembers'] as int? ?? 0,
      features: features,
    );
  }
}
