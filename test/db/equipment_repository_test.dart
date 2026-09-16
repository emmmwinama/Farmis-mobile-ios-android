import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/equipment/equipment_repository.dart';
import '../support/fake_mobile_api.dart';

void main() {
  late AppDatabase db;
  late EquipmentRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = EquipmentRepository(
        db, fakeApiDio([FakeEquipmentResource('/api/mobile/equipment')]));
  });

  tearDown(() async => db.close());

  test('addEquipment then getEquipment lists it', () async {
    await repo.addEquipment({'name': 'Tractor', 'category': 'tractor'});

    final items = await repo.getEquipment();
    expect(items, hasLength(1));
    expect(items.first.name, 'Tractor');
    expect(items.first.category, 'tractor');
    expect(items.first.status, 'active');
  });

  test('updateEquipment merges onto the current row', () async {
    await repo.addEquipment({'name': 'Tractor', 'category': 'tractor'});
    final id = (await repo.getEquipment()).first.id;

    await repo.updateEquipment(id, {'status': 'under_repair'});

    final items = await repo.getEquipment();
    expect(items.first.status, 'under_repair');
    expect(items.first.name, 'Tractor'); // untouched
  });

  test('deleteEquipment removes the item', () async {
    await repo.addEquipment({'name': 'Tractor', 'category': 'tractor'});
    final id = (await repo.getEquipment()).first.id;

    await repo.deleteEquipment(id);

    expect(await repo.getEquipment(), isEmpty);
  });

  test('addLog then getEquipment reflects log count and maintenance cost',
      () async {
    await repo.addEquipment({'name': 'Tractor', 'category': 'tractor'});
    final id = (await repo.getEquipment()).first.id;

    await repo.addLog(id, {
      'date': DateTime(2026, 3, 1).toIso8601String(),
      'description': 'Oil change',
      'cost': '15000',
      'hoursUsed': '2',
    });

    final items = await repo.getEquipment();
    expect(items.first.logCount, 1);
    expect(items.first.maintenanceCost, 15000);

    final logs = await repo.getLogs(id);
    expect(logs, hasLength(1));
    expect(logs.first.description, 'Oil change');
    expect(logs.first.hoursUsed, 2);
  });

  test('deleteLog removes just that log', () async {
    await repo.addEquipment({'name': 'Tractor', 'category': 'tractor'});
    final id = (await repo.getEquipment()).first.id;
    await repo.addLog(id, {
      'date': DateTime(2026, 3, 1).toIso8601String(),
      'description': 'Oil change',
      'cost': '15000',
    });
    final logId = (await repo.getLogs(id)).first.id;

    await repo.deleteLog(id, logId);

    expect(await repo.getLogs(id), isEmpty);
  });
}
