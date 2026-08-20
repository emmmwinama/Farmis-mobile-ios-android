import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/notifications/notifications_repository.dart';
import 'package:farmio_mobile/features/fields/fields_repository.dart';
import 'package:farmio_mobile/features/crops/crops_repository.dart';
import 'package:farmio_mobile/features/activities/activities_repository.dart';
import 'package:farmio_mobile/features/inventory/inventory_repository.dart';

void main() {
  late AppDatabase db;
  late NotificationsRepository repo;
  late FieldsRepository fields;
  late CropsRepository crops;
  late ActivitiesRepository activities;
  late InventoryRepository inventory;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = NotificationsRepository(db);
    fields = FieldsRepository(db);
    crops = CropsRepository(db);
    activities = ActivitiesRepository(db);
    inventory = InventoryRepository(db);
  });

  tearDown(() async => db.close());

  test('getNotifications generates a crop_activity_due notification for an overdue step',
      () async {
    final field = await fields.createField({
      'name': 'North Field',
      'totalArea': '10',
      'cultivatableArea': '9',
      'soilType': 'Loam',
    });
    final cropType = await crops.createCropType('Maize');
    await crops.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': field.id,
      'variety': 'DK8053',
      'areaPlanted': '3',
      'season': '2026 Rain',
      'plantingDate':
          DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
      'expectedHarvestDate':
          DateTime.now().add(const Duration(days: 60)).toIso8601String(),
    });

    final data = await repo.getNotifications();

    expect(data.notifications.any((n) => n.type == 'crop_activity_due'), isTrue);
    expect(data.unread, greaterThan(0));
  });

  test('getNotifications does not duplicate notifications on a second call',
      () async {
    final field = await fields.createField({
      'name': 'North Field',
      'totalArea': '10',
      'cultivatableArea': '9',
      'soilType': 'Loam',
    });
    final cropType = await crops.createCropType('Maize');
    await crops.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': field.id,
      'variety': 'DK8053',
      'areaPlanted': '3',
      'season': '2026 Rain',
      'plantingDate':
          DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
      'expectedHarvestDate':
          DateTime.now().add(const Duration(days: 60)).toIso8601String(),
    });

    final first = await repo.getNotifications();
    final second = await repo.getNotifications();

    expect(second.notifications.length, first.notifications.length);
  });

  test('getNotifications generates harvest_due within 14 days of expected harvest',
      () async {
    final field = await fields.createField({
      'name': 'North Field',
      'totalArea': '10',
      'cultivatableArea': '9',
      'soilType': 'Loam',
    });
    final cropType = await crops.createCropType('Maize');
    await crops.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': field.id,
      'variety': 'DK8053',
      'areaPlanted': '3',
      'season': '2026 Rain',
      'plantingDate':
          DateTime.now().subtract(const Duration(days: 100)).toIso8601String(),
      'expectedHarvestDate':
          DateTime.now().add(const Duration(days: 5)).toIso8601String(),
    });

    final data = await repo.getNotifications();

    expect(data.notifications.any((n) => n.type == 'harvest_due'), isTrue);
  });

  test('getNotifications generates no_activity after 21+ days since the last logged activity',
      () async {
    final field = await fields.createField({
      'name': 'North Field',
      'totalArea': '10',
      'cultivatableArea': '9',
      'soilType': 'Loam',
    });
    final cropType = await crops.createCropType('Maize');
    final crop = await crops.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': field.id,
      'variety': 'DK8053',
      'areaPlanted': '3',
      'season': '2026 Rain',
      'plantingDate':
          DateTime.now().subtract(const Duration(days: 100)).toIso8601String(),
      'expectedHarvestDate':
          DateTime.now().add(const Duration(days: 60)).toIso8601String(),
    });
    await activities.createActivity({
      'activityType': 'Weeding',
      'fieldId': field.id,
      'cropFieldId': crop.id,
      'date':
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'inputs': [],
      'otherCosts': [],
    });

    final data = await repo.getNotifications();

    expect(data.notifications.any((n) => n.type == 'no_activity'), isTrue);
  });

  test('getNotifications generates low_inventory below 20% remaining', () async {
    await inventory.createItem({
      'name': 'Fertiliser',
      'category': 'Input',
      'unit': 'kg',
      'quantity': '100',
    });
    final itemId = (await inventory.getItems()).first.id;
    await inventory.createSale({
      'inventoryItemId': itemId,
      'quantitySold': '85',
      'pricePerUnit': '100',
      'saleDate': DateTime.now().toIso8601String(),
    });

    final data = await repo.getNotifications();

    expect(data.notifications.any((n) => n.type == 'low_inventory'), isTrue);
  });

  test('getNotifications does not generate alerts for a crop already marked harvested',
      () async {
    final field = await fields.createField({
      'name': 'North Field',
      'totalArea': '10',
      'cultivatableArea': '9',
      'soilType': 'Loam',
    });
    final cropType = await crops.createCropType('Maize');
    final crop = await crops.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': field.id,
      'variety': 'DK8053',
      'areaPlanted': '3',
      'season': '2026 Rain',
      // Both overdue on its timeline steps and overdue on expected harvest.
      'plantingDate':
          DateTime.now().subtract(const Duration(days: 200)).toIso8601String(),
      'expectedHarvestDate':
          DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
    });
    await crops.markHarvested(crop.id);

    final data = await repo.getNotifications();

    expect(data.notifications.any((n) => n.type == 'crop_activity_due'), isFalse);
    expect(data.notifications.any((n) => n.type == 'harvest_due'), isFalse);
  });

  test('getNotifications purges a stale alert once its crop is marked harvested afterward',
      () async {
    final field = await fields.createField({
      'name': 'North Field',
      'totalArea': '10',
      'cultivatableArea': '9',
      'soilType': 'Loam',
    });
    final cropType = await crops.createCropType('Maize');
    final crop = await crops.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': field.id,
      'variety': 'DK8053',
      'areaPlanted': '3',
      'season': '2026 Rain',
      'plantingDate':
          DateTime.now().subtract(const Duration(days: 200)).toIso8601String(),
      'expectedHarvestDate':
          DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
    });

    final before = await repo.getNotifications();
    expect(before.notifications.any((n) => n.type == 'crop_activity_due'), isTrue);

    await crops.markHarvested(crop.id);
    final after = await repo.getNotifications();

    expect(after.notifications.any((n) => n.type == 'crop_activity_due'), isFalse);
    expect(after.notifications.any((n) => n.type == 'harvest_due'), isFalse);
  });

  test('markAllRead clears the unread count', () async {
    final field = await fields.createField({
      'name': 'North Field',
      'totalArea': '10',
      'cultivatableArea': '9',
      'soilType': 'Loam',
    });
    final cropType = await crops.createCropType('Maize');
    await crops.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': field.id,
      'variety': 'DK8053',
      'areaPlanted': '3',
      'season': '2026 Rain',
      'plantingDate':
          DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
      'expectedHarvestDate':
          DateTime.now().add(const Duration(days: 60)).toIso8601String(),
    });
    await repo.getNotifications();

    await repo.markAllRead();
    final data = await repo.getNotifications();

    expect(data.unread, 0);
  });
}
