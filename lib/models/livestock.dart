class LivestockType {
  final String id;
  final String name;
  final String category;
  final String icon;

  const LivestockType({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
  });

  factory LivestockType.fromJson(Map<String, dynamic> json) => LivestockType(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        category: json['category'] as String? ?? '',
        icon: json['icon'] as String? ?? 'Cattle',
      );
}

class AnimalHealth {
  final String id;
  final String type;
  final String description;
  final String? veterinarian;
  final double cost;
  final DateTime date;
  final DateTime? nextDueDate;
  final String? notes;

  const AnimalHealth({
    required this.id,
    required this.type,
    required this.description,
    this.veterinarian,
    required this.cost,
    required this.date,
    this.nextDueDate,
    this.notes,
  });

  factory AnimalHealth.fromJson(Map<String, dynamic> json) => AnimalHealth(
        id: json['id'] as String,
        type: json['type'] as String? ?? '',
        description: json['description'] as String? ?? '',
        veterinarian: json['veterinarian'] as String?,
        cost: (json['cost'] as num? ?? 0).toDouble(),
        date: DateTime.tryParse(json['date'] as String? ?? '') ??
            DateTime.now(),
        nextDueDate: json['nextDueDate'] != null
            ? DateTime.tryParse(json['nextDueDate'] as String)
            : null,
        notes: json['notes'] as String?,
      );
}

class AnimalProduction {
  final String id;
  final String type;
  final double quantity;
  final String unit;
  final DateTime date;
  final double? pricePerUnit;
  final double? totalValue;
  final String? notes;

  const AnimalProduction({
    required this.id,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.date,
    this.pricePerUnit,
    this.totalValue,
    this.notes,
  });

