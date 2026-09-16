class FarmMembership {
  final String id;
  final String name;
  final String? location;
  final String role;

  const FarmMembership({required this.id, required this.name, this.location, required this.role});

  factory FarmMembership.fromJson(Map<String, dynamic> json) => FarmMembership(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        location: json['location'] as String?,
        role: json['role'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'location': location, 'role': role};
}

/// The response of `GET /api/mobile/farm-context` — every farm the signed-in
/// user belongs to, and which one the current session is scoped to (sent
/// back as `X-Farm-Id` on every subsequent request).
class FarmContext {
  final String activeFarmId;
  final String role;
  final List<FarmMembership> farms;

  const FarmContext({required this.activeFarmId, required this.role, required this.farms});

  FarmMembership? get activeFarm {
    for (final f in farms) {
      if (f.id == activeFarmId) return f;
    }
    return null;
  }

  factory FarmContext.fromJson(Map<String, dynamic> json) => FarmContext(
        activeFarmId: json['active_farm_id'] as String? ?? '',
        role: json['role'] as String? ?? '',
        farms: (json['farms'] as List? ?? const [])
            .map((f) => FarmMembership.fromJson(f as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'active_farm_id': activeFarmId,
        'role': role,
        'farms': farms.map((f) => f.toJson()).toList(),
      };
}
