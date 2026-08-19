import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../db/app_database.dart';

class ImportSummary {
  final Map<String, int> counts;
  const ImportSummary(this.counts);

  int get total => counts.values.fold(0, (s, c) => s + c);

  @override
  String toString() => counts.entries
      .where((e) => e.value > 0)
      .map((e) => '${e.key}: ${e.value}')
      .join(', ');
}

/// One-time import of a farm's data exported from the old backend (via
/// `Farmis/scripts/export-mobile-data.ts`) into the local database. Meant
/// to run once, against a freshly-installed app, before the farmer starts
/// entering their own data — safe to delete once that migration is done.
class ImportService {
  ImportService(this._db);

  final AppDatabase _db;

  Future<ImportSummary> importFromJson(Map<String, dynamic> json) async {
    final counts = <String, int>{};

    await _db.transaction(() async {
      counts['farmProfile'] = await _importFarmProfile(json['farmProfile']);
      counts['fields'] = await _importList(json['fields'], _importField);
      counts['fieldBoundaries'] =
          await _importList(json['fieldBoundaries'], _importFieldBoundary);
      counts['fieldZones'] =
          await _importList(json['fieldZones'], _importFieldZone);
      counts['farmMarkers'] =
          await _importList(json['farmMarkers'], _importFarmMarker);
      counts['cropTypes'] =
          await _importList(json['cropTypes'], _importCropType);
      counts['cropFields'] =
          await _importList(json['cropFields'], _importCropField);
      counts['employees'] =
          await _importList(json['employees'], _importEmployee);
      counts['activities'] =
          await _importList(json['activities'], _importActivity);
      counts['activityInputs'] =
          await _importList(json['activityInputs'], _importActivityInput);
      counts['activityLabourRecords'] = await _importList(
          json['activityLabourRecords'], _importActivityLabour);
      counts['activityOtherCosts'] = await _importList(
          json['activityOtherCosts'], _importActivityOtherCost);
      counts['transactions'] =
          await _importList(json['transactions'], _importTransaction);
      counts['overheadExpenses'] =
          await _importList(json['overheadExpenses'], _importOverhead);
      counts['harvestYields'] =
          await _importList(json['harvestYields'], _importHarvestYield);
      counts['inventoryItems'] =
          await _importList(json['inventoryItems'], _importInventoryItem);
      counts['inventorySales'] =
          await _importList(json['inventorySales'], _importInventorySale);
      counts['farmDocuments'] =
          await _importList(json['farmDocuments'], _importFarmDocument);
      counts['notifications'] =
          await _importList(json['notifications'], _importNotification);

      final livestockTypeRemap = await _importLivestockTypes(
          json['livestockTypes'] as List? ?? const []);
      counts['livestockTypes'] = livestockTypeRemap.length;
      counts['animals'] = await _importList(
          json['animals'], (row) => _importAnimal(row, livestockTypeRemap));
      counts['animalHealthRecords'] =
          await _importList(json['animalHealthRecords'], _importAnimalHealth);
      counts['animalProductionRecords'] = await _importList(
          json['animalProductionRecords'], _importAnimalProduction);
      counts['animalWeightRecords'] =
          await _importList(json['animalWeightRecords'], _importAnimalWeight);
      counts['animalExpenseRecords'] = await _importList(
          json['animalExpenseRecords'], _importAnimalExpense);
      counts['animalSaleRecords'] =
          await _importList(json['animalSaleRecords'], _importAnimalSale);
    });

    return ImportSummary(counts);
  }

  Future<int> _importList(
    Object? rows,
    Future<void> Function(Map<String, dynamic>) importRow,
  ) async {
    if (rows is! List) return 0;
    for (final row in rows) {
      await importRow(row as Map<String, dynamic>);
    }
    return rows.length;
  }

