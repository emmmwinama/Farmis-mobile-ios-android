class SubscriptionInfo {
  final String status;
  final String tierName;

  const SubscriptionInfo({
    required this.status,
    required this.tierName,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) =>
      SubscriptionInfo(
        status: json['status'] as String? ?? 'active',
        tierName: json['tierName'] as String? ??
            json['planName'] as String? ??
            (json['tier'] is Map<String, dynamic>
                ? (json['tier'] as Map<String, dynamic>)['name'] as String?
                : null) ??
            'Unknown plan',
      );

  Map<String, dynamic> toJson() => {
    'status': status,
    'tierName': tierName,
  };
}
