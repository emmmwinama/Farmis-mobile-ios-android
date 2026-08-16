import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/inventory/inventory_repository.dart';
import 'package:farmio_mobile/features/finance/finance_repository.dart';

void main() {
  late AppDatabase db;
  late InventoryRepository repo;
  late FinanceRepository finance;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = InventoryRepository(db);
    finance = FinanceRepository(db);
  });

  tearDown(() async => db.close());

  test('createItem then getItems computes quantityKg and lowStock', () async {
    await repo.createItem({
      'name': 'Maize seed',
      'category': 'Seed',
      'unit': 'bags',
      'quantity': '10',
      'unitWeight': '50',
    });

    final items = await repo.getItems();
    expect(items, hasLength(1));
    expect(items.first.quantityKg, 500);
    expect(items.first.lowStock, isFalse);
  });

  test('createItem merges into an existing matching item instead of duplicating',
      () async {
    await repo.createItem({
      'name': 'Fertiliser',
      'category': 'Input',
      'unit': 'kg',
      'quantity': '20',
    });
    await repo.createItem({
      'name': 'Fertiliser',
      'category': 'Input',
      'unit': 'kg',
      'quantity': '5',
    });

    final items = await repo.getItems();
    expect(items, hasLength(1));
    expect(items.first.quantity, 25);
  });

  test('lowStock is true at or below 5 units', () async {
    await repo.createItem({
      'name': 'Diesel',
      'category': 'Fuel',
      'unit': 'litres',
      'quantity': '5',
    });

    final items = await repo.getItems();
    expect(items.first.lowStock, isTrue);
  });

  test('createSale deducts stock and records revenue and a finance transaction',
      () async {
    await repo.createItem({
      'name': 'Maize grain',
      'category': 'Produce',
      'unit': 'kg',
      'quantity': '500',
    });
    final itemId = (await repo.getItems()).first.id;

    await repo.createSale({
      'inventoryItemId': itemId,
      'quantitySold': '100',
      'pricePerUnit': '300',
      'saleDate': DateTime(2026, 5, 1).toIso8601String(),
      'buyerName': 'ADMARC',
    });

    final items = await repo.getItems();
    expect(items.first.quantity, 400);
    expect(items.first.totalRevenue, 30000);
    expect(items.first.sales, hasLength(1));

    final financeData = await finance.getTransactions();
    expect(financeData.transactions, hasLength(1));
    expect(financeData.transactions.first.amount, 30000);
    expect(financeData.transactions.first.type, 'Income');
  });

  test('deleteItem removes the row', () async {
    await repo.createItem({
      'name': 'Old stock',
      'category': 'Seed',
      'unit': 'kg',
      'quantity': '10',
    });
    final itemId = (await repo.getItems()).first.id;

    await repo.deleteItem(itemId);

    expect(await repo.getItems(), isEmpty);
  });
}
