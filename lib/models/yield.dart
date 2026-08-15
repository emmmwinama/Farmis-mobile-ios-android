class YieldModel {
  final String   id;
  final DateTime harvestDate;
  final double   quantity;
  final String   unit;
  final double?  unitWeight;
  final String?  notes;
  final double   totalKg;
  final String   cropFieldId;
  final String   cropTypeName;
  final String   variety;
  final String   season;
  final String   fieldName;

  const YieldModel({
    required this.id,
    required this.harvestDate,
    required this.quantity,
    required this.unit,
    this.unitWeight,
    this.notes,
    required this.totalKg,
    required this.cropFieldId,
    required this.cropTypeName,
    required this.variety,
    required this.season,
    required this.fieldName,
  });

  String get displayQuantity => '${quantity.toStringAsFixed(
      quantity.truncateToDouble() == quantity ? 0 : 1)} $unit';

  String get displayKg {
    if (totalKg >= 1000) {
      return '${(totalKg / 1000).toStringAsFixed(2)} t';
    }
    return '${totalKg.round()} kg';
  }

  factory YieldModel.fromJson(Map<String, dynamic> json) => YieldModel(
    id:           json['id']           as String,
    harvestDate:  DateTime.parse(json['harvestDate'] as String),
    quantity:     (json['quantity']    as num).toDouble(),
    unit:         json['unit']         as String,
    unitWeight:   (json['unitWeight']  as num?)?.toDouble(),
    notes:        json['notes']        as String?,
    totalKg:      (json['totalKg']     as num).toDouble(),
    cropFieldId:  json['cropFieldId']  as String,
    cropTypeName: json['cropTypeName'] as String,
    variety:      json['variety']      as String,
    season:       json['season']       as String,
    fieldName:    json['fieldName']    as String,
  );
}

class YieldByCrop {
  final String crop;
  final int    count;
  final double totalKg;

  const YieldByCrop({
    required this.crop,
    required this.count,
    required this.totalKg,
  });

  String get displayKg {
    if (totalKg >= 1000) {
      return '${(totalKg / 1000).toStringAsFixed(2)} t';
    }
    return '${totalKg.round()} kg';
  }

  factory YieldByCrop.fromJson(Map<String, dynamic> json) => YieldByCrop(
    crop:    json['crop']    as String,
    count:   json['count']   as int,
    totalKg: (json['totalKg']as num).toDouble(),
  );
}

class YieldSummary {
  final int    totalRecords;
  final double totalKg;
  final List<YieldByCrop> byCrop;

  const YieldSummary({
    required this.totalRecords,
    required this.totalKg,
    required this.byCrop,
  });

  String get displayKg {
    if (totalKg >= 1000) {
      return '${(totalKg / 1000).toStringAsFixed(2)} t';
    }
    return '${totalKg.round()} kg';
  }

  factory YieldSummary.fromJson(Map<String, dynamic> json) => YieldSummary(
    totalRecords: json['totalRecords'] as int,
    totalKg:      (json['totalKg']     as num).toDouble(),
    byCrop: (json['byCrop'] as List)
        .map((e) => YieldByCrop.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class YieldsData {
  final List<YieldModel> yields;
  final YieldSummary     summary;

  const YieldsData({
    required this.yields,
    required this.summary,
  });

  factory YieldsData.fromJson(Map<String, dynamic> json) => YieldsData(
    yields: (json['yields'] as List)
        .map((e) => YieldModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    summary: YieldSummary.fromJson(
        json['summary'] as Map<String, dynamic>),
  );
}