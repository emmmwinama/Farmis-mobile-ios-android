import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../models/livestock.dart';

const _eventKinds = ['health', 'production', 'weight', 'expense'];

/// Livestock lives on Ulimi's mobile API now (`/api/mobile/livestock/...`) —
/// same write-through pattern as the other ported entities, with two
/// backend-shaped quirks:
///  - Types have no default seed on a fresh farm server-side (the app used
///    to seed 6 defaults locally on first launch). `_pullTypes` pushes those
///    local defaults up via `storeType` the first time the server comes back
///    empty, so animal creation always references a real, server-known
///    `livestock_type_id`.
///  - There is no endpoint to list an animal's sale history (only
///    `POST .../sell`, which returns the updated animal, and the `events`
///    route explicitly excludes the `sale` kind) — sale records are kept
///    write-through/local-only, mirroring Inventory's `cropFieldId` gap.
class LivestockRepository {
  LivestockRepository(this._db, this._dio);

  final AppDatabase _db;
  final Dio _dio;

  Future<LivestockData> getLivestock() async {
    await _pullTypes();
    await _pullAnimals();

    final typeRows = await (_db.select(_db.livestockTypes)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    final animalRows = await (_db.select(_db.animals)
          ..orderBy([(t) => OrderingTerm.desc(t.id)]))
        .get();

    final animals = <Animal>[];
    for (final row in animalRows) {
      animals.add(await _hydrateAnimal(row, take: 5));
    }

    return LivestockData(
      types: typeRows.map((r) => LivestockType.fromJson(r.toJson())).toList(),
      animals: animals,
    );
  }

  Future<Animal> getAnimal(String id) async {
    await _pullTypes();
    await _pullOneAnimal(id);
    await _pullEvents(id);

    final row =
        await (_db.select(_db.animals)..where((t) => t.id.equals(id)))
            .getSingle();
    return _hydrateAnimal(row);
  }

  Future<Animal> _hydrateAnimal(AnimalRow row, {int? take}) async {
    final type = await (_db.select(_db.livestockTypes)
          ..where((t) => t.id.equals(row.livestockTypeId)))
        .getSingleOrNull();

    final healthQuery = _db.select(_db.animalHealthRecords)
      ..where((t) => t.animalId.equals(row.id))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    final productionQuery = _db.select(_db.animalProductionRecords)
      ..where((t) => t.animalId.equals(row.id))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    final weightQuery = _db.select(_db.animalWeightRecords)
      ..where((t) => t.animalId.equals(row.id))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    final expenseQuery = _db.select(_db.animalExpenseRecords)
      ..where((t) => t.animalId.equals(row.id))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    final saleQuery = _db.select(_db.animalSaleRecords)
      ..where((t) => t.animalId.equals(row.id))
      ..orderBy([(t) => OrderingTerm.desc(t.saleDate)]);
    if (take != null) {
      healthQuery.limit(take);
      productionQuery.limit(take);
      weightQuery.limit(take);
      expenseQuery.limit(take);
      saleQuery.limit(take);
    }

    final health = await healthQuery.get();
    final production = await productionQuery.get();
    final weight = await weightQuery.get();
    final expenses = await expenseQuery.get();
    final sales = await saleQuery.get();

    return Animal.fromJson({
      ...row.toJson(),
      'group': row.animalGroup,
      'livestockType': type != null ? {'name': type.name} : null,
      'healthRecords': health.map((r) => r.toJson()).toList(),
      'productions': production.map((r) => r.toJson()).toList(),
      'weightRecords': weight.map((r) => r.toJson()).toList(),
      'expenses': expenses.map((r) => r.toJson()).toList(),
      'sales': sales.map((r) => r.toJson()).toList(),
    });
  }

  /* ------------------------------------------------------------- types */

  Future<void> _pullTypes() async {
    try {
      final res = await _dio.get('/api/mobile/livestock/types');
      final rows =
          ((res.data as Map)['data'] as List).cast<Map<String, dynamic>>();
      if (rows.isEmpty) {
        await _pushLocalDefaultTypes();
        return;
      }
      for (final row in rows) {
        await _upsertType(row);
      }
    } catch (_) {
      // Offline or unreachable — fall back to whatever's cached locally.
    }
  }

  /// A fresh farm has no livestock types server-side. Push whatever's
  /// currently seeded locally (the app's onCreate defaults) up once, so
  /// animal creation references a real, server-known type id.
  Future<void> _pushLocalDefaultTypes() async {
    final localTypes = await _db.select(_db.livestockTypes).get();
    for (final t in localTypes) {
      try {
        final res = await _dio.post('/api/mobile/livestock/types', data: {
          'name': t.name,
          'category': t.category,
        });
        final serverRow = (res.data as Map)['data'] as Map<String, dynamic>;
        await (_db.delete(_db.livestockTypes)..where((x) => x.id.equals(t.id)))
            .go();
        await _upsertType(serverRow);
      } catch (_) {
        // Leave the local-only row in place; it'll retry on the next pull.
      }
    }
  }

  Future<void> _upsertType(Map<String, dynamic> row) async {
    await _db.into(_db.livestockTypes).insertOnConflictUpdate(
          LivestockTypesCompanion.insert(
            id: row['id'] as String,
            name: row['name'] as String,
            category: row['category'] as String? ?? '',
            icon: row['icon'] as String? ?? (row['name'] as String? ?? 'Cattle'),
          ),
        );
  }

  /* ----------------------------------------------------------- animals */

  Future<void> _pullAnimals() async {
    try {
      final res = await _dio.get('/api/mobile/livestock/animals');
      final rows =
          ((res.data as Map)['data'] as List).cast<Map<String, dynamic>>();
      for (final row in rows) {
        await _upsertAnimal(row);
      }
    } catch (_) {
      // Offline or unreachable — fall back to whatever's cached locally.
    }
  }

  Future<void> _pullOneAnimal(String id) async {
    try {
      final res = await _dio.get('/api/mobile/livestock/animals/$id');
      await _upsertAnimal((res.data as Map)['data'] as Map<String, dynamic>);
    } catch (_) {
      // Offline or unreachable — fall back to whatever's cached locally.
    }
  }

  Future<void> _upsertAnimal(Map<String, dynamic> row) async {
    await _db.into(_db.animals).insertOnConflictUpdate(
          AnimalsCompanion.insert(
            id: row['id'] as String,
            livestockTypeId: row['livestock_type_id'] as String,
            tag: Value(asStringOrNull(row['tag'])),
            name: Value(asStringOrNull(row['name'])),
            animalGroup: Value(asStringOrNull(row['animal_group'])),
            sex: row['sex'] as String? ?? 'Unknown',
            birthDate: Value(row['birth_date'] != null
                ? DateTime.tryParse(row['birth_date'] as String)
                : null),
            acquisitionDate:
                DateTime.tryParse(row['acquisition_date']?.toString() ?? '') ??
                    DateTime.now(),
            acquisitionType:
                row['acquisition_type'] as String? ?? 'Born on farm',
            acquisitionCost: Value(asDoubleOrNull(row['acquisition_cost'])),
            status: Value(row['status'] as String? ?? 'Active'),
            breed: Value(asStringOrNull(row['breed'])),
            colour: Value(asStringOrNull(row['colour'])),
            weight: Value(asDoubleOrNull(row['weight'])),
            notes: Value(asStringOrNull(row['notes'])),
          ),
        );
  }

  Map<String, dynamic> _animalApiBody(Map<String, dynamic> data) => {
        'livestock_type_id': data['livestockTypeId'],
        'tag': asStringOrNull(data['tag']),
        'name': asStringOrNull(data['name']),
        'animal_group': asStringOrNull(data['group']),
        'sex': asStringOrNull(data['sex']) ?? 'Unknown',
        'birth_date': data['birthDate'] != null
            ? (data['birthDate'] as String).split('T').first
            : null,
        'acquisition_date': data['acquisitionDate'] != null
            ? (data['acquisitionDate'] as String).split('T').first
            : DateTime.now().toIso8601String().split('T').first,
        'acquisition_type':
            asStringOrNull(data['acquisitionType']) ?? 'Born on farm',
        'acquisition_cost': asDoubleOrNull(data['acquisitionCost']),
        'status': asStringOrNull(data['status']) ?? 'Active',
        'breed': asStringOrNull(data['breed']),
        'colour': asStringOrNull(data['colour']),
        'weight': asDoubleOrNull(data['weight']),
        'notes': asStringOrNull(data['notes']),
      };

  Future<void> createAnimal(Map<String, dynamic> data) async {
    final res = await _dio.post('/api/mobile/livestock/animals',
        data: _animalApiBody(data));
    await _upsertAnimal((res.data as Map)['data'] as Map<String, dynamic>);
  }

  /// The API's `PUT` requires the full object (`livestock_type_id` included,
  /// even though it's immutable after create — the server just discards it
  /// there), so this merges onto the current local row first.
  Future<void> updateAnimal(String id, Map<String, dynamic> data) async {
    final current =
        await (_db.select(_db.animals)..where((t) => t.id.equals(id)))
            .getSingle();
    final merged = {
      'livestockTypeId': current.livestockTypeId,
      'tag': data.containsKey('tag') ? data['tag'] : current.tag,
      'name': data.containsKey('name') ? data['name'] : current.name,
      'group':
          data.containsKey('group') ? data['group'] : current.animalGroup,
      'sex': data['sex'] ?? current.sex,
      'birthDate': data.containsKey('birthDate')
          ? data['birthDate']
          : current.birthDate?.toIso8601String(),
      'acquisitionDate':
          data['acquisitionDate'] ?? current.acquisitionDate.toIso8601String(),
      'acquisitionType': data['acquisitionType'] ?? current.acquisitionType,
      'acquisitionCost': data.containsKey('acquisitionCost')
          ? data['acquisitionCost']
          : current.acquisitionCost,
      'status': data['status'] ?? current.status,
      'breed': data.containsKey('breed') ? data['breed'] : current.breed,
      'colour': data.containsKey('colour') ? data['colour'] : current.colour,
      'weight': data.containsKey('weight') ? data['weight'] : current.weight,
      'notes': data.containsKey('notes') ? data['notes'] : current.notes,
    };

    final res = await _dio.put('/api/mobile/livestock/animals/$id',
        data: _animalApiBody(merged));
    await _upsertAnimal((res.data as Map)['data'] as Map<String, dynamic>);
  }

  Future<void> deleteAnimal(String id) async {
    await _dio.post('/api/mobile/livestock/animals/$id/delete');
    await (_db.delete(_db.animals)..where((t) => t.id.equals(id))).go();
  }

  /* ------------------------------------------------------------- events */

  Future<void> _pullEvents(String animalId) async {
    for (final kind in _eventKinds) {
      try {
        final res = await _dio
            .get('/api/mobile/livestock/animals/$animalId/events/$kind');
        final rows =
            ((res.data as Map)['data'] as List).cast<Map<String, dynamic>>();
        for (final row in rows) {
          await _upsertEventFromApi(kind, animalId, row);
        }
      } catch (_) {
        // Offline or unreachable — fall back to whatever's cached locally.
      }
    }
  }

  /// Upserts one event row pulled from the API (snake_case fields).
  Future<void> _upsertEventFromApi(
      String kind, String animalId, Map<String, dynamic> row) async {
    switch (kind) {
      case 'health':
        await _db.into(_db.animalHealthRecords).insertOnConflictUpdate(
              AnimalHealthRecordsCompanion.insert(
                id: row['id'] as String,
                animalId: animalId,
                type: row['type'] as String,
                description: row['description'] as String,
                veterinarian: Value(asStringOrNull(row['veterinarian'])),
                cost: asDouble(row['cost']),
                date: DateTime.parse(row['date'] as String),
                nextDueDate: Value(row['next_due_date'] != null
                    ? DateTime.tryParse(row['next_due_date'] as String)
                    : null),
                notes: Value(asStringOrNull(row['notes'])),
              ),
            );
        return;
      case 'production':
        await _db.into(_db.animalProductionRecords).insertOnConflictUpdate(
              AnimalProductionRecordsCompanion.insert(
                id: row['id'] as String,
                animalId: animalId,
                type: row['type'] as String,
                quantity: asDouble(row['quantity']),
                unit: row['unit'] as String,
                date: DateTime.parse(row['date'] as String),
                pricePerUnit: Value(asDoubleOrNull(row['price_per_unit'])),
                totalValue: Value(asDoubleOrNull(row['total_value'])),
                notes: Value(asStringOrNull(row['notes'])),
              ),
            );
        return;
      case 'weight':
        await _db.into(_db.animalWeightRecords).insertOnConflictUpdate(
              AnimalWeightRecordsCompanion.insert(
                id: row['id'] as String,
                animalId: animalId,
                weight: asDouble(row['weight']),
                unit: row['unit'] as String? ?? 'kg',
                date: DateTime.parse(row['date'] as String),
                notes: Value(asStringOrNull(row['notes'])),
              ),
            );
        return;
      case 'expense':
        await _db.into(_db.animalExpenseRecords).insertOnConflictUpdate(
              AnimalExpenseRecordsCompanion.insert(
                id: row['id'] as String,
                animalId: Value(animalId),
                category: row['category'] as String,
                description: row['description'] as String,
                amount: asDouble(row['amount']),
                date: DateTime.parse(row['date'] as String),
                notes: Value(asStringOrNull(row['notes'])),
              ),
            );
        return;
    }
  }

  Future<void> addRecord(Map<String, dynamic> data) async {
    final recordType = data['recordType'] as String;
    final animalId = data['animalId'] as String;

    if (recordType == 'sale') {
      await _sellAnimal(animalId, data);
      return;
    }
    if (!_eventKinds.contains(recordType)) {
      throw ArgumentError('Unsupported livestock record type: $recordType');
    }

    final res = await _dio.post(
      '/api/mobile/livestock/animals/$animalId/events/$recordType',
      data: _eventApiBody(recordType, data),
    );
    final eventId = ((res.data as Map)['data'] as Map)['id'] as String;
    await _insertEventFromForm(recordType, animalId, eventId, data);

    if (recordType == 'weight') {
      await (_db.update(_db.animals)..where((t) => t.id.equals(animalId)))
          .write(AnimalsCompanion(weight: Value(asDouble(data['weight']))));
    }
  }

  Map<String, dynamic> _eventApiBody(String kind, Map<String, dynamic> data) {
    final date = (data['date'] as String).split('T').first;
    switch (kind) {
      case 'health':
        return {
          'type': data['type'],
          'description': data['description'],
          'veterinarian': asStringOrNull(data['veterinarian']),
          'cost': asDouble(data['cost']),
          'date': date,
          'next_due_date': data['nextDueDate'] != null
              ? (data['nextDueDate'] as String).split('T').first
              : null,
          'notes': asStringOrNull(data['notes']),
        };
      case 'production':
        return {
          'type': data['type'],
          'quantity': asDouble(data['quantity']),
          'unit': data['unit'],
          'date': date,
          'price_per_unit': asDoubleOrNull(data['pricePerUnit']),
          'notes': asStringOrNull(data['notes']),
        };
      case 'weight':
        return {
          'weight': asDouble(data['weight']),
          'unit': asStringOrNull(data['unit']) ?? 'kg',
          'date': date,
          'notes': asStringOrNull(data['notes']),
        };
      case 'expense':
        return {
          'category': data['category'],
          'description': data['description'],
          'amount': asDouble(data['amount']),
          'date': date,
          'notes': asStringOrNull(data['notes']),
        };
      default:
        throw ArgumentError('Unsupported livestock record type: $kind');
    }
  }

  /// Inserts a freshly-created event row locally (camelCase [data] from the
  /// record form, with the server-assigned [id]).
  Future<void> _insertEventFromForm(String recordType, String animalId,
      String id, Map<String, dynamic> data) async {
    switch (recordType) {
      case 'health':
        await _db.into(_db.animalHealthRecords).insert(
              AnimalHealthRecordsCompanion.insert(
                id: id,
                animalId: animalId,
                type: data['type'] as String,
                description: data['description'] as String,
                veterinarian: Value(asStringOrNull(data['veterinarian'])),
                cost: asDouble(data['cost']),
                date: DateTime.parse(data['date'] as String),
                nextDueDate: Value(data['nextDueDate'] != null
                    ? DateTime.parse(data['nextDueDate'] as String)
                    : null),
                notes: Value(asStringOrNull(data['notes'])),
              ),
            );
        return;
      case 'production':
        final quantity = asDouble(data['quantity']);
        final pricePerUnit = asDoubleOrNull(data['pricePerUnit']);
        await _db.into(_db.animalProductionRecords).insert(
              AnimalProductionRecordsCompanion.insert(
                id: id,
                animalId: animalId,
                type: data['type'] as String,
                quantity: quantity,
                unit: data['unit'] as String,
                date: DateTime.parse(data['date'] as String),
                pricePerUnit: Value(pricePerUnit),
                totalValue: Value(
                    pricePerUnit != null ? quantity * pricePerUnit : null),
                notes: Value(asStringOrNull(data['notes'])),
              ),
            );
        return;
      case 'weight':
        await _db.into(_db.animalWeightRecords).insert(
              AnimalWeightRecordsCompanion.insert(
                id: id,
                animalId: animalId,
                weight: asDouble(data['weight']),
                unit: asStringOrNull(data['unit']) ?? 'kg',
                date: DateTime.parse(data['date'] as String),
                notes: Value(asStringOrNull(data['notes'])),
              ),
            );
        return;
      case 'expense':
        await _db.into(_db.animalExpenseRecords).insert(
              AnimalExpenseRecordsCompanion.insert(
                id: id,
                animalId: Value(animalId),
                category: data['category'] as String,
                description: data['description'] as String,
                amount: asDouble(data['amount']),
                date: DateTime.parse(data['date'] as String),
                notes: Value(asStringOrNull(data['notes'])),
              ),
            );
        return;
    }
  }

  Future<void> deleteRecord(
      String recordType, String animalId, String id) async {
    if (recordType == 'sale') {
      // The server has no delete-sale endpoint — a recorded sale is
      // permanent, matching how the "Sales" section hides its delete
      // affordance in the UI.
      throw UnsupportedError('Sale records cannot be deleted.');
    }
    if (!_eventKinds.contains(recordType)) {
      throw ArgumentError('Unsupported livestock record type: $recordType');
    }

    await _dio.post(
        '/api/mobile/livestock/animals/$animalId/events/$recordType/$id/delete');

    switch (recordType) {
      case 'health':
        await (_db.delete(_db.animalHealthRecords)
              ..where((t) => t.id.equals(id)))
            .go();
        return;
      case 'production':
        await (_db.delete(_db.animalProductionRecords)
              ..where((t) => t.id.equals(id)))
            .go();
        return;
      case 'weight':
        await (_db.delete(_db.animalWeightRecords)
              ..where((t) => t.id.equals(id)))
            .go();
        return;
      case 'expense':
        await (_db.delete(_db.animalExpenseRecords)
              ..where((t) => t.id.equals(id)))
            .go();
        return;
    }
  }

  /* --------------------------------------------------------------- sale */

  /// The server books the sale AND a Finance transaction in one call, and
  /// returns only the updated animal — there's no sale-list endpoint (see
  /// class doc), so the sale record itself is mirrored locally, and (since
  /// Finance isn't API-ported yet — it stays local-first) so is the income
  /// transaction, matching what `sellAnimal` books server-side.
  Future<void> _sellAnimal(String animalId, Map<String, dynamic> data) async {
    final saleDateStr = data['saleDate'] as String;
    final totalAmount = asDouble(data['totalAmount']);
    final buyer = asStringOrNull(data['buyer']);

    final res = await _dio.post(
      '/api/mobile/livestock/animals/$animalId/sell',
      data: {
        'sale_date': saleDateStr.split('T').first,
        'total_amount': totalAmount,
        'quantity': asInt(data['quantity'], fallback: 1),
        'weight_at_sale': asDoubleOrNull(data['weightAtSale']),
        'price_per_kg': asDoubleOrNull(data['pricePerKg']),
        'buyer': buyer,
        'notes': asStringOrNull(data['notes']),
      },
    );
    await _upsertAnimal((res.data as Map)['data'] as Map<String, dynamic>);

    final animal = await (_db.select(_db.animals)
          ..where((t) => t.id.equals(animalId)))
        .getSingleOrNull();
    final type = animal != null
        ? await (_db.select(_db.livestockTypes)
              ..where((t) => t.id.equals(animal.livestockTypeId)))
            .getSingleOrNull()
        : null;
    final saleDate = DateTime.parse(saleDateStr);

    await _db.into(_db.animalSaleRecords).insert(
          AnimalSaleRecordsCompanion.insert(
            id: newId(),
            animalId: animalId,
            saleDate: saleDate,
            quantity: Value(asInt(data['quantity'], fallback: 1)),
            weightAtSale: Value(asDoubleOrNull(data['weightAtSale'])),
            pricePerKg: Value(asDoubleOrNull(data['pricePerKg'])),
            totalAmount: totalAmount,
            buyer: Value(buyer),
            notes: Value(asStringOrNull(data['notes'])),
          ),
        );

    await _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            id: newId(),
            type: 'Income',
            category: 'Livestock sales',
            amount: totalAmount,
            date: saleDate,
            description:
                'Sale of ${type?.name ?? 'animal'}${buyer != null ? ' to $buyer' : ''}',
          ),
        );
  }
}
