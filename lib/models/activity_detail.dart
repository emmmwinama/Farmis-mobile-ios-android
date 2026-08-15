class ActivityInput {
  final String id;
  final String inputName;
  final String category;
  final double quantity;
  final String unit;
  final double unitCost;
  final double totalCost;

  const ActivityInput({
    required this.id,
    required this.inputName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.unitCost,
    required this.totalCost,
  });

  factory ActivityInput.fromJson(Map<String, dynamic> json) => ActivityInput(
    id:        json['id']        as String,
    inputName: json['inputName'] as String,
    category:  json['category']  as String,
    quantity:  (json['quantity'] as num).toDouble(),
    unit:      json['unit']      as String,
    unitCost:  (json['unitCost'] as num).toDouble(),
    totalCost: (json['totalCost']as num).toDouble(),
  );
}

class ActivityLabour {
  final String id;
  final String employeeName;
  final double hoursWorked;
  final double daysWorked;
  final double totalCost;

  const ActivityLabour({
    required this.id,
    required this.employeeName,
    required this.hoursWorked,
    required this.daysWorked,
    required this.totalCost,
  });

  factory ActivityLabour.fromJson(Map<String, dynamic> json) => ActivityLabour(
    id:           json['id']           as String,
    employeeName: json['employeeName'] as String,
    hoursWorked:  (json['hoursWorked'] as num).toDouble(),
    daysWorked:   (json['daysWorked']  as num).toDouble(),
    totalCost:    (json['totalCost']   as num).toDouble(),
  );
}

class ActivityOtherCost {
  final String id;
  final String description;
  final double amount;

  const ActivityOtherCost({
    required this.id,
    required this.description,
    required this.amount,
  });

  factory ActivityOtherCost.fromJson(Map<String, dynamic> json) =>
      ActivityOtherCost(
        id:          json['id']          as String,
        description: json['description'] as String,
        amount:      (json['amount']     as num).toDouble(),
      );
}

class ActivityCosts {
  final double inputs;
  final double labour;
  final double other;
  final double total;

  const ActivityCosts({
    required this.inputs,
    required this.labour,
    required this.other,
    required this.total,
  });

  factory ActivityCosts.fromJson(Map<String, dynamic> json) => ActivityCosts(
    inputs: (json['inputs'] as num).toDouble(),
    labour: (json['labour'] as num).toDouble(),
    other:  (json['other']  as num).toDouble(),
    total:  (json['total']  as num).toDouble(),
  );
}

class ActivityDetail {
  final String         id;
  final String         activityType;
  final DateTime       date;
  final String?        notes;
  final String         fieldId;
  final String         fieldName;
  final String?        cropFieldId;
  final String?        cropName;
  final ActivityCosts  costs;
  final List<ActivityInput>     inputs;
  final List<ActivityLabour>    labourRecords;
  final List<ActivityOtherCost> otherCosts;

  const ActivityDetail({
    required this.id,
    required this.activityType,
    required this.date,
    this.notes,
    required this.fieldId,
    required this.fieldName,
    this.cropFieldId,
    this.cropName,
    required this.costs,
    required this.inputs,
    required this.labourRecords,
    required this.otherCosts,
  });

  factory ActivityDetail.fromJson(Map<String, dynamic> json) => ActivityDetail(
    id:           json['id']           as String,
    activityType: json['activityType'] as String,
    date:         DateTime.parse(json['date'] as String),
    notes:        json['notes']        as String?,
    fieldId:      json['fieldId']      as String,
    fieldName:    json['fieldName']    as String,
    cropFieldId:  json['cropFieldId']  as String?,
    cropName:     json['cropName']     as String?,
    costs: ActivityCosts.fromJson(
        json['costs'] as Map<String, dynamic>),
    inputs: (json['inputs'] as List)
        .map((e) => ActivityInput.fromJson(e as Map<String, dynamic>))
        .toList(),
    labourRecords: (json['labourRecords'] as List)
        .map((e) => ActivityLabour.fromJson(e as Map<String, dynamic>))
        .toList(),
    otherCosts: (json['otherCosts'] as List)
        .map((e) => ActivityOtherCost.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}