import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/auth/account_models.dart';
import 'package:farmio_mobile/core/auth/account_provider.dart';
import 'package:farmio_mobile/core/auth/account_repository.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/core/db/database_provider.dart';
import 'package:farmio_mobile/core/sync/auto_sync_service.dart';
import 'package:farmio_mobile/features/fields/fields_repository.dart';

class _FakeAccountRepository extends AccountRepository {
  int backupCalls = 0;
  bool shouldThrow = false;
  _FakeAccountRepository() : super(Dio());

  @override
  Future<Map<String, int>> backup(Map<String, dynamic> exportJson) async {
    backupCalls++;
    if (shouldThrow) throw Exception('network error');
    return {'fields': 1};
  }
}

const _freeAccount = Account(
  user: AccountUser(id: 'u1', name: 'Jane', email: 'jane@example.com'),
  farm: AccountFarm(id: 'f1', name: 'Jane Farm'),
  subscription: AccountSubscription(status: 'active', tierName: 'Mobile Free'),
);

const _paidAccount = Account(
  user: AccountUser(id: 'u1', name: 'Jane', email: 'jane@example.com'),
  farm: AccountFarm(id: 'f1', name: 'Jane Farm'),
  subscription: AccountSubscription(status: 'active', tierName: 'Mobile Monthly'),
);

void main() {
  late AppDatabase db;
  late _FakeAccountRepository fakeRepo;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    // Force the schema-creation migration (which seeds default crop types
    // via an insert — a genuine local write) to run now, before the sync
    // watcher subscribes below, so it isn't mistaken for a user-triggered
    // write and doesn't schedule a spurious extra sync mid-test.
    await db.select(db.fields).get();
    fakeRepo = _FakeAccountRepository();
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      accountRepositoryProvider.overrideWithValue(fakeRepo),
    ]);
    addTearDown(container.dispose);
    addTearDown(db.close);
  });

  void setAccount(Account? account) {
    final notifier = container.read(accountProvider.notifier);
    // ignore: invalid_use_of_protected_member
    notifier.state = AccountState(hydrated: true, account: account);
  }

  testWidgets('stays disabled for a free-tier account, never syncing', (tester) async {
    setAccount(_freeAccount);
    container.read(autoSyncProvider); // create the notifier
    await FieldsRepository(db).createField({
      'name': 'A', 'totalArea': 1.0, 'cultivatableArea': 1.0, 'soilType': 'Loam',
    });

    await tester.pump(const Duration(seconds: 10));

    expect(container.read(autoSyncProvider).status, SyncStatus.disabled);
    expect(fakeRepo.backupCalls, 0);
  });

  testWidgets('runs a courtesy sync as soon as a paid account is set', (tester) async {
    setAccount(_paidAccount);
    container.read(autoSyncProvider);

    await tester.pump(const Duration(seconds: 10));

    expect(fakeRepo.backupCalls, 1);
    expect(container.read(autoSyncProvider).status, SyncStatus.synced);
  });

  testWidgets('debounces a local write into a single sync after the delay', (tester) async {
    setAccount(_paidAccount);
    container.read(autoSyncProvider);
    await tester.pump(const Duration(seconds: 10)); // let the courtesy sync settle
    fakeRepo.backupCalls = 0;

    final repo = FieldsRepository(db);
    await repo.createField({'name': 'A', 'totalArea': 1.0, 'cultivatableArea': 1.0, 'soilType': 'Loam'});
    await tester.pump(const Duration(seconds: 3));
    await repo.createField({'name': 'B', 'totalArea': 1.0, 'cultivatableArea': 1.0, 'soilType': 'Loam'});

    // Still within the debounce window from the second write — no sync yet.
    await tester.pump(const Duration(seconds: 3));
    expect(fakeRepo.backupCalls, 0);

    await tester.pump(const Duration(seconds: 6));
    expect(fakeRepo.backupCalls, 1);
  });

  testWidgets('an error can be retried via syncNow', (tester) async {
    fakeRepo.shouldThrow = true;
    setAccount(_paidAccount);
    container.read(autoSyncProvider);
    await tester.pump(const Duration(seconds: 10));

    expect(container.read(autoSyncProvider).status, SyncStatus.error);

    fakeRepo.shouldThrow = false;
    await container.read(autoSyncProvider.notifier).syncNow();

    expect(container.read(autoSyncProvider).status, SyncStatus.synced);
  });

  testWidgets('downgrading to free stops watching', (tester) async {
    setAccount(_paidAccount);
    container.read(autoSyncProvider);
    await tester.pump(const Duration(seconds: 10));
    fakeRepo.backupCalls = 0;

    setAccount(_freeAccount);
    await FieldsRepository(db).createField({
      'name': 'A', 'totalArea': 1.0, 'cultivatableArea': 1.0, 'soilType': 'Loam',
    });
    await tester.pump(const Duration(seconds: 10));

    expect(fakeRepo.backupCalls, 0);
    expect(container.read(autoSyncProvider).status, SyncStatus.disabled);
  });
}
