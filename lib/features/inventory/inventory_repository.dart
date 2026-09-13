import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../models/inventory_item.dart';

/// Inventory items live on Ulimi's mobile API now (`/api/mobile/inventory`)
/// — same write-through pattern as FieldsRepository. Sales stay entirely
/// local for now: the API's `/inventory/{id}/sell` bundles a stock
/// decrement + an auto-created Income transaction server-side, but Finance
/// (transactions) hasn't been ported yet — pushing sales through it now
/// would create the transaction server-side while the still-local-only
/// Finance screen never learns about it. Revisit once transactions are
/// ported too.
///
/// One real limitation inherited from the API: create doesn't accept
/// `crop_field_id`/`harvest_yield_id` at all (not in its validated payload),
/// so a brand-new item's harvest link only exists locally until the API
/// grows that field. Existing links survive edits fine — the API's update
/// only ever touches the columns it validates, so it never nulls those out.
class InventoryRepository {
  InventoryRepository(this._db, this._dio);

  final AppDatabase _db;
  final Dio _dio;

  Future<List<InventoryItem>> getItems({String? category}) async {
    await _pullFromApi();
    return getItemsLocalOnly(category: category);
  }

  /// Same as [getItems] but skips the network pull — for background/local
  /// computations (see NotificationsRepository's low-stock scan) that run
  /// frequently and shouldn't force a round-trip just to check quantities
  /// against whatever's already cached.
  Future<List<InventoryItem>> getItemsLocalOnly({String? category}) async {
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

  Future<void> _pullFromApi() async {
    try {
      final res = await _dio.get('/api/mobile/inventory');
      final rows = ((res.data as Map)['data'] as List).cast<Map<String, dynamic>>();
      for (final row in rows) {
        await _upsertFromApi(row);
      }
    } catch (_) {
      // Offline or unreachable — fall back to whatever's cached locally.
    }
  }

  Future<void> _upsertFromApi(Map<String, dynamic> row) async {
    await _db.into(_db.inventoryItems).insertOnConflictUpdate(InventoryItemsCompanion.insert(
          id: row['id'] as String,
          name: row['name'] as String,
          category: row['category'] as String,
          unit: row['unit'] as String,
          quantity: asDouble(row['quantity']),
          acquisitionUnitCost: Value(asDoubleOrNull(row['acquisition_unit_cost'])),
          acquiredAt: Value(row['acquired_at'] != null ? DateTime.tryParse(row['acquired_at'].toString()) : null),
          unitWeight: Value(asDoubleOrNull(row['unit_weight'])),
          season: Value(asStringOrNull(row['season'])),
          // The API doesn't manage crop_field_id at all (never part of its
          // validated create/update payload, always null in a real create
          // response) — omitting it here (rather than writing whatever the
          // API says) means a fresh local row defaults to no link, and an
          // existing local link survives every future sync untouched.
          notes: Value(asStringOrNull(row['notes'])),
        ));
  }

  Map<String, dynamic> _apiBody(Map<String, dynamic> data) => {
        'name': data['name'],
        'category': data['category'],
        'unit': data['unit'],
        'quantity': asDouble(data['quantity']),
        'acquisition_unit_cost': asDoubleOrNull(data['acquisitionUnitCost']),
        'acquired_at': data['acquiredAt'] != null ? (data['acquiredAt'] as String).split('T').first : null,
        'unit_weight': asDoubleOrNull(data['unitWeight']),
        'season': asStringOrNull(data['season']),
        'notes': asStringOrNull(data['notes']),
      };

  /// Adding stock for a name/category/unit/season/crop-field combination
  /// that already exists locally increments that row instead of creating a
  /// duplicate — same dedup the local-only version always did, just routed
  /// through an API update instead of a bare local write when a match exists.
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
      final merged = {
        'name': existing.name,
        'category': existing.category,
        'unit': existing.unit,
        'quantity': existing.quantity + quantity,
        'acquisitionUnitCost':
            data['acquisitionUnitCost'] ?? existing.acquisitionUnitCost,
        'acquiredAt': data['acquiredAt'] ?? existing.acquiredAt?.toIso8601String(),
        'unitWeight': data['unitWeight'] ?? existing.unitWeight,
        'season': existing.season,
        'notes': asStringOrNull(data['notes']) != null
            ? '${existing.notes ?? ''}\nPurchase/addition: ${data['notes']}'.trim()
            : existing.notes,
      };
      final res = await _dio.put('/api/mobile/inventory/${existing.id}', data: _apiBody(merged));
      await _upsertFromApi((res.data as Map)['data'] as Map<String, dynamic>);
      return;
    }

