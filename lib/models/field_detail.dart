class FieldCrop {
  final String   id;
  final String   cropTypeName;
  final String   variety;
  final double   areaPlanted;
  final String   season;
  final DateTime plantingDate;
  final DateTime expectedHarvestDate;
  final String   status;

  const FieldCrop({
    required this.id,
    required this.cropTypeName,
    required this.variety,
    required this.areaPlanted,
    required this.season,
    required this.plantingDate,
    required this.expectedHarvestDate,
    required this.status,
  });

  int get daysToHarvest =>
      expectedHarvestDate.difference(DateTime.now()).inDays;

  factory FieldCrop.fromJson(Map<String, dynamic> json) => FieldCrop(
    id:                  json['id']                  as String? ?? '',
    cropTypeName:        json['cropTypeName']        as String? ?? 'Crop',
    variety:             json['variety']             as String? ?? '',
    areaPlanted:         (json['areaPlanted']        as num? ?? 0).toDouble(),
    season:              json['season']              as String? ?? '',
    plantingDate:        DateTime.tryParse(
          json['plantingDate'] as String? ?? '',
        ) ??
        DateTime.now(),
    expectedHarvestDate: DateTime.tryParse(
          json['expectedHarvestDate'] as String? ?? '',
        ) ??
        DateTime.now(),
    status:              json['status']              as String? ?? 'Active',
  );
}

class FieldActivity {
  final String   id;
  final String   activityType;
  final DateTime date;
  final String?  notes;
  final String?  cropName;

  const FieldActivity({
    required this.id,
    required this.activityType,
    required this.date,
    this.notes,
    this.cropName,
  });

  factory FieldActivity.fromJson(Map<String, dynamic> json) => FieldActivity(
    id:           json['id']           as String? ?? '',
    activityType: json['activityType'] as String? ?? 'Activity',
    date:         DateTime.tryParse(json['date'] as String? ?? '') ??
        DateTime.now(),
    notes:        json['notes']        as String?,
    cropName:     json['cropName']     as String?,
  );
}

class FieldDetail {
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
  final List<FieldCrop>     crops;
  final List<FieldActivity> recentActivities;

  const FieldDetail({
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
    required this.crops,
    required this.recentActivities,
  });

  double get availableArea => cultivatableArea - allocatedArea;

  factory FieldDetail.fromJson(Map<String, dynamic> json) => FieldDetail(
    id:               json['id']               as String? ?? '',
    name:             json['name']             as String? ?? 'Field',
    totalArea:        (json['totalArea']        as num? ?? 0).toDouble(),
    cultivatableArea: (json['cultivatableArea'] as num? ?? 0).toDouble(),
    soilType:         json['soilType']          as String? ?? 'Not set',
    locationLat:      (json['locationLat']      as num?)?.toDouble(),
    locationLng:      (json['locationLng']      as num?)?.toDouble(),
    notes:            json['notes']             as String?,
    createdAt:        DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.now(),
    allocatedArea:    (json['allocatedArea']    as num? ?? 0).toDouble(),
    crops: (json['crops'] as List? ?? const [])
        .map((e) => FieldCrop.fromJson(e as Map<String, dynamic>))
        .toList(),
    recentActivities: (json['recentActivities'] as List? ?? const [])
        .map((e) => FieldActivity.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
