class CropCosts {
  final double inputs;
  final double labour;
  final double other;
  final double total;

  const CropCosts({
    required this.inputs,
    required this.labour,
    required this.other,
    required this.total,
  });

  factory CropCosts.fromJson(Map<String, dynamic> json) => CropCosts(
    inputs: (json['inputs'] as num).toDouble(),
    labour: (json['labour'] as num).toDouble(),
    other:  (json['other']  as num).toDouble(),
    total:  (json['total']  as num).toDouble(),
  );
}

class CropYield {
  final String   id;
  final DateTime harvestDate;
  final double   quantity;
  final String   unit;
  final double?  unitWeight;
  final String?  notes;

  const CropYield({
    required this.id,
    required this.harvestDate,
    required this.quantity,
    required this.unit,
    this.unitWeight,
    this.notes,
  });

  double get totalKg {
    if (unit.toLowerCase() == 'kg')    return quantity;
    if (unit.toLowerCase() == 'tonne') return quantity * 1000;
    if (unit.toLowerCase().startsWith('bag')) {
      return quantity * (unitWeight ?? 50);
    }
    return quantity;
  }

  factory CropYield.fromJson(Map<String, dynamic> json) => CropYield(
    id:          json['id']          as String,
    harvestDate: DateTime.parse(json['harvestDate'] as String),
    quantity:    (json['quantity']   as num).toDouble(),
    unit:        json['unit']        as String,
    unitWeight:  (json['unitWeight'] as num?)?.toDouble(),
    notes:       json['notes']       as String?,
  );
}

class CropActivity {
  final String   id;
  final String   activityType;
  final DateTime date;
  final String?  notes;
  final double   totalCost;

  const CropActivity({
    required this.id,
    required this.activityType,
    required this.date,
    this.notes,
    required this.totalCost,
  });

  factory CropActivity.fromJson(Map<String, dynamic> json) => CropActivity(
    id:           json['id']           as String,
    activityType: json['activityType'] as String,
    date:         DateTime.parse(json['date'] as String),
    notes:        json['notes']        as String?,
    totalCost:    (json['totalCost']   as num).toDouble(),
  );
}

class CropDetail {
  final String       id;
  final String       cropTypeName;
  final String       variety;
  final double       areaPlanted;
  final String       season;
  final DateTime     plantingDate;
  final DateTime     expectedHarvestDate;
  final String       status;
  final String       fieldId;
  final String       fieldName;
  final CropCosts    costs;
  final List<CropYield>    yields;
  final List<CropActivity> activities;

  const CropDetail({
    required this.id,
    required this.cropTypeName,
    required this.variety,
    required this.areaPlanted,
    required this.season,
    required this.plantingDate,
    required this.expectedHarvestDate,
    required this.status,
    required this.fieldId,
    required this.fieldName,
    required this.costs,
    required this.yields,
    required this.activities,
  });

  int get daysToHarvest =>
      expectedHarvestDate.difference(DateTime.now()).inDays;

  bool get isArchived => status == 'Archived';
  bool get isOverdue  => !isArchived && daysToHarvest < 0;
  bool get isDueSoon  => !isArchived && daysToHarvest >= 0 && daysToHarvest <= 14;

  double get totalYieldKg =>
      yields.fold(0, (s, y) => s + y.totalKg);

  factory CropDetail.fromJson(Map<String, dynamic> json) => CropDetail(
    id:                  json['id']                  as String,
    cropTypeName:        json['cropTypeName']        as String,
    variety:             json['variety']             as String,
    areaPlanted:         (json['areaPlanted']        as num).toDouble(),
    season:              json['season']              as String,
    plantingDate:        DateTime.parse(json['plantingDate']        as String),
    expectedHarvestDate: DateTime.parse(json['expectedHarvestDate'] as String),
    status:              json['status']              as String,
    fieldId:             json['fieldId']             as String,
    fieldName:           json['fieldName']           as String,
    costs:      CropCosts.fromJson(json['costs'] as Map<String, dynamic>),
    yields:     (json['yields'] as List)
        .map((e) => CropYield.fromJson(e as Map<String, dynamic>))
        .toList(),
    activities: (json['activities'] as List)
        .map((e) => CropActivity.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}