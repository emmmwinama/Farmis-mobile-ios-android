class TeamMemberUser {
  final String id;
  final String name;
  final String email;

  const TeamMemberUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory TeamMemberUser.fromJson(Map<String, dynamic> json) =>
      TeamMemberUser(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
      );
}

class TeamMember {
  final String id;
  final String role;
  final String status;
  final String? inviteEmail;
  final DateTime createdAt;
  final TeamMemberUser? user;

  const TeamMember({
    required this.id,
    required this.role,
    required this.status,
    this.inviteEmail,
    required this.createdAt,
    this.user,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        id: json['id'] as String,
        role: json['role'] as String? ?? 'viewer',
        status: json['status'] as String? ?? 'active',
        inviteEmail: json['inviteEmail'] as String?,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        user: json['user'] != null
            ? TeamMemberUser.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );
}

class TeamData {
  final List<TeamMember> members;
  final List<String> roles;
  final List<String> permissionKeys;

  const TeamData({
    required this.members,
    required this.roles,
    required this.permissionKeys,
  });

  factory TeamData.fromJson(Map<String, dynamic> json) => TeamData(
        members: (json['members'] as List? ?? const [])
            .map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
            .toList(),
        roles: List<String>.from(json['roles'] as List? ?? const []),
        permissionKeys:
            List<String>.from(json['permissionKeys'] as List? ?? const []),
      );
}
