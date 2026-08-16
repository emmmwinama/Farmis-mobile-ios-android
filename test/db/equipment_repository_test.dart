import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/equipment/equipment_repository.dart';
import 'package:farmio_mobile/features/inventory/inventory_repository.dart';

void main() {
  late AppDatabase db;
  late EquipmentRepository repo;
  late InventoryRepository inventory;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = EquipmentRepository(db);
    inventory = InventoryRepository(db);
  });

  tearDown(() async => db.close());

  test('addEquipment then getEquipment lists it under equipment', () async {
    await repo.addEquipment({'name': 'Tractor', 'unit': 'unit'});

    final data = await repo.getEquipment();
    expect(data.equipment, hasLength(1));
    expect(data.equipment.first.name, 'Tractor');
  });

  test('getEquipment does not include non-equipment inventory items', () async {
    await inventory.createItem({
      'name': 'Maize seed',
      'category': 'Seed',
      'unit': 'bags',
      'quantity': '10',
    });
    await repo.addEquipment({'name': 'Plough', 'unit': 'unit'});

    final data = await repo.getEquipment();
    expect(data.equipment, hasLength(1));
    expect(data.equipment.first.name, 'Plough');
  });

  test('addCost then getEquipment lists it under costs, filtered by category',
      () async {
    await repo.addCost({
      'description': 'Diesel refill',
      'category': 'Fuel',
      'amount': '25000',
      'date': DateTime(2026, 3, 1).toIso8601String(),
    });
    await repo.addCost({
      'description': 'Unrelated overhead',
      'category': 'Rent',
      'amount': '10000',
      'date': DateTime(2026, 3, 1).toIso8601String(),
    });

    final data = await repo.getEquipment();
    expect(data.costs, hasLength(1));
    expect(data.costs.first.description, 'Diesel refill');
  });
}