  DateTime? _dateOrNull(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
  DateTime _date(Object? value) => _dateOrNull(value) ?? DateTime.now();
  double? _numOrNull(Object? value) => (value as num?)?.toDouble();
  double _num(Object? value, {double fallback = 0}) =>
      (value as num?)?.toDouble() ?? fallback;

  /// `farmProfile` is a singleton table with no uniqueness constraint
  /// beyond `id` — if onboarding already created a row (with a locally
  /// generated id) before this import runs, the imported row's id won't
  /// match it, so a plain conflict-or-update insert would silently create
  /// a *second* row instead of replacing the first. This updates whatever
  /// row already exists in place, and only inserts fresh if the table is
  /// genuinely empty.
  Future<int> _importFarmProfile(Object? row) async {
    if (row is! Map<String, dynamic>) return 0;
    final ownerName = Value(row['ownerName'] as String?);
    final name = row['name'] as String? ?? 'My Farm';
    final location = row['location'] as String? ?? '';
    final locationLat = Value(_numOrNull(row['locationLat']));
    final locationLng = Value(_numOrNull(row['locationLng']));

    final existing = await _db.select(_db.farmProfile).getSingleOrNull();
    if (existing != null) {
      await (_db.update(_db.farmProfile)
            ..where((t) => t.id.equals(existing.id)))
          .write(FarmProfileCompanion(
        ownerName: ownerName,
        name: Value(name),
        location: Value(location),
        locationLat: locationLat,
        locationLng: locationLng,
      ));
    } else {
      await _db.into(_db.farmProfile).insert(FarmProfileCompanion.insert(
            id: row['id'] as String,
            ownerName: ownerName,
            name: name,
            location: location,
            locationLat: locationLat,
            locationLng: locationLng,
            createdAt: _date(row['createdAt']),
          ));
    }
    return 1;
  }

  Future<void> _importField(Map<String, dynamic> row) async {
    await _db.into(_db.fields).insert(
          FieldsCompanion.insert(
            id: row['id'] as String,
            name: row['name'] as String,
            totalArea: _num(row['totalArea']),
            cultivatableArea: _num(row['cultivatableArea']),
            soilType: row['soilType'] as String? ?? 'Not set',
            locationLat: Value(_numOrNull(row['locationLat'])),
            locationLng: Value(_numOrNull(row['locationLng'])),
            notes: Value(row['notes'] as String?),
            createdAt: _date(row['createdAt']),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importFieldBoundary(Map<String, dynamic> row) async {
    await _db.into(_db.fieldBoundaries).insert(
          FieldBoundariesCompanion.insert(
            id: row['id'] as String,
            fieldId: row['fieldId'] as String,
            geoJson: jsonEncode(row['geoJson']),
            areaHa: Value(_numOrNull(row['areaHa'])),
            centroidLat: Value(_numOrNull(row['centroidLat'])),
            centroidLng: Value(_numOrNull(row['centroidLng'])),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importFieldZone(Map<String, dynamic> row) async {
    await _db.into(_db.fieldZones).insert(
          FieldZonesCompanion.insert(
            id: row['id'] as String,
            boundaryId: row['boundaryId'] as String,
            fieldId: row['fieldId'] as String,
            name: row['name'] as String? ?? 'Zone',
            type: row['type'] as String? ?? 'crop',
            cropFieldId: Value(row['cropFieldId'] as String?),
            geoJson: jsonEncode(row['geoJson']),
            areaHa: Value(_numOrNull(row['areaHa'])),
            colour: Value(row['colour'] as String?),
            notes: Value(row['notes'] as String?),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importFarmMarker(Map<String, dynamic> row) async {
    await _db.into(_db.farmMarkers).insert(
          FarmMarkersCompanion.insert(
            id: row['id'] as String,
            fieldId: Value(row['fieldId'] as String?),
            type: row['type'] as String,
            label: row['label'] as String,
            lat: _num(row['lat']),
            lng: _num(row['lng']),
            notes: Value(row['notes'] as String?),
            icon: Value(row['icon'] as String?),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importCropType(Map<String, dynamic> row) async {
    await _db.into(_db.cropTypes).insert(
          CropTypesCompanion.insert(
            id: row['id'] as String,
            name: row['name'] as String,
            isCustom: Value(row['isCustom'] as bool? ?? false),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importCropField(Map<String, dynamic> row) async {
    await _db.into(_db.cropFields).insert(
          CropFieldsCompanion.insert(
            id: row['id'] as String,
            cropTypeId: row['cropTypeId'] as String,
            fieldId: row['fieldId'] as String,
            variety: row['variety'] as String? ?? '',
            areaPlanted: _num(row['areaPlanted']),
            season: row['season'] as String,
            plantingDate: _date(row['plantingDate']),
            expectedHarvestDate: _date(row['expectedHarvestDate']),
            status: Value(row['status'] as String? ?? 'Active'),
            isArchived: Value(row['isArchived'] as bool? ?? false),
            createdAt: _date(row['createdAt']),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importEmployee(Map<String, dynamic> row) async {
    await _db.into(_db.employees).insert(
          EmployeesCompanion.insert(
            id: row['id'] as String,
            name: row['name'] as String,
            role: row['role'] as String,
            payRate: _num(row['payRate']),
            payRateUnit: row['payRateUnit'] as String? ?? 'day',
            phone: Value(row['phone'] as String?),
            isActive: Value(row['isActive'] as bool? ?? true),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importActivity(Map<String, dynamic> row) async {
    await _db.into(_db.activities).insert(
          ActivitiesCompanion.insert(
            id: row['id'] as String,
            activityType: row['activityType'] as String,
            date: _date(row['date']),
            notes: Value(row['notes'] as String?),
            fieldId: row['fieldId'] as String,
            cropFieldId: Value(row['cropFieldId'] as String?),
            createdAt: _date(row['createdAt']),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importActivityInput(Map<String, dynamic> row) async {
    await _db.into(_db.activityInputs).insert(
          ActivityInputsCompanion.insert(
            id: row['id'] as String,
            activityId: row['activityId'] as String,
            inputName: row['inputName'] as String,
            category: row['category'] as String? ?? 'Other',
            quantity: _num(row['quantity']),
            unit: row['unit'] as String? ?? '',
            unitCost: _num(row['unitCost']),
            totalCost: _num(row['totalCost']),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importActivityLabour(Map<String, dynamic> row) async {
    await _db.into(_db.activityLabourRecords).insert(
          ActivityLabourRecordsCompanion.insert(
            id: row['id'] as String,
            activityId: row['activityId'] as String,
            employeeId: row['employeeId'] as String,
            hoursWorked: _num(row['hoursWorked']),
            daysWorked: _num(row['daysWorked']),
            totalCost: _num(row['totalCost']),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importActivityOtherCost(Map<String, dynamic> row) async {
    await _db.into(_db.activityOtherCosts).insert(
          ActivityOtherCostsCompanion.insert(
            id: row['id'] as String,
            activityId: row['activityId'] as String,
            description: row['description'] as String,
            amount: _num(row['amount']),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importTransaction(Map<String, dynamic> row) async {
    await _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            id: row['id'] as String,
            type: row['type'] as String,
            category: row['category'] as String,
            amount: _num(row['amount']),
            date: _date(row['date']),
            description: row['description'] as String,
            season: Value(row['season'] as String?),
            fieldId: Value(row['fieldId'] as String?),
            cropFieldId: Value(row['cropFieldId'] as String?),
            harvestYieldId: Value(row['harvestYieldId'] as String?),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importOverhead(Map<String, dynamic> row) async {
    await _db.into(_db.overheadExpenses).insert(
          OverheadExpensesCompanion.insert(
            id: row['id'] as String,
            description: row['description'] as String,
            category: row['category'] as String,
            amount: _num(row['amount']),
            date: _date(row['date']),
            recurring: Value(row['recurring'] as bool? ?? false),
            notes: Value(row['notes'] as String?),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importHarvestYield(Map<String, dynamic> row) async {
    await _db.into(_db.harvestYields).insert(
          HarvestYieldsCompanion.insert(
            id: row['id'] as String,
            cropFieldId: row['cropFieldId'] as String,
            harvestDate: _date(row['harvestDate']),
            quantity: _num(row['quantity']),
            unit: row['unit'] as String,
            unitWeight: Value(_numOrNull(row['unitWeight'])),
            notes: Value(row['notes'] as String?),
            createdAt: _date(row['createdAt']),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importInventoryItem(Map<String, dynamic> row) async {
    await _db.into(_db.inventoryItems).insert(
          InventoryItemsCompanion.insert(
            id: row['id'] as String,
            name: row['name'] as String,
            category: row['category'] as String,
            unit: row['unit'] as String,
            quantity: _num(row['quantity']),
            acquisitionUnitCost: Value(_numOrNull(row['acquisitionUnitCost'])),
            acquiredAt: Value(_dateOrNull(row['acquiredAt'])),
            unitWeight: Value(_numOrNull(row['unitWeight'])),
            season: Value(row['season'] as String?),
            cropFieldId: Value(row['cropFieldId'] as String?),
            harvestYieldId: Value(row['harvestYieldId'] as String?),
            notes: Value(row['notes'] as String?),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importInventorySale(Map<String, dynamic> row) async {
    await _db.into(_db.inventorySales).insert(
          InventorySalesCompanion.insert(
            id: row['id'] as String,
            inventoryItemId: row['inventoryItemId'] as String,
            quantitySold: _num(row['quantitySold']),
            unit: row['unit'] as String,
            pricePerUnit: _num(row['pricePerUnit']),
            totalAmount: _num(row['totalAmount']),
            buyerName: Value(row['buyerName'] as String?),
            saleDate: _date(row['saleDate']),
            notes: Value(row['notes'] as String?),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// A base64 `data:` URL is decoded to a real file on-device (the one
  /// field needing transformation, per the migration plan); anything else
  /// (an already-local path, or an external URL) is copied through as-is.
  Future<void> _importFarmDocument(Map<String, dynamic> row) async {
    final id = row['id'] as String;
    final rawUrl = row['url'] as String? ?? '';
    String finalUrl = rawUrl;

    if (rawUrl.startsWith('data:')) {
      final comma = rawUrl.indexOf(',');
      final header = rawUrl.substring(5, comma == -1 ? rawUrl.length : comma);
      final mimeType = header.split(';').first;
      final extension = _extensionForMimeType(mimeType);
      // Some export tools wrap long base64 payloads with line breaks
      // (e.g. PHP's chunk_split, or how phpMyAdmin renders a LongText
      // column) — Dart's base64Decode rejects embedded whitespace outright,
      // so it's stripped before decoding.
      final base64Part = comma == -1
          ? ''
          : rawUrl.substring(comma + 1).replaceAll(RegExp(r'\s'), '');

      if (base64Part.isNotEmpty) {
        try {
          final bytes = base64Decode(base64Part);
          final dir = await getApplicationDocumentsDirectory();
          final docsDir = Directory(p.join(dir.path, 'documents'));
          await docsDir.create(recursive: true);
          final file = File(p.join(docsDir.path, '$id.$extension'));
          await file.writeAsBytes(bytes);
          finalUrl = file.path;
        } on FormatException {
          // Some database exports truncate long TEXT/LongText columns
          // (e.g. phpMyAdmin's max_allowed_packet limit), leaving a
          // malformed base64 payload for this one attachment. The file
          // content is unrecoverable, but the rest of the import — and
          // this document's own name/type/notes metadata — shouldn't be
          // lost over it.
          finalUrl = '';
        }
      }
    }

    await _db.into(_db.farmDocuments).insert(
          FarmDocumentsCompanion.insert(
            id: id,
            name: row['name'] as String,
            type: row['type'] as String,
            url: finalUrl,
            size: Value((row['size'] as num?)?.toInt()),
            linkedTo: Value(row['linkedTo'] as String?),
            linkedType: Value(row['linkedType'] as String?),
            notes: Value(row['notes'] as String?),
            uploadedAt: _date(row['uploadedAt']),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  String _extensionForMimeType(String mimeType) {
    switch (mimeType) {
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'application/pdf':
        return 'pdf';
      default:
        return 'jpg';
    }
  }

  Future<void> _importNotification(Map<String, dynamic> row) async {
    await _db.into(_db.notifications).insert(
          NotificationsCompanion.insert(
            id: row['id'] as String,
            type: row['type'] as String,
            title: row['title'] as String,
            message: row['message'] as String,
            isRead: Value(row['isRead'] as bool? ?? false),
            link: Value(row['link'] as String?),
            createdAt: _date(row['createdAt']),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Livestock types are seeded by default on every fresh database (see
  /// `AppDatabase.migration`'s `onCreate`), so an imported type with the
  /// same name would otherwise duplicate one that already exists. This
  /// matches by name, skips the duplicate insert, and returns a remap of
  /// imported-id -> local-id so animals can be re-pointed correctly.
  Future<Map<String, String>> _importLivestockTypes(List rows) async {
    final existing = await _db.select(_db.livestockTypes).get();
    final byName = {for (final t in existing) t.name: t.id};
    final remap = <String, String>{};

    for (final raw in rows) {
      final row = raw as Map<String, dynamic>;
      final importedId = row['id'] as String;
      final name = row['name'] as String;
      final matchedId = byName[name];
      if (matchedId != null) {
        remap[importedId] = matchedId;
        continue;
      }
      await _db.into(_db.livestockTypes).insert(
            LivestockTypesCompanion.insert(
              id: importedId,
              name: name,
              category: row['category'] as String? ?? name,
              icon: row['icon'] as String? ?? name,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      byName[name] = importedId;
      remap[importedId] = importedId;
    }
    return remap;
  }

  Future<void> _importAnimal(
    Map<String, dynamic> row,
    Map<String, String> livestockTypeRemap,
  ) async {
    final originalTypeId = row['livestockTypeId'] as String;
    await _db.into(_db.animals).insert(
          AnimalsCompanion.insert(
            id: row['id'] as String,
            livestockTypeId:
                livestockTypeRemap[originalTypeId] ?? originalTypeId,
            tag: Value(row['tag'] as String?),
            name: Value(row['name'] as String?),
            animalGroup: Value(row['animalGroup'] as String?),
            sex: row['sex'] as String? ?? 'Unknown',
            birthDate: Value(_dateOrNull(row['birthDate'])),
            acquisitionDate: _date(row['acquisitionDate']),
            acquisitionType: row['acquisitionType'] as String? ?? 'Born on farm',
            acquisitionCost: Value(_numOrNull(row['acquisitionCost'])),
            status: Value(row['status'] as String? ?? 'Active'),
            breed: Value(row['breed'] as String?),
            colour: Value(row['colour'] as String?),
            weight: Value(_numOrNull(row['weight'])),
            notes: Value(row['notes'] as String?),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importAnimalHealth(Map<String, dynamic> row) async {
    await _db.into(_db.animalHealthRecords).insert(
          AnimalHealthRecordsCompanion.insert(
            id: row['id'] as String,
            animalId: row['animalId'] as String,
            type: row['type'] as String,
            description: row['description'] as String,
            veterinarian: Value(row['veterinarian'] as String?),
            cost: _num(row['cost']),
            date: _date(row['date']),
            nextDueDate: Value(_dateOrNull(row['nextDueDate'])),
            notes: Value(row['notes'] as String?),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importAnimalProduction(Map<String, dynamic> row) async {
    final animalId = row['animalId'] as String?;
    if (animalId == null) return; // herd-level records have no local column
    await _db.into(_db.animalProductionRecords).insert(
          AnimalProductionRecordsCompanion.insert(
            id: row['id'] as String,
            animalId: animalId,
            type: row['type'] as String,
            quantity: _num(row['quantity']),
            unit: row['unit'] as String,
            date: _date(row['date']),
            pricePerUnit: Value(_numOrNull(row['pricePerUnit'])),
            totalValue: Value(_numOrNull(row['totalValue'])),
            notes: Value(row['notes'] as String?),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importAnimalWeight(Map<String, dynamic> row) async {
    await _db.into(_db.animalWeightRecords).insert(
          AnimalWeightRecordsCompanion.insert(
            id: row['id'] as String,
            animalId: row['animalId'] as String,
            weight: _num(row['weight']),
            unit: row['unit'] as String? ?? 'kg',
            date: _date(row['date']),
            notes: Value(row['notes'] as String?),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importAnimalExpense(Map<String, dynamic> row) async {
    await _db.into(_db.animalExpenseRecords).insert(
          AnimalExpenseRecordsCompanion.insert(
            id: row['id'] as String,
            animalId: Value(row['animalId'] as String?),
            category: row['category'] as String,
            description: row['description'] as String,
            amount: _num(row['amount']),
            date: _date(row['date']),
            notes: Value(row['notes'] as String?),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _importAnimalSale(Map<String, dynamic> row) async {
    await _db.into(_db.animalSaleRecords).insert(
          AnimalSaleRecordsCompanion.insert(
            id: row['id'] as String,
            animalId: row['animalId'] as String,
            saleDate: _date(row['saleDate']),
            quantity: Value((row['quantity'] as num?)?.toInt() ?? 1),
            weightAtSale: Value(_numOrNull(row['weightAtSale'])),
            pricePerKg: Value(_numOrNull(row['pricePerKg'])),
            totalAmount: _num(row['totalAmount']),
            buyer: Value(row['buyer'] as String?),
            notes: Value(row['notes'] as String?),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }
}
