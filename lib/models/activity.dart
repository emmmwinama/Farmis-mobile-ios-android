class ActivityLabourSummary {
  final String id;
  final String employeeName;
  final double hoursWorked;
  final double daysWorked;
  final double totalCost;

  const ActivityLabourSummary({
    required this.id,
    required this.employeeName,
    required this.hoursWorked,
    required this.daysWorked,
    required this.totalCost,
  });

  factory ActivityLabourSummary.fromJson(Map<String, dynamic> json) =>
      ActivityLabourSummary(
        id:           json['id']           as String,
        employeeName: json['employeeName'] as String,
        hoursWorked:  (json['hoursWorked'] as num).toDouble(),
        daysWorked:   (json['daysWorked']  as num).toDouble(),
        totalCost:    (json['totalCost']   as num).toDouble(),
      );
}

class ActivityInputSummary {
  final String id;
  final String inputName;
  final String category;
  final double quantity;
  final String unit;
  final double unitCost;
  final double totalCost;

  const ActivityInputSummary({
    required this.id,
    required this.inputName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.unitCost,
    required this.totalCost,
  });

  factory ActivityInputSummary.fromJson(Map<String, dynamic> json) =>
      ActivityInputSummary(
        id:        json['id']        as String,
        inputName: json['inputName'] as String,
        category:  json['category']  as String,
        quantity:  (json['quantity'] as num).toDouble(),
        unit:      json['unit']      as String,
        unitCost:  (json['unitCost'] as num).toDouble(),
        totalCost: (json['totalCost']as num).toDouble(),
      );
}

class ActivityOtherCostSummary {
  final String id;
  final String description;
  final double amount;

  const ActivityOtherCostSummary({
    required this.id,
    required this.description,
    required this.amount,
  });

  factory ActivityOtherCostSummary.fromJson(Map<String, dynamic> json) =>
      ActivityOtherCostSummary(
        id:          json['id']          as String,
        description: json['description'] as String,
        amount:      (json['amount']     as num).toDouble(),
      );
}

class ActivityModel {
  final String   id;
  final String   activityType;
  final DateTime date;
  final String?  notes;
  final String   fieldId;
  final String   fieldName;
  final String?  cropFieldId;
  final String?  cropName;
  final String?  cropVariety;
  final String?  season;
  final double   totalCost;
  final double   totalInputCost;
  final double   totalLabourCost;
  final double   totalOtherCost;
  final int      inputCount;
  final int      labourCount;
  final List<ActivityInputSummary>     inputs;
  final List<ActivityLabourSummary>    labourRecords;
  final List<ActivityOtherCostSummary> otherCosts;

  const ActivityModel({
    required this.id,
    required this.activityType,
    required this.date,
    this.notes,
    required this.fieldId,
    required this.fieldName,
    this.cropFieldId,
    this.cropName,
    this.cropVariety,
    this.season,
    required this.totalCost,
    required this.totalInputCost,
    required this.totalLabourCost,
    required this.totalOtherCost,
    required this.inputCount,
    required this.labourCount,
    required this.inputs,
    required this.labourRecords,
    required this.otherCosts,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
    id:              json['id']              as String,
    activityType:    json['activityType']    as String,
    date:            DateTime.parse(json['date'] as String),
    notes:           json['notes']           as String?,
    fieldId:         json['fieldId']         as String,
    fieldName:       json['fieldName']       as String,
    cropFieldId:     json['cropFieldId']     as String?,
    cropName:        json['cropName']        as String?,
    cropVariety:     json['cropVariety']     as String?,
    season:          json['season']          as String?,
    totalCost:       (json['totalCost']      as num).toDouble(),
    totalInputCost:  (json['totalInputCost'] as num).toDouble(),
    totalLabourCost: (json['totalLabourCost']as num).toDouble(),
    totalOtherCost:  (json['totalOtherCost'] as num).toDouble(),
    inputCount:      json['inputCount']      as int,
    labourCount:     json['labourCount']     as int,
    inputs: (json['inputs'] as List)
        .map((e) => ActivityInputSummary.fromJson(
        e as Map<String, dynamic>))
        .toList(),
    labourRecords: (json['labourRecords'] as List)
        .map((e) => ActivityLabourSummary.fromJson(
        e as Map<String, dynamic>))
        .toList(),
    otherCosts: (json['otherCosts'] as List)
        .map((e) => ActivityOtherCostSummary.fromJson(
        e as Map<String, dynamic>))
        .toList(),
  );
}

// ── Analytics models ──────────────────────────────────────────────────────────
class ActivityByType {
  final String type;
  final int    count;
  final double totalCost;

  const ActivityByType({
    required this.type,
    required this.count,
    required this.totalCost,
  });

  factory ActivityByType.fromJson(Map<String, dynamic> json) =>
      ActivityByType(
        type:      json['type']      as String,
        count:     json['count']     as int,
        totalCost: (json['totalCost']as num).toDouble(),
      );
}

class ActivityByField {
  final String name;
  final int    count;
  final double totalCost;

  const ActivityByField({
    required this.name,
    required this.count,
    required this.totalCost,
  });

  factory ActivityByField.fromJson(Map<String, dynamic> json) =>
      ActivityByField(
        name:      json['name']      as String,
        count:     json['count']     as int,
        totalCost: (json['totalCost']as num).toDouble(),
      );
}

class ActivityBySeason {
  final String       season;
  final int          count;
  final double       totalCost;
  final List<String> types;

  const ActivityBySeason({
    required this.season,
    required this.count,
    required this.totalCost,
    required this.types,
  });

  factory ActivityBySeason.fromJson(Map<String, dynamic> json) =>
      ActivityBySeason(
        season:    json['season']    as String,
        count:     json['count']     as int,
        totalCost: (json['totalCost']as num).toDouble(),
        types:     List<String>.from(json['types'] as List),
      );
}

class ActivitiesData {
  final List<ActivityModel>    activities;
  final List<String>           allSeasons;
  final List<ActivityByType>   byType;
  final List<ActivityByField>  byField;
  final List<ActivityBySeason> bySeason;

  const ActivitiesData({
    required this.activities,
    required this.allSeasons,
    required this.byType,
    required this.byField,
    required this.bySeason,
  });

  factory ActivitiesData.fromJson(Map<String, dynamic> json) =>
      ActivitiesData(
        activities: (json['activities'] as List)
            .map((e) => ActivityModel.fromJson(
            e as Map<String, dynamic>))
            .toList(),
        allSeasons: List<String>.from(json['allSeasons'] as List),
        byType: (json['byType'] as List)
            .map((e) => ActivityByType.fromJson(
            e as Map<String, dynamic>))
            .toList(),
        byField: (json['byField'] as List)
            .map((e) => ActivityByField.fromJson(
            e as Map<String, dynamic>))
            .toList(),
        bySeason: (json['bySeason'] as List)
            .map((e) => ActivityBySeason.fromJson(
            e as Map<String, dynamic>))
            .toList(),
      );
}