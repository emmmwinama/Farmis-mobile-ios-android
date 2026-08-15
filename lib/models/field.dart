class FieldModel {
  final String   id;
  final String   name;
  final double   totalArea;
  final double   cultivatableArea;
  final String   soilType;
  final double?  locationLat;
  final double?  locationLng;
  final String?  notes;
  final DateTime createdAt;
  final double   allocatedArea;
  final int      cropCount;
  final List<String> crops;

  const FieldModel({
    required this.id,
    required this.name,
    required this.totalArea,
    required this.cultivatableArea,
    required this.soilType,
    this.locationLat,
    this.locationLng,
    this.notes,
    required this.createdAt,
    required this.allocatedArea,
    required this.cropCount,
    required this.crops,
  });

  double get availableArea => cultivatableArea - allocatedArea;

  factory FieldModel.fromJson(Map<String, dynamic> json) => FieldModel(
    id:               json['id']               as String,
    name:             json['name']             as String,
    totalArea:        (json['totalArea']        as num).toDouble(),
    cultivatableArea: (json['cultivatableArea'] as num).toDouble(),
    soilType:         json['soilType']          as String,
    locationLat:      (json['locationLat']      as num?)?.toDouble(),
    locationLng:      (json['locationLng']      as num?)?.toDouble(),
    notes:            json['notes']             as String?,
    createdAt:        DateTime.parse(json['createdAt'] as String),
    allocatedArea:    (json['allocatedArea']    as num).toDouble(),
    cropCount:        json['cropCount']         as int,
    crops:            List<String>.from(json['crops'] as List),
  );
}