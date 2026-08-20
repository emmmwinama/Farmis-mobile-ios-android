class CropFieldModel {
  final String   id;
  final String   cropTypeName;
  final String   cropTypeId;
  final String   variety;
  final double   areaPlanted;
  final String   season;
  final DateTime plantingDate;
  final DateTime expectedHarvestDate;
  final String   status;
  final String   fieldId;
  final String   fieldName;
  final double   fieldCultivatable;

  const CropFieldModel({
    required this.id,
    required this.cropTypeName,
    required this.cropTypeId,
    required this.variety,
    required this.areaPlanted,
    required this.season,
    required this.plantingDate,
    required this.expectedHarvestDate,
    required this.status,
    required this.fieldId,
    required this.fieldName,
    required this.fieldCultivatable,
  });

  int get daysToHarvest =>
      expectedHarvestDate.difference(DateTime.now()).inDays;

  bool get isActive => status == 'Active';
  bool get isOverdue => isActive && daysToHarvest < 0;
  bool get isDueSoon => isActive && daysToHarvest >= 0 && daysToHarvest <= 14;

  factory CropFieldModel.fromJson(Map<String, dynamic> json) => CropFieldModel(
    id:                  json['id']                  as String,
    cropTypeName:        json['cropTypeName']        as String,
    cropTypeId:          json['cropTypeId']          as String,
    variety:             json['variety']             as String,
    areaPlanted:         (json['areaPlanted']        as num).toDouble(),
    season:              json['season']              as String,
    plantingDate:        DateTime.parse(json['plantingDate']        as String),
    expectedHarvestDate: DateTime.parse(json['expectedHarvestDate'] as String),
    status:              json['status']              as String,
    fieldId:             json['fieldId']             as String,
    fieldName:           json['fieldName']           as String,
    fieldCultivatable:   (json['fieldCultivatable']  as num).toDouble(),
  );
}