  factory AnimalProduction.fromJson(Map<String, dynamic> json) =>
      AnimalProduction(
        id: json['id'] as String,
        type: json['type'] as String? ?? '',
        quantity: (json['quantity'] as num? ?? 0).toDouble(),
        unit: json['unit'] as String? ?? '',
        date: DateTime.tryParse(json['date'] as String? ?? '') ??
            DateTime.now(),
        pricePerUnit: (json['pricePerUnit'] as num?)?.toDouble(),
        totalValue: (json['totalValue'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
      );
}

class AnimalWeight {
  final String id;
  final double weight;
  final String unit;
  final DateTime date;
  final String? notes;

  const AnimalWeight({
    required this.id,
    required this.weight,
    required this.unit,
    required this.date,
    this.notes,
  });

  factory AnimalWeight.fromJson(Map<String, dynamic> json) => AnimalWeight(
        id: json['id'] as String,
        weight: (json['weight'] as num? ?? 0).toDouble(),
        unit: json['unit'] as String? ?? 'kg',
        date: DateTime.tryParse(json['date'] as String? ?? '') ??
            DateTime.now(),
        notes: json['notes'] as String?,
      );
}

class AnimalExpense {
  final String id;
  final String category;
  final String description;
  final double amount;
  final DateTime date;
  final String? notes;

  const AnimalExpense({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    this.notes,
  });

  factory AnimalExpense.fromJson(Map<String, dynamic> json) => AnimalExpense(
        id: json['id'] as String,
        category: json['category'] as String? ?? '',
        description: json['description'] as String? ?? '',
        amount: (json['amount'] as num? ?? 0).toDouble(),
        date: DateTime.tryParse(json['date'] as String? ?? '') ??
            DateTime.now(),
        notes: json['notes'] as String?,
      );
}

class AnimalSale {
  final String id;
  final DateTime saleDate;
  final int quantity;
  final double? weightAtSale;
  final double? pricePerKg;
  final double totalAmount;
  final String? buyer;
  final String? notes;

  const AnimalSale({
    required this.id,
    required this.saleDate,
    required this.quantity,
    this.weightAtSale,
    this.pricePerKg,
    required this.totalAmount,
    this.buyer,
    this.notes,
  });

  factory AnimalSale.fromJson(Map<String, dynamic> json) => AnimalSale(
        id: json['id'] as String,
        saleDate: DateTime.tryParse(json['saleDate'] as String? ?? '') ??
            DateTime.now(),
        quantity: (json['quantity'] as num? ?? 1).toInt(),
        weightAtSale: (json['weightAtSale'] as num?)?.toDouble(),
        pricePerKg: (json['pricePerKg'] as num?)?.toDouble(),
        totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
        buyer: json['buyer'] as String?,
        notes: json['notes'] as String?,
      );
}

class Animal {
  final String id;
  final String livestockTypeId;
  final String? tag;
  final String? name;
  final String? group;
  final String sex;
  final DateTime? birthDate;
  final DateTime acquisitionDate;
  final String acquisitionType;
  final double? acquisitionCost;
  final String status;
  final String? breed;
  final String? colour;
  final double? weight;
  final String? notes;
  final String? livestockTypeName;
  final List<AnimalHealth> healthRecords;
  final List<AnimalProduction> productions;
  final List<AnimalWeight> weightRecords;
  final List<AnimalExpense> expenses;
  final List<AnimalSale> sales;

  const Animal({
    required this.id,
    required this.livestockTypeId,
    this.tag,
    this.name,
    this.group,
    required this.sex,
    this.birthDate,
    required this.acquisitionDate,
    required this.acquisitionType,
    this.acquisitionCost,
    required this.status,
    this.breed,
    this.colour,
    this.weight,
    this.notes,
    this.livestockTypeName,
    this.healthRecords = const [],
    this.productions = const [],
    this.weightRecords = const [],
    this.expenses = const [],
    this.sales = const [],
  });

  String get displayName =>
      name?.isNotEmpty == true ? name! : (tag?.isNotEmpty == true ? tag! : 'Animal');

  factory Animal.fromJson(Map<String, dynamic> json) {
    final type = json['livestockType'] as Map<String, dynamic>?;
    return Animal(
      id: json['id'] as String,
      livestockTypeId: json['livestockTypeId'] as String? ?? '',
      tag: json['tag'] as String?,
      name: json['name'] as String?,
      group: json['group'] as String?,
      sex: json['sex'] as String? ?? 'Unknown',
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'] as String)
          : null,
      acquisitionDate:
          DateTime.tryParse(json['acquisitionDate'] as String? ?? '') ??
              DateTime.now(),
      acquisitionType: json['acquisitionType'] as String? ?? 'Born on farm',
      acquisitionCost: (json['acquisitionCost'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'Active',
      breed: json['breed'] as String?,
      colour: json['colour'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      livestockTypeName: type?['name'] as String?,
      healthRecords: (json['healthRecords'] as List? ?? const [])
          .map((e) => AnimalHealth.fromJson(e as Map<String, dynamic>))
          .toList(),
      productions: (json['productions'] as List? ?? const [])
          .map((e) => AnimalProduction.fromJson(e as Map<String, dynamic>))
          .toList(),
      weightRecords: (json['weightRecords'] as List? ?? const [])
          .map((e) => AnimalWeight.fromJson(e as Map<String, dynamic>))
          .toList(),
      expenses: (json['expenses'] as List? ?? const [])
          .map((e) => AnimalExpense.fromJson(e as Map<String, dynamic>))
          .toList(),
      sales: (json['sales'] as List? ?? const [])
          .map((e) => AnimalSale.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LivestockData {
  final List<LivestockType> types;
  final List<Animal> animals;

  const LivestockData({required this.types, required this.animals});

  factory LivestockData.fromJson(Map<String, dynamic> json) => LivestockData(
        types: (json['types'] as List? ?? const [])
            .map((e) => LivestockType.fromJson(e as Map<String, dynamic>))
            .toList(),
        animals: (json['animals'] as List? ?? const [])
            .map((e) => Animal.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