    final res = await _dio.post('/api/mobile/inventory', data: _apiBody(data));
    final row = (res.data as Map)['data'] as Map<String, dynamic>;
    await _upsertFromApi(row);
    if (cropFieldId != null) {
      await (_db.update(_db.inventoryItems)..where((t) => t.id.equals(row['id'] as String)))
          .write(InventoryItemsCompanion(cropFieldId: Value(cropFieldId)));
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    final current =
        await (_db.select(_db.inventoryItems)..where((t) => t.id.equals(id))).getSingle();
    final merged = {
      'name': data['name'] ?? current.name,
      'category': data['category'] ?? current.category,
      'unit': data['unit'] ?? current.unit,
      'quantity': data['quantity'] ?? current.quantity,
      'acquisitionUnitCost': data.containsKey('acquisitionUnitCost')
          ? data['acquisitionUnitCost']
          : current.acquisitionUnitCost,
      'acquiredAt': data.containsKey('acquiredAt')
          ? data['acquiredAt']
          : current.acquiredAt?.toIso8601String(),
      'unitWeight': data.containsKey('unitWeight') ? data['unitWeight'] : current.unitWeight,
      'season': data.containsKey('season') ? data['season'] : current.season,
      'notes': data.containsKey('notes') ? data['notes'] : current.notes,
    };

    final res = await _dio.put('/api/mobile/inventory/$id', data: _apiBody(merged));
    await _upsertFromApi((res.data as Map)['data'] as Map<String, dynamic>);
  }

  Future<void> deleteItem(String id) async {
    await _dio.post('/api/mobile/inventory/$id/delete');
    await (_db.delete(_db.inventoryItems)..where((t) => t.id.equals(id))).go();
  }

  Future<void> createSale(Map<String, dynamic> data) async {
    final itemId = data['inventoryItemId'] as String;
    final sold = asDouble(data['quantitySold']);
    final pricePerUnit = asDouble(data['pricePerUnit']);
    final totalAmount = sold * pricePerUnit;
    final saleDate = DateTime.parse(data['saleDate'] as String);
    final buyerName = asStringOrNull(data['buyerName']);
    late double remainingQuantity;

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

      remainingQuantity = item.quantity - sold;
      await (_db.update(_db.inventoryItems)..where((t) => t.id.equals(itemId)))
          .write(InventoryItemsCompanion(
        quantity: Value(remainingQuantity),
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

    // The server has no idea this sale happened (see the class doc comment
    // — sales stay local until Finance is ported too), so its cached
    // quantity is now stale. Push the new quantity so the next getItems()
    // pull-down doesn't stomp this decrement back to the pre-sale value.
    // Best-effort: the sale itself already committed locally either way.
    try {
      await updateItem(itemId, {'quantity': remainingQuantity});
    } catch (_) {}
  }

  double _quantityKg(String unit, double quantity, double? unitWeight) {
    final normalized = unit.toLowerCase();
    if (normalized == 'kg') return quantity;
    if (normalized == 'tonnes' || normalized == 'tonne') return quantity * 1000;
    return unitWeight != null ? quantity * unitWeight : quantity;
  }
}
