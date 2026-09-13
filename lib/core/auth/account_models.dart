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
