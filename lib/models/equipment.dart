const kEquipmentCategories = ['tractor', 'irrigation', 'tool', 'vehicle', 'other'];
const kEquipmentStatuses = ['active', 'under_repair', 'retired'];

String equipmentCategoryLabel(String category) => switch (category) {
      'tractor' => 'Tractor',
      'irrigation' => 'Irrigation',
      'tool' => 'Tool',
      'vehicle' => 'Vehicle',
      _ => 'Other',
    };

String equipmentStatusLabel(String status) => switch (status) {
      'under_repair' => 'Under repair',
      'retired' => 'Retired',
      _ => 'Active',
    };

class EquipmentModel {
  final String id;
  final String name;
  final String category;
  final String status;
  final DateTime? acquisitionDate;
  final double? acquisitionCost;
  final String? notes;
  final int logCount;
  final double maintenanceCost;

  const EquipmentModel({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    this.acquisitionDate,
    this.acquisitionCost,
    this.notes,
    this.logCount = 0,
    this.maintenanceCost = 0,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) => EquipmentModel(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Equipment',
        category: json['category'] as String? ?? 'other',
        status: json['status'] as String? ?? 'active',
        acquisitionDate: json['acquisitionDate'] != null
            ? DateTime.tryParse(json['acquisitionDate'] as String)
            : null,
        acquisitionCost: (json['acquisitionCost'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
        logCount: (json['logCount'] as num? ?? 0).toInt(),
        maintenanceCost: (json['maintenanceCost'] as num? ?? 0).toDouble(),
      );
}

class EquipmentMaintenanceLog {
  final String id;
  final DateTime date;
  final String description;
  final double cost;
  final double? hoursUsed;
  final String? notes;

  const EquipmentMaintenanceLog({
    required this.id,
    required this.date,
    required this.description,
    required this.cost,
    this.hoursUsed,
    this.notes,
  });

  factory EquipmentMaintenanceLog.fromJson(Map<String, dynamic> json) =>
      EquipmentMaintenanceLog(
        id: json['id'] as String,
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        description: json['description'] as String? ?? '',
        cost: (json['cost'] as num? ?? 0).toDouble(),
        hoursUsed: (json['hoursUsed'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
      );
}
