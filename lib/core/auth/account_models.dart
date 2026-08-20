class AccountUser {
  final String id;
  final String? name;
  final String email;

  const AccountUser({required this.id, required this.name, required this.email});

  factory AccountUser.fromJson(Map<String, dynamic> json) => AccountUser(
        id: json['id'] as String,
        name: json['name'] as String?,
        email: json['email'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}

class AccountFarm {
  final String id;
  final String name;

  const AccountFarm({required this.id, required this.name});

  factory AccountFarm.fromJson(Map<String, dynamic> json) => AccountFarm(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class AccountSubscription {
  final String status;
  final String tierName;

  const AccountSubscription({required this.status, required this.tierName});

  /// Whether cloud backup/restore is expected to work — only the paid
  /// (Monthly/Lifetime) tiers have `syncEnabled` on the backend; this is a
  /// display-only mirror of that so the UI can show the right CTA without an
  /// extra round trip. The backend re-checks the real flag on every call.
  bool get isPaid => !tierName.toLowerCase().contains('free');

  factory AccountSubscription.fromJson(Map<String, dynamic> json) => AccountSubscription(
        status: json['status'] as String? ?? 'inactive',
        tierName: json['tierName'] as String? ?? 'Mobile Free',
      );

  Map<String, dynamic> toJson() => {'status': status, 'tierName': tierName};
}

/// The signed-in account snapshot — cached to secure storage so the app
/// shows the last-known plan/name immediately on cold start, before the
/// background profile refresh (or without one, if offline).
class Account {
  final AccountUser user;
  final AccountFarm? farm;
  final AccountSubscription? subscription;

  const Account({required this.user, required this.farm, required this.subscription});

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        user: AccountUser.fromJson(json['user'] as Map<String, dynamic>),
        farm: json['farm'] != null ? AccountFarm.fromJson(json['farm'] as Map<String, dynamic>) : null,
        subscription: json['subscription'] != null
            ? AccountSubscription.fromJson(json['subscription'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'farm': farm?.toJson(),
        'subscription': subscription?.toJson(),
      };
}
