import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../models/inventory_item.dart';

class InventoryRepository {
  InventoryRepository(this._db);

  final AppDatabase _db;

  Future<List<InventoryItem>> getItems({String? category}) async {
    final query = _db.select(_db.inventoryItems)
      ..orderBy([(t) => OrderingTerm.desc(t.acquiredAt)]);
    if (category != null) query.where((t) => t.category.equals(category));
    final rows = await query.get();

    final items = <InventoryItem>[];
    for (final row in rows) {
      String? cropName, fieldName;
      final cropFieldId = row.cropFieldId;
      if (cropFieldId != null) {
        final crop = await (_db.select(_db.cropFields)
              ..where((t) => t.id.equals(cropFieldId)))
            .getSingleOrNull();
        if (crop != null) {
          final cropType = await (_db.select(_db.cropTypes)
                ..where((t) => t.id.equals(crop.cropTypeId)))
              .getSingleOrNull();
          cropName = cropType?.name;
          final field = await (_db.select(_db.fields)
                ..where((t) => t.id.equals(crop.fieldId)))
              .getSingleOrNull();
          fieldName = field?.name;
        }
      }

      final sales = await (_db.select(_db.inventorySales)
            ..where((t) => t.inventoryItemId.equals(row.id))
            ..orderBy([(t) => OrderingTerm.desc(t.saleDate)]))
          .get();
      final totalRevenue =
          sales.fold<double>(0, (s, sale) => s + sale.totalAmount);

      items.add(InventoryItem.fromJson({
        ...row.toJson(),
        'cropName': cropName,
        'fieldName': fieldName,
        'quantityKg': _quantityKg(row.unit, row.quantity, row.unitWeight),
        'lowStock': row.quantity <= 5,
        'totalRevenue': totalRevenue,
        'sales': sales.map((s) => s.toJson()).toList(),
      }));
    }
    return items;
  }

