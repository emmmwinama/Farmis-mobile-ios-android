import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../models/equipment_item.dart';
import '../../models/overhead.dart';

const _costCategories = ['Fuel', 'Maintenance', 'Machinery'];

class EquipmentData {
  final List<EquipmentItem> equipment;
  final List<OverheadExpense> costs;

  const EquipmentData({required this.equipment, required this.costs});
}

class EquipmentRepository {
  EquipmentRepository(this._db);

  final AppDatabase _db;

  Future<EquipmentData> getEquipment() async {
    final equipmentRows = await (_db.select(_db.inventoryItems)
          ..where((t) => t.category.equals('equipment')))
        .get();
    final costRows = await (_db.select(_db.overheadExpenses)
          ..where((t) => t.category.isIn(_costCategories))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();

    return EquipmentData(
      equipment: equipmentRows
          .map((r) => EquipmentItem.fromJson(r.toJson()))
          .toList(),
      costs: costRows.map((r) => OverheadExpense.fromJson(r.toJson())).toList(),
    );
  }

  Future<void> addEquipment(Map<String, dynamic> data) async {
    await _db.into(_db.inventoryItems).insert(InventoryItemsCompanion.insert(
          id: newId(),
          name: data['name'] as String,
          category: 'equipment',
          unit: asStringOrNull(data['unit']) ?? 'unit',
          quantity: data['quantity'] != null ? asDouble(data['quantity']) : 1,
          notes: Value(asStringOrNull(data['notes'])),
        ));
  }

  Future<void> addCost(Map<String, dynamic> data) async {
    await _db.into(_db.overheadExpenses).insert(
          OverheadExpensesCompanion.insert(
            id: newId(),
            description: data['description'] as String,
            category: asStringOrNull(data['category']) ?? 'Machinery',
            amount: asDouble(data['amount']),
            date: DateTime.parse(data['date'] as String),
            recurring: const Value(false),
            notes: Value(asStringOrNull(data['notes'])),
          ),
        );
  }
}
