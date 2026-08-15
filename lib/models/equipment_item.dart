class EquipmentItem {
  final String id;
  final String name;
  final String unit;
  final double quantity;
  final String? notes;

  const EquipmentItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
    this.notes,
  });

  factory EquipmentItem.fromJson(Map<String, dynamic> json) => EquipmentItem(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Equipment',
        unit: json['unit'] as String? ?? 'unit',
        quantity: (json['quantity'] as num? ?? 0).toDouble(),
        notes: json['notes'] as String?,
      );
}
