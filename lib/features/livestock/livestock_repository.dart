import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../models/livestock.dart';

class LivestockRepository {
  LivestockRepository(this._db);

  final AppDatabase _db;

  Future<LivestockData> getLivestock() async {
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

  Future<void> createAnimal(Map<String, dynamic> data) async {
    await _db.into(_db.animals).insert(AnimalsCompanion.insert(
          id: newId(),
          livestockTypeId: data['livestockTypeId'] as String,
          tag: Value(asStringOrNull(data['tag'])),
          name: Value(asStringOrNull(data['name'])),
          animalGroup: Value(asStringOrNull(data['group'])),
          sex: asStringOrNull(data['sex']) ?? 'Unknown',
          birthDate: Value(data['birthDate'] != null
              ? DateTime.parse(data['birthDate'] as String)
              : null),
          acquisitionDate: data['acquisitionDate'] != null
              ? DateTime.parse(data['acquisitionDate'] as String)
              : DateTime.now(),
          acquisitionType:
              asStringOrNull(data['acquisitionType']) ?? 'Born on farm',
          acquisitionCost: Value(asDoubleOrNull(data['acquisitionCost'])),
          breed: Value(asStringOrNull(data['breed'])),
          colour: Value(asStringOrNull(data['colour'])),
          weight: Value(asDoubleOrNull(data['weight'])),
          notes: Value(asStringOrNull(data['notes'])),
        ));
  }

  Future<void> updateAnimal(String id, Map<String, dynamic> data) async {
    await (_db.update(_db.animals)..where((t) => t.id.equals(id))).write(
      AnimalsCompanion(
        livestockTypeId: data['livestockTypeId'] != null
            ? Value(data['livestockTypeId'] as String)
            : const Value.absent(),
        tag: data.containsKey('tag')
            ? Value(asStringOrNull(data['tag']))
            : const Value.absent(),
        name: data.containsKey('name')
            ? Value(asStringOrNull(data['name']))
            : const Value.absent(),
        animalGroup: data.containsKey('group')
            ? Value(asStringOrNull(data['group']))
            : const Value.absent(),
        sex: data['sex'] != null
            ? Value(data['sex'] as String)
            : const Value.absent(),
        birthDate: data.containsKey('birthDate')
            ? Value(data['birthDate'] != null
                ? DateTime.parse(data['birthDate'] as String)
                : null)
            : const Value.absent(),
        acquisitionDate: data['acquisitionDate'] != null
            ? Value(DateTime.parse(data['acquisitionDate'] as String))
            : const Value.absent(),
        acquisitionType: data['acquisitionType'] != null
            ? Value(data['acquisitionType'] as String)
            : const Value.absent(),
        acquisitionCost: data.containsKey('acquisitionCost')
            ? Value(asDoubleOrNull(data['acquisitionCost']))
            : const Value.absent(),
        status: data['status'] != null
            ? Value(data['status'] as String)
            : const Value.absent(),
        breed: data.containsKey('breed')
            ? Value(asStringOrNull(data['breed']))
            : const Value.absent(),
        colour: data.containsKey('colour')
            ? Value(asStringOrNull(data['colour']))
            : const Value.absent(),
        weight: data.containsKey('weight')
            ? Value(asDoubleOrNull(data['weight']))
            : const Value.absent(),
        notes: data.containsKey('notes')
            ? Value(asStringOrNull(data['notes']))
            : const Value.absent(),
      ),
    );
  }

  Future<void> deleteAnimal(String id) async {
    await (_db.delete(_db.animals)..where((t) => t.id.equals(id))).go();
  }

  Future<void> addRecord(Map<String, dynamic> data) async {
    final recordType = data['recordType'] as String;
    final animalId = data['animalId'] as String;

    switch (recordType) {
      case 'health':
        await _db.into(_db.animalHealthRecords).insert(
              AnimalHealthRecordsCompanion.insert(
                id: newId(),
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
        await _db.into(_db.animalProductionRecords).insert(
              AnimalProductionRecordsCompanion.insert(
                id: newId(),
                animalId: animalId,
                type: data['type'] as String,
                quantity: asDouble(data['quantity']),
                unit: data['unit'] as String,
                date: DateTime.parse(data['date'] as String),
                pricePerUnit: Value(asDoubleOrNull(data['pricePerUnit'])),
                totalValue: Value(asDoubleOrNull(data['totalValue'])),
                notes: Value(asStringOrNull(data['notes'])),
              ),
            );
        return;
      case 'weight':
        await _db.into(_db.animalWeightRecords).insert(
              AnimalWeightRecordsCompanion.insert(
                id: newId(),
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
                id: newId(),
                animalId: Value(animalId),
                category: data['category'] as String,
                description: data['description'] as String,
                amount: asDouble(data['amount']),
                date: DateTime.parse(data['date'] as String),
                notes: Value(asStringOrNull(data['notes'])),
              ),
            );
        return;
      case 'sale':
        final animal = await (_db.select(_db.animals)
              ..where((t) => t.id.equals(animalId)))
            .getSingle();
        final type = await (_db.select(_db.livestockTypes)
              ..where((t) => t.id.equals(animal.livestockTypeId)))
            .getSingleOrNull();
        final totalAmount = asDouble(data['totalAmount']);
        final saleDate = DateTime.parse(data['saleDate'] as String);
        final buyer = asStringOrNull(data['buyer']);

        await _db.transaction(() async {
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
        });
        return;
      default:
        throw ArgumentError('Unsupported livestock record type: $recordType');
    }
  }

  Future<void> deleteRecord(String recordType, String id) async {
    switch (recordType) {
      case 'health':
        await (_db.delete(_db.animalHealthRecords)..where((t) => t.id.equals(id))).go();
        return;
      case 'production':
        await (_db.delete(_db.animalProductionRecords)..where((t) => t.id.equals(id))).go();
        return;
      case 'weight':
        await (_db.delete(_db.animalWeightRecords)..where((t) => t.id.equals(id))).go();
        return;
      case 'expense':
        await (_db.delete(_db.animalExpenseRecords)..where((t) => t.id.equals(id))).go();
        return;
      case 'sale':
        await (_db.delete(_db.animalSaleRecords)..where((t) => t.id.equals(id))).go();
        return;
      default:
        throw ArgumentError('Unsupported livestock record type: $recordType');
    }
  }
}
