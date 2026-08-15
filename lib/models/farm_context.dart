import 'farm.dart';

class FarmContext {
  final List<FarmModel> farms;
  final String? activeFarmId;
  final String? token;

  const FarmContext({
    required this.farms,
    this.activeFarmId,
    this.token,
  });

  factory FarmContext.fromJson(Map<String, dynamic> json) => FarmContext(
        farms: (json['farms'] as List? ?? const [])
            .map((e) => FarmModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        activeFarmId: json['activeFarmId'] as String?,
        token: json['token'] as String?,
      );
}
