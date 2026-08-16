import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/livestock/livestock_repository.dart';
import 'package:farmio_mobile/features/finance/finance_repository.dart';

void main() {
  late AppDatabase db;
  late LivestockRepository repo;
  late FinanceRepository finance;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = LivestockRepository(db);
    finance = FinanceRepository(db);
  });

  tearDown(() async => db.close());

  test('fresh database ships with a starter set of livestock types', () async {
    final data = await repo.getLivestock();
    expect(data.types, isNotEmpty);
    expect(data.types.map((t) => t.name), contains('Cattle'));
  });

  test('createAnimal then getLivestock resolves the livestock type name',
      () async {
    final typeId = (await repo.getLivestock()).types.first.id;

    await repo.createAnimal({
      'livestockTypeId': typeId,
      'tag': 'A-001',
      'sex': 'Female',
    });

    final data = await repo.getLivestock();
    expect(data.animals, hasLength(1));
    expect(data.animals.first.livestockTypeName, isNotNull);
    expect(data.animals.first.tag, 'A-001');
  });

  test('addRecord(health) then getAnimal includes it in health records',
      () async {
    final typeId = (await repo.getLivestock()).types.first.id;
    await repo.createAnimal({'livestockTypeId': typeId, 'sex': 'Male'});
    final animalId = (await repo.getLivestock()).animals.first.id;

    await repo.addRecord({
      'recordType': 'health',
      'animalId': animalId,
      'type': 'Vaccination',
      'description': 'Foot and mouth vaccine',
      'cost': '5000',
      'date': DateTime(2026, 2, 1).toIso8601String(),
    });

    final animal = await repo.getAnimal(animalId);
    expect(animal.healthRecords, hasLength(1));
    expect(animal.healthRecords.first.cost, 5000);
  });

  test('addRecord(sale) deducts nothing from herd but records revenue and a finance transaction',
      () async {
    final typeId = (await repo.getLivestock()).types.first.id;
    await repo.createAnimal({'livestockTypeId': typeId, 'sex': 'Male'});
    final animalId = (await repo.getLivestock()).animals.first.id;

    await repo.addRecord({
      'recordType': 'sale',
      'animalId': animalId,
      'saleDate': DateTime(2026, 3, 1).toIso8601String(),
      'quantity': '1',
      'totalAmount': '80000',
      'buyer': 'Local market',
    });

    final animal = await repo.getAnimal(animalId);
    expect(animal.sales, hasLength(1));
    expect(animal.sales.first.totalAmount, 80000);

    final financeData = await finance.getTransactions();
    expect(financeData.transactions, hasLength(1));
    expect(financeData.transactions.first.category, 'Livestock sales');
    expect(financeData.transactions.first.amount, 80000);
  });

  test('deleteAnimal removes the row', () async {
    final typeId = (await repo.getLivestock()).types.first.id;
    await repo.createAnimal({'livestockTypeId': typeId, 'sex': 'Male'});
    final animalId = (await repo.getLivestock()).animals.first.id;

    await repo.deleteAnimal(animalId);

    expect((await repo.getLivestock()).animals, isEmpty);
  });
}