  Future<void> createItem(Map<String, dynamic> data) async {
    final name = (data['name'] as String).trim();
    final category = data['category'] as String;
    final unit = data['unit'] as String;
    final season = asStringOrNull(data['season']);
    final cropFieldId = asStringOrNull(data['cropFieldId']);
    final quantity = asDouble(data['quantity']);

    final existing = await (_db.select(_db.inventoryItems)
          ..where((t) =>
              t.name.equals(name) &
              t.category.equals(category) &
              t.unit.equals(unit) &
              (season == null ? t.season.isNull() : t.season.equals(season)) &
              (cropFieldId == null
                  ? t.cropFieldId.isNull()
                  : t.cropFieldId.equals(cropFieldId))))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.inventoryItems)
            ..where((t) => t.id.equals(existing.id)))
          .write(InventoryItemsCompanion(
        quantity: Value(existing.quantity + quantity),
        acquisitionUnitCost: data['acquisitionUnitCost'] != null
            ? Value(asDoubleOrNull(data['acquisitionUnitCost']))
            : Value(existing.acquisitionUnitCost),
        acquiredAt: data['acquiredAt'] != null
            ? Value(DateTime.parse(data['acquiredAt'] as String))
            : Value(existing.acquiredAt),
        unitWeight: data['unitWeight'] != null
            ? Value(asDoubleOrNull(data['unitWeight']))
            : Value(existing.unitWeight),
        notes: Value(asStringOrNull(data['notes']) != null
            ? '${existing.notes ?? ''}\nPurchase/addition: ${data['notes']}'
                .trim()
            : existing.notes),
      ));
      return;
    }

    await _db.into(_db.inventoryItems).insert(InventoryItemsCompanion.insert(
          id: newId(),
          name: name,
          category: category,
          unit: unit,
          quantity: quantity,
          acquisitionUnitCost: Value(asDoubleOrNull(data['acquisitionUnitCost'])),
          acquiredAt: Value(data['acquiredAt'] != null
              ? DateTime.parse(data['acquiredAt'] as String)
              : null),
          unitWeight: Value(asDoubleOrNull(data['unitWeight'])),
          season: Value(season),
          cropFieldId: Value(cropFieldId),
          notes: Value(asStringOrNull(data['notes'])),
        ));
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    await (_db.update(_db.inventoryItems)..where((t) => t.id.equals(id)))
        .write(InventoryItemsCompanion(
      name: data['name'] != null ? Value(data['name'] as String) : const Value.absent(),
      category: data['category'] != null
          ? Value(data['category'] as String)
          : const Value.absent(),
      unit: data['unit'] != null ? Value(data['unit'] as String) : const Value.absent(),
      quantity: data['quantity'] != null
          ? Value(asDouble(data['quantity']))
          : const Value.absent(),
      acquisitionUnitCost: data.containsKey('acquisitionUnitCost')
          ? Value(asDoubleOrNull(data['acquisitionUnitCost']))
          : const Value.absent(),
      acquiredAt: data.containsKey('acquiredAt')
          ? Value(data['acquiredAt'] != null
              ? DateTime.parse(data['acquiredAt'] as String)
              : null)
          : const Value.absent(),
      unitWeight: data.containsKey('unitWeight')
          ? Value(asDoubleOrNull(data['unitWeight']))
          : const Value.absent(),
      season: data.containsKey('season')
          ? Value(asStringOrNull(data['season']))
          : const Value.absent(),
      cropFieldId: data.containsKey('cropFieldId')
          ? Value(asStringOrNull(data['cropFieldId']))
          : const Value.absent(),
      notes: data.containsKey('notes')
          ? Value(asStringOrNull(data['notes']))
          : const Value.absent(),
    ));
  }

  Future<void> deleteItem(String id) async {
    await (_db.delete(_db.inventoryItems)..where((t) => t.id.equals(id))).go();
  }

  Future<void> createSale(Map<String, dynamic> data) async {
    final itemId = data['inventoryItemId'] as String;
    final sold = asDouble(data['quantitySold']);
    final pricePerUnit = asDouble(data['pricePerUnit']);
    final totalAmount = sold * pricePerUnit;
    final saleDate = DateTime.parse(data['saleDate'] as String);
    final buyerName = asStringOrNull(data['buyerName']);

    await _db.transaction(() async {
      final item = await (_db.select(_db.inventoryItems)
            ..where((t) => t.id.equals(itemId)))
          .getSingle();

      await _db.into(_db.inventorySales).insert(InventorySalesCompanion.insert(
            id: newId(),
            inventoryItemId: itemId,
            quantitySold: sold,
            unit: asStringOrNull(data['unit']) ?? item.unit,
            pricePerUnit: pricePerUnit,
            totalAmount: totalAmount,
            buyerName: Value(buyerName),
            saleDate: saleDate,
            notes: Value(asStringOrNull(data['notes'])),
          ));

      await (_db.update(_db.inventoryItems)..where((t) => t.id.equals(itemId)))
          .write(InventoryItemsCompanion(
        quantity: Value(item.quantity - sold),
      ));

      if (data['createFinanceRecord'] != false) {
        await _db.into(_db.transactions).insert(TransactionsCompanion.insert(
              id: newId(),
              type: 'Income',
              category: 'Crop sales',
              amount: totalAmount,
              date: saleDate,
              description:
                  'Sale of ${item.name}${buyerName != null ? ' to $buyerName' : ''}',
              season: Value(item.season),
              cropFieldId: Value(item.cropFieldId),
            ));
      }
    });
  }

  double _quantityKg(String unit, double quantity, double? unitWeight) {
    final normalized = unit.toLowerCase();
    if (normalized == 'kg') return quantity;
    if (normalized == 'tonnes' || normalized == 'tonne') return quantity * 1000;
    return unitWeight != null ? quantity * unitWeight : quantity;
  }
}
