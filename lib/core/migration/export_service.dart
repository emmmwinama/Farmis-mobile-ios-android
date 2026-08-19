import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// Dumps the entire local database to the same JSON shape [ImportService]
/// (in import_service.dart) reads — so a file exported from one install of
/// this app can be imported into another, and round-tripping (export, wipe,
/// re-import) is lossless for every table the importer understands.
class ExportService {
  ExportService(this._db);

  final AppDatabase _db;

  Future<Map<String, dynamic>> exportToJson() async {
    final farmProfile = await _db.select(_db.farmProfile).getSingleOrNull();

    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'farmProfile': farmProfile == null
          ? null
          : {
              'id': farmProfile.id,
              'ownerName': farmProfile.ownerName,
              'name': farmProfile.name,
              'location': farmProfile.location,
              'locationLat': farmProfile.locationLat,
              'locationLng': farmProfile.locationLng,
              'createdAt': _iso(farmProfile.createdAt),
            },
      'fields': await _dump(_db.fields, (Field r) => {
            'id': r.id,
            'name': r.name,
            'totalArea': r.totalArea,
            'cultivatableArea': r.cultivatableArea,
            'soilType': r.soilType,
            'locationLat': r.locationLat,
            'locationLng': r.locationLng,
            'notes': r.notes,
            'createdAt': _iso(r.createdAt),
          }),
      'fieldBoundaries': await _dump(_db.fieldBoundaries, (FieldBoundaryRow r) => {
            'id': r.id,
            'fieldId': r.fieldId,
            'geoJson': _decode(r.geoJson),
            'areaHa': r.areaHa,
            'centroidLat': r.centroidLat,
            'centroidLng': r.centroidLng,
          }),
      'fieldZones': await _dump(_db.fieldZones, (FieldZoneRow r) => {
            'id': r.id,
            'boundaryId': r.boundaryId,
            'fieldId': r.fieldId,
            'name': r.name,
            'type': r.type,
            'cropFieldId': r.cropFieldId,
            'geoJson': _decode(r.geoJson),
            'areaHa': r.areaHa,
            'colour': r.colour,
            'notes': r.notes,
          }),
      'farmMarkers': await _dump(_db.farmMarkers, (FarmMarkerRow r) => {
            'id': r.id,
            'fieldId': r.fieldId,
            'type': r.type,
            'label': r.label,
            'lat': r.lat,
            'lng': r.lng,
            'notes': r.notes,
            'icon': r.icon,
          }),
      'cropTypes': await _dump(_db.cropTypes, (CropTypeRow r) => {
            'id': r.id,
            'name': r.name,
            'isCustom': r.isCustom,
          }),
      'cropFields': await _dump(_db.cropFields, (CropField r) => {
            'id': r.id,
            'cropTypeId': r.cropTypeId,
            'fieldId': r.fieldId,
            'variety': r.variety,
            'areaPlanted': r.areaPlanted,
            'season': r.season,
            'plantingDate': _iso(r.plantingDate),
            'expectedHarvestDate': _iso(r.expectedHarvestDate),
            'status': r.status,
            'isArchived': r.isArchived,
            'createdAt': _iso(r.createdAt),
          }),
      'employees': await _dump(_db.employees, (Employee r) => {
            'id': r.id,
            'name': r.name,
            'role': r.role,
            'payRate': r.payRate,
            'payRateUnit': r.payRateUnit,
            'phone': r.phone,
            'isActive': r.isActive,
          }),
      'activities': await _dump(_db.activities, (Activity r) => {
            'id': r.id,
            'activityType': r.activityType,
            'date': _iso(r.date),
            'notes': r.notes,
            'fieldId': r.fieldId,
            'cropFieldId': r.cropFieldId,
            'createdAt': _iso(r.createdAt),
          }),
      'activityInputs': await _dump(_db.activityInputs, (ActivityInputRow r) => {
            'id': r.id,
            'activityId': r.activityId,
            'inputName': r.inputName,
            'category': r.category,
            'quantity': r.quantity,
            'unit': r.unit,
            'unitCost': r.unitCost,
            'totalCost': r.totalCost,
          }),
      'activityLabourRecords': await _dump(_db.activityLabourRecords, (ActivityLabourRecord r) => {
            'id': r.id,
            'activityId': r.activityId,
            'employeeId': r.employeeId,
            'hoursWorked': r.hoursWorked,
            'daysWorked': r.daysWorked,
            'totalCost': r.totalCost,
          }),
      'activityOtherCosts': await _dump(_db.activityOtherCosts, (ActivityOtherCostRow r) => {
            'id': r.id,
            'activityId': r.activityId,
            'description': r.description,
            'amount': r.amount,
          }),
      'transactions': await _dump(_db.transactions, (Transaction r) => {
            'id': r.id,
            'type': r.type,
            'category': r.category,
            'amount': r.amount,
            'date': _iso(r.date),
            'description': r.description,
            'season': r.season,
            'fieldId': r.fieldId,
            'cropFieldId': r.cropFieldId,
            'harvestYieldId': r.harvestYieldId,
          }),
      'overheadExpenses': await _dump(_db.overheadExpenses, (OverheadExpenseRow r) => {
            'id': r.id,
            'description': r.description,
            'category': r.category,
            'amount': r.amount,
            'date': _iso(r.date),
            'recurring': r.recurring,
            'notes': r.notes,
          }),
      'harvestYields': await _dump(_db.harvestYields, (HarvestYield r) => {
            'id': r.id,
            'cropFieldId': r.cropFieldId,
            'harvestDate': _iso(r.harvestDate),
            'quantity': r.quantity,
            'unit': r.unit,
            'unitWeight': r.unitWeight,
            'notes': r.notes,
            'createdAt': _iso(r.createdAt),
          }),
      'inventoryItems': await _dump(_db.inventoryItems, (InventoryItemRow r) => {
            'id': r.id,
            'name': r.name,
            'category': r.category,
            'unit': r.unit,
            'quantity': r.quantity,
            'acquisitionUnitCost': r.acquisitionUnitCost,
            'acquiredAt': _isoOrNull(r.acquiredAt),
            'unitWeight': r.unitWeight,
            'season': r.season,
            'cropFieldId': r.cropFieldId,
            'harvestYieldId': r.harvestYieldId,
            'notes': r.notes,
          }),
      'inventorySales': await _dump(_db.inventorySales, (InventorySaleRow r) => {
            'id': r.id,
            'inventoryItemId': r.inventoryItemId,
            'quantitySold': r.quantitySold,
            'unit': r.unit,
            'pricePerUnit': r.pricePerUnit,
            'totalAmount': r.totalAmount,
            'buyerName': r.buyerName,
            'saleDate': _iso(r.saleDate),
            'notes': r.notes,
          }),
      'farmDocuments': await _dump(_db.farmDocuments, (FarmDocumentRow r) => {
            'id': r.id,
            'name': r.name,
            'type': r.type,
            // Local file paths aren't portable across devices/installs — an
            // export only carries the document's metadata, not its bytes
            // (unlike import, which can decode a base64 payload back in).
            'url': '',
            'size': r.size,
            'linkedTo': r.linkedTo,
            'linkedType': r.linkedType,
            'notes': r.notes,
            'uploadedAt': _iso(r.uploadedAt),
          }),
      'notifications': await _dump(_db.notifications, (NotificationRow r) => {
            'id': r.id,
            'type': r.type,
            'title': r.title,
            'message': r.message,
            'isRead': r.isRead,
            'link': r.link,
            'createdAt': _iso(r.createdAt),
          }),
      'livestockTypes': await _dump(_db.livestockTypes, (LivestockTypeRow r) => {
            'id': r.id,
            'name': r.name,
            'category': r.category,
            'icon': r.icon,
          }),
      'animals': await _dump(_db.animals, (AnimalRow r) => {
            'id': r.id,
            'livestockTypeId': r.livestockTypeId,
            'tag': r.tag,
            'name': r.name,
            'animalGroup': r.animalGroup,
            'sex': r.sex,
            'birthDate': _isoOrNull(r.birthDate),
            'acquisitionDate': _iso(r.acquisitionDate),
            'acquisitionType': r.acquisitionType,
            'acquisitionCost': r.acquisitionCost,
            'status': r.status,
            'breed': r.breed,
            'colour': r.colour,
            'weight': r.weight,
            'notes': r.notes,
          }),
      'animalHealthRecords': await _dump(_db.animalHealthRecords, (AnimalHealthRecord r) => {
            'id': r.id,
            'animalId': r.animalId,
            'type': r.type,
            'description': r.description,
            'veterinarian': r.veterinarian,
            'cost': r.cost,
            'date': _iso(r.date),
            'nextDueDate': _isoOrNull(r.nextDueDate),
            'notes': r.notes,
          }),
      'animalProductionRecords':
          await _dump(_db.animalProductionRecords, (AnimalProductionRecord r) => {
                'id': r.id,
                'animalId': r.animalId,
                'type': r.type,
                'quantity': r.quantity,
                'unit': r.unit,
                'date': _iso(r.date),
                'pricePerUnit': r.pricePerUnit,
                'totalValue': r.totalValue,
                'notes': r.notes,
              }),
      'animalWeightRecords': await _dump(_db.animalWeightRecords, (AnimalWeightRecord r) => {
            'id': r.id,
            'animalId': r.animalId,
            'weight': r.weight,
            'unit': r.unit,
            'date': _iso(r.date),
            'notes': r.notes,
          }),
      'animalExpenseRecords': await _dump(_db.animalExpenseRecords, (AnimalExpenseRecord r) => {
            'id': r.id,
            'animalId': r.animalId,
            'category': r.category,
            'description': r.description,
            'amount': r.amount,
            'date': _iso(r.date),
            'notes': r.notes,
          }),
      'animalSaleRecords': await _dump(_db.animalSaleRecords, (AnimalSaleRecord r) => {
            'id': r.id,
            'animalId': r.animalId,
            'saleDate': _iso(r.saleDate),
            'quantity': r.quantity,
            'weightAtSale': r.weightAtSale,
            'pricePerKg': r.pricePerKg,
            'totalAmount': r.totalAmount,
            'buyer': r.buyer,
            'notes': r.notes,
          }),
    };
  }

  Future<List<Map<String, dynamic>>> _dump<Tbl extends Table, D>(
    TableInfo<Tbl, D> table,
    Map<String, dynamic> Function(D row) toJson,
  ) async {
    final rows = await _db.select(table).get();
    return rows.map(toJson).toList();
  }

  String _iso(DateTime date) => date.toIso8601String();
  String? _isoOrNull(DateTime? date) => date?.toIso8601String();

  dynamic _decode(String geoJson) {
    try {
      return jsonDecode(geoJson);
    } catch (_) {
      return geoJson;
    }
  }
}
