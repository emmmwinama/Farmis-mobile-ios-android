class FarmModel {
  final String  id;
  final String  name;
  final String  location;

  const FarmModel({
    required this.id,
    required this.name,
    required this.location,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) => FarmModel(
    id:       json['id']       as String,
    name:     json['name']     as String,
    location: json['location'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
  };
}
