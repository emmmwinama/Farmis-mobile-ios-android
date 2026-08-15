class InventorySale {
  final String id;
  final double quantitySold;
  final String unit;
  final double pricePerUnit;
  final double totalAmount;
  final String? buyerName;
  final DateTime saleDate;
  final String? notes;

  const InventorySale({
    required this.id,
    required this.quantitySold,
    required this.unit,
    required this.pricePerUnit,
    required this.totalAmount,
    this.buyerName,
    required this.saleDate,
    this.notes,
  });

  factory InventorySale.fromJson(Map<String, dynamic> json) => InventorySale(
        id: json['id'] as String,
        quantitySold: (json['quantitySold'] as num? ?? 0).toDouble(),
        unit: json['unit'] as String? ?? '',
        pricePerUnit: (json['pricePerUnit'] as num? ?? 0).toDouble(),
        totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
        buyerName: json['buyerName'] as String?,
        saleDate: DateTime.tryParse(json['saleDate'] as String? ?? '') ??
            DateTime.now(),
        notes: json['notes'] as String?,
      );
}

class InventoryItem {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double quantity;
  final double? acquisitionUnitCost;
  final DateTime? acquiredAt;
  final double? unitWeight;
  final String? season;
  final String? cropFieldId;
  final String? cropName;
  final String? fieldName;
  final String? notes;
  final double quantityKg;
  final bool lowStock;
  final double totalRevenue;
  final List<InventorySale> sales;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.quantity,
    this.acquisitionUnitCost,
    this.acquiredAt,
    this.unitWeight,
    this.season,
    this.cropFieldId,
    this.cropName,
    this.fieldName,
    this.notes,
    required this.quantityKg,
    required this.lowStock,
    required this.totalRevenue,
    this.sales = const [],
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Item',
        category: json['category'] as String? ?? '',
        unit: json['unit'] as String? ?? 'unit',
        quantity: (json['quantity'] as num? ?? 0).toDouble(),
        acquisitionUnitCost: (json['acquisitionUnitCost'] as num?)?.toDouble(),
        acquiredAt: json['acquiredAt'] != null
            ? DateTime.tryParse(json['acquiredAt'] as String)
            : null,
        unitWeight: (json['unitWeight'] as num?)?.toDouble(),
        season: json['season'] as String?,
        cropFieldId: json['cropFieldId'] as String?,
        cropName: json['cropName'] as String?,
        fieldName: json['fieldName'] as String?,
        notes: json['notes'] as String?,
        quantityKg: (json['quantityKg'] as num? ?? 0).toDouble(),
        lowStock: json['lowStock'] as bool? ?? false,
        totalRevenue: (json['totalRevenue'] as num? ?? 0).toDouble(),
        sales: (json['sales'] as List? ?? const [])
            .map((e) => InventorySale.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
