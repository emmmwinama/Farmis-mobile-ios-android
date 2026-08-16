import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/finance/finance_repository.dart';

void main() {
  late AppDatabase db;
  late FinanceRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = FinanceRepository(db);
  });

  tearDown(() async => db.close());

  test('createTransaction then getTransactions computes income/expense/net',
      () async {
    await repo.createTransaction({
      'type': 'Income',
      'category': 'Crop sales',
      'amount': '150000',
      'date': DateTime(2026, 1, 10).toIso8601String(),
      'description': 'Maize sale',
      'season': '2026 Rain',
    });
    await repo.createTransaction({
      'type': 'Expense',
      'category': 'Inputs',
      'amount': '40000',
      'date': DateTime(2026, 1, 12).toIso8601String(),
      'description': 'Seed purchase',
    });

    final data = await repo.getTransactions();
    expect(data.transactions, hasLength(2));
    expect(data.summary.income, 150000);
    expect(data.summary.expense, 40000);
    expect(data.summary.net, 110000);
    expect(data.summary.byCategory, hasLength(2));
  });

  test('getTransactions filters by season', () async {
    await repo.createTransaction({
      'type': 'Income',
      'category': 'Crop sales',
      'amount': '1000',
      'date': DateTime(2026, 1, 1).toIso8601String(),
      'description': 'A',
      'season': '2026 Rain',
    });
    await repo.createTransaction({
      'type': 'Income',
      'category': 'Crop sales',
      'amount': '2000',
      'date': DateTime(2025, 6, 1).toIso8601String(),
      'description': 'B',
      'season': '2025 Dry',
    });

    final filtered = await repo.getTransactions(season: '2026 Rain');
    expect(filtered.transactions, hasLength(1));
    expect(filtered.summary.income, 1000);
  });

  test('deleteTransaction removes the row', () async {
    await repo.createTransaction({
      'type': 'Expense',
      'category': 'Other',
      'amount': '500',
      'date': DateTime(2026, 1, 1).toIso8601String(),
      'description': 'X',
    });
    final before = await repo.getTransactions();
    final id = before.transactions.first.id;

    await repo.deleteTransaction(id);

    expect((await repo.getTransactions()).transactions, isEmpty);
  });

  test('createOverhead then getOverhead computes total/recurring', () async {
    await repo.createOverhead({
      'description': 'Land rent',
      'category': 'Rent',
      'amount': '20000',
      'date': DateTime(2026, 1, 1).toIso8601String(),
      'recurring': true,
    });
    await repo.createOverhead({
      'description': 'Fence repair',
      'category': 'Maintenance',
      'amount': '5000',
      'date': DateTime(2026, 1, 2).toIso8601String(),
      'recurring': false,
    });

    final data = await repo.getOverhead();
    expect(data.expenses, hasLength(2));
    expect(data.summary.total, 25000);
    expect(data.summary.recurring, 20000);
  });

  test('deleteOverhead removes the row', () async {
    await repo.createOverhead({
      'description': 'Test',
      'category': 'Other',
      'amount': '100',
      'date': DateTime(2026, 1, 1).toIso8601String(),
      'recurring': false,
    });
    final before = await repo.getOverhead();
    final id = before.expenses.first.id;

    await repo.deleteOverhead(id);

    expect((await repo.getOverhead()).expenses, isEmpty);
  });
}
