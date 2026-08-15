class CropType {
  final String id;
  final String name;
  final bool   isCustom;

  const CropType({
    required this.id,
    required this.name,
    required this.isCustom,
  });

  factory CropType.fromJson(Map<String, dynamic> json) => CropType(
    id:       json['id']       as String,
    name:     json['name']     as String,
    isCustom: json['isCustom'] as bool,
  );
}