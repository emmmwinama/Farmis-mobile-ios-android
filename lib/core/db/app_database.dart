import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'db_utils.dart';

part 'app_database.g.dart';

// Livestock types were previously created ad hoc from the web dashboard;
// standalone mode has no dashboard, so a starter set ships with every fresh
// database instead. Users can still add farm-specific types later.
const _defaultLivestockTypes = [
  ('Cattle', 'Cattle'),
  ('Goats', 'Goats'),
  ('Sheep', 'Sheep'),
  ('Pigs', 'Pigs'),
  ('Chickens', 'Poultry'),
  ('Ducks', 'Poultry'),
];

// ── Farm profile (single row) ───────────────────────────────────────────────
class FarmProfile extends Table {
  TextColumn get id => text()();
  TextColumn get ownerName => text().nullable()();
  TextColumn get name => text()();
  TextColumn get location => text()();
  RealColumn get locationLat => real().nullable()();
  RealColumn get locationLng => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Fields ───────────────────────────────────────────────────────────────────
class Fields extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get totalArea => real()();
  RealColumn get cultivatableArea => real()();
  TextColumn get soilType => text()();
  RealColumn get locationLat => real().nullable()();
  RealColumn get locationLng => real().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FieldBoundaryRow')
class FieldBoundaries extends Table {
  TextColumn get id => text()();
  TextColumn get fieldId => text()();
  TextColumn get geoJson => text()(); // JSON-encoded
  RealColumn get areaHa => real().nullable()();
  RealColumn get centroidLat => real().nullable()();
  RealColumn get centroidLng => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FieldZoneRow')
class FieldZones extends Table {
  TextColumn get id => text()();
  TextColumn get boundaryId => text()();
  TextColumn get fieldId => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get cropFieldId => text().nullable()();
  TextColumn get geoJson => text()(); // JSON-encoded
  RealColumn get areaHa => real().nullable()();
  TextColumn get colour => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FarmMarkerRow')
class FarmMarkers extends Table {
  TextColumn get id => text()();
  TextColumn get fieldId => text().nullable()();
  TextColumn get type => text()();
  TextColumn get label => text()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  TextColumn get notes => text().nullable()();
  TextColumn get icon => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Crops ────────────────────────────────────────────────────────────────────
@DataClassName('CropTypeRow')
class CropTypes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class CropFields extends Table {
  TextColumn get id => text()();
  TextColumn get cropTypeId => text()();
  TextColumn get fieldId => text()();
  TextColumn get variety => text()();
  RealColumn get areaPlanted => real()();
  TextColumn get season => text()();
  DateTimeColumn get plantingDate => dateTime()();
  DateTimeColumn get expectedHarvestDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('Active'))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Activities ───────────────────────────────────────────────────────────────
class Activities extends Table {
  TextColumn get id => text()();
  TextColumn get activityType => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get fieldId => text()();
  TextColumn get cropFieldId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ActivityInputRow')
class ActivityInputs extends Table {
  TextColumn get id => text()();
  TextColumn get activityId => text()();
  TextColumn get inputName => text()();
  TextColumn get category => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  RealColumn get unitCost => real()();
  RealColumn get totalCost => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class ActivityLabourRecords extends Table {
  TextColumn get id => text()();
  TextColumn get activityId => text()();
  TextColumn get employeeId => text()();
  RealColumn get hoursWorked => real()();
  RealColumn get daysWorked => real()();
  RealColumn get totalCost => real()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ActivityOtherCostRow')
class ActivityOtherCosts extends Table {
  TextColumn get id => text()();
  TextColumn get activityId => text()();
  TextColumn get description => text()();
  RealColumn get amount => real()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Employees ────────────────────────────────────────────────────────────────
class Employees extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get role => text()();
  RealColumn get payRate => real()();
  TextColumn get payRateUnit => text()();
  TextColumn get phone => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Finance ──────────────────────────────────────────────────────────────────
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()(); // Income | Expense
  TextColumn get category => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text()();
  TextColumn get season => text().nullable()();
  TextColumn get fieldId => text().nullable()();
  TextColumn get cropFieldId => text().nullable()();
  TextColumn get harvestYieldId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OverheadExpenseRow')
class OverheadExpenses extends Table {
  TextColumn get id => text()();
  TextColumn get description => text()();
  TextColumn get category => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get recurring => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Yields & inventory ───────────────────────────────────────────────────────
class HarvestYields extends Table {
  TextColumn get id => text()();
  TextColumn get cropFieldId => text()();
  DateTimeColumn get harvestDate => dateTime()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  RealColumn get unitWeight => real().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('InventoryItemRow')
class InventoryItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get unit => text()();
  RealColumn get quantity => real()();
  RealColumn get acquisitionUnitCost => real().nullable()();
  DateTimeColumn get acquiredAt => dateTime().nullable()();
  RealColumn get unitWeight => real().nullable()();
  TextColumn get season => text().nullable()();
  TextColumn get cropFieldId => text().nullable()();
  TextColumn get harvestYieldId => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('InventorySaleRow')
class InventorySales extends Table {
  TextColumn get id => text()();
  TextColumn get inventoryItemId => text()();
  RealColumn get quantitySold => real()();
  TextColumn get unit => text()();
  RealColumn get pricePerUnit => real()();
  RealColumn get totalAmount => real()();
  TextColumn get buyerName => text().nullable()();
  DateTimeColumn get saleDate => dateTime()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Documents & notifications ───────────────────────────────────────────────
@DataClassName('FarmDocumentRow')
class FarmDocuments extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get url => text()(); // local file path
  IntColumn get size => integer().nullable()();
  TextColumn get linkedTo => text().nullable()();
  TextColumn get linkedType => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get uploadedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('NotificationRow')
class Notifications extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get message => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get link => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  // A deliberate user dismissal, distinct from a hard delete: the row is
  // kept (not shown in the list, not re-notified) so the same still-true
  // condition doesn't just get regenerated the next time notifications
  // refresh — see NotificationsRepository.dismissNotification.
  BoolColumn get dismissed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Livestock ────────────────────────────────────────────────────────────────
@DataClassName('LivestockTypeRow')
class LivestockTypes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get icon => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AnimalRow')
class Animals extends Table {
  TextColumn get id => text()();
  TextColumn get livestockTypeId => text()();
  TextColumn get tag => text().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get animalGroup => text().nullable()(); // `group` is reserved
  TextColumn get sex => text()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  DateTimeColumn get acquisitionDate => dateTime()();
  TextColumn get acquisitionType => text()();
  RealColumn get acquisitionCost => real().nullable()();
  TextColumn get status => text().withDefault(const Constant('Active'))();
  TextColumn get breed => text().nullable()();
  TextColumn get colour => text().nullable()();
  RealColumn get weight => real().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AnimalHealthRecords extends Table {
  TextColumn get id => text()();
  TextColumn get animalId => text()();
  TextColumn get type => text()();
  TextColumn get description => text()();
  TextColumn get veterinarian => text().nullable()();
  RealColumn get cost => real()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get nextDueDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AnimalProductionRecords extends Table {
  TextColumn get id => text()();
  TextColumn get animalId => text()();
  TextColumn get type => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get pricePerUnit => real().nullable()();
  RealColumn get totalValue => real().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AnimalWeightRecords extends Table {
  TextColumn get id => text()();
  TextColumn get animalId => text()();
  RealColumn get weight => real()();
  TextColumn get unit => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AnimalExpenseRecords extends Table {
  TextColumn get id => text()();
  TextColumn get animalId => text().nullable()();
  TextColumn get category => text()();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AnimalSaleRecords extends Table {
  TextColumn get id => text()();
  TextColumn get animalId => text()();
  DateTimeColumn get saleDate => dateTime()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  RealColumn get weightAtSale => real().nullable()();
  RealColumn get pricePerKg => real().nullable()();
  RealColumn get totalAmount => real()();
  TextColumn get buyer => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  FarmProfile,
  Fields,
  FieldBoundaries,
  FieldZones,
  FarmMarkers,
  CropTypes,
  CropFields,
  Activities,
  ActivityInputs,
  ActivityLabourRecords,
  ActivityOtherCosts,
  Employees,
  Transactions,
  OverheadExpenses,
  HarvestYields,
  InventoryItems,
  InventorySales,
  FarmDocuments,
  Notifications,
  LivestockTypes,
  Animals,
  AnimalHealthRecords,
  AnimalProductionRecords,
  AnimalWeightRecords,
  AnimalExpenseRecords,
  AnimalSaleRecords,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection()) {
    // Every existing model's `fromJson` expects DateTime fields as ISO8601
    // strings (`DateTime.parse(json['x'] as String)`), so drift's generated
    // row `.toJson()` is configured to serialize DateTime columns as
    // ISO8601 strings globally — this is what makes
    // `Model.fromJson(row.toJson())` work unchanged everywhere. Set in the
    // constructor (not just `_openConnection`) so it applies regardless of
    // which executor is passed in — including `NativeDatabase.memory()` in
    // tests, which bypasses `_openConnection` entirely.
    driftRuntimeOptions.defaultSerializer =
        const ValueSerializer.defaults(serializeDateTimeValuesAsString: true);
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await batch((b) {
            b.insertAll(
              livestockTypes,
              _defaultLivestockTypes
                  .map((t) => LivestockTypesCompanion.insert(
                        id: newId(),
                        name: t.$1,
                        category: t.$2,
                        icon: t.$1,
                      ))
                  .toList(),
            );
          });
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(farmProfile, farmProfile.ownerName);
          }
          if (from < 3) {
            await m.addColumn(notifications, notifications.dismissed);
          }
        },
      );
}

/// Opens (creating if needed) the on-device sqlite file at the app's
/// documents directory.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'agrivault.sqlite'));
    // Opened on the main isolate (not `createInBackground`): this app's
    // write volume is low, and a background-isolate connection adds a
    // failure mode (isolate spawn stalling with no error surfaced) that
    // isn't worth the throughput win here.
    return NativeDatabase(file, setup: (rawDb) {
      applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      rawDb.execute('PRAGMA foreign_keys = ON;');
    });
  });
}
