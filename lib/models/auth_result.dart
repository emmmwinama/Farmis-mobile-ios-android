import 'user.dart';
import 'farm.dart';
import 'subscription_info.dart';

class AuthResult {
  final String           token;
  final UserModel        user;
  final FarmModel?       farm;
  final SubscriptionInfo? subscription;

  const AuthResult({
    required this.token,
    required this.user,
    this.farm,
    this.subscription,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) =>
      AuthResult._build(json, json['token'] as String);

  factory AuthResult.fromJsonWithToken(
    Map<String, dynamic> json,
    String token,
  ) =>
      AuthResult._build(json, json['token'] as String? ?? token);

  static AuthResult _build(Map<String, dynamic> json, String token) =>
      AuthResult(
        token: token,
        user:  UserModel.fromJson(json['user'] as Map<String, dynamic>),
        farm:  json['farm'] != null
            ? FarmModel.fromJson(json['farm'] as Map<String, dynamic>)
            : null,
        subscription: json['subscription'] != null
            ? SubscriptionInfo.fromJson(
            json['subscription'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
    'token': token,
    'user': user.toJson(),
    if (farm != null) 'farm': farm!.toJson(),
    if (subscription != null) 'subscription': subscription!.toJson(),
  };
}
