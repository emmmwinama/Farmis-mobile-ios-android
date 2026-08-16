import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../models/compliance.dart';

const _sprayActivityTypes = [
  'spraying',
  'pest control',
  'fertilizing',
  'fertilising',
];

class ComplianceRepository {
  ComplianceRepository(this._db);

  final AppDatabase _db;

  /// Sales linked to a crop's harvest. The backend chains through
  /// `harvestYield -> inventoryItem -> sales`, but nothing in the local
  /// inventory flow ever sets `inventoryItems.harvestYieldId` (there's no
  /// "convert yield to inventory" UI). The inventory screen does let you tag
  /// a new stock item with `cropFieldId` directly, and that's what actually
  /// gets populated when a farmer records a sale — so that's the join used
  /// here to keep the traceability/compliance signal meaningful locally.
  Future<List<InventorySaleRow>> _salesForCrop(String cropFieldId) async {
    final items = await (_db.select(_db.inventoryItems)
          ..where((t) => t.cropFieldId.equals(cropFieldId)))
        .get();
    final sales = <InventorySaleRow>[];
    for (final item in items) {
      sales.addAll(await (_db.select(_db.inventorySales)
            ..where((t) => t.inventoryItemId.equals(item.id)))
          .get());
    }
    return sales;
  }

  Future<ComplianceData> getCompliance() async {
    final crops = await _db.select(_db.cropFields).get();
    final documents = await _db.select(_db.farmDocuments).get();
    final boundaryCount =
        (await _db.select(_db.fieldBoundaries).get()).length;
    final markerCount = (await _db.select(_db.farmMarkers).get()).length;

    final lots = <Map<String, dynamic>>[];
    for (final crop in crops) {
      final field = await (_db.select(_db.fields)
            ..where((t) => t.id.equals(crop.fieldId)))
          .getSingleOrNull();
      final cropType = await (_db.select(_db.cropTypes)
            ..where((t) => t.id.equals(crop.cropTypeId)))
          .getSingleOrNull();
      final activities = await (_db.select(_db.activities)
            ..where((t) => t.cropFieldId.equals(crop.id)))
          .get();
      final yields = await (_db.select(_db.harvestYields)
            ..where((t) => t.cropFieldId.equals(crop.id)))
          .get();
      final sales = await _salesForCrop(crop.id);

      lots.add({
        'id': crop.id,
        'cropName': cropType?.name ?? 'Crop',
        'fieldName': field?.name ?? 'Field',
        'season': crop.season,
        'checklist': {
          'fieldMapped': boundaryCount > 0,
          'activitiesRecorded': activities.isNotEmpty,
          'harvestRecorded': yields.isNotEmpty,
          'salesLinked': sales.isNotEmpty,
          'documentsAttached': documents.any((d) =>
              d.linkedTo == crop.id || d.linkedType == 'crop'),
        },
      });
    }

    final buyerReadyLots = lots.where((lot) {
      final checklist = lot['checklist'] as Map<String, dynamic>;
      return checklist.values.where((v) => v == true).length >= 4;
    }).length;

    final checklist = [
      {
        'key': 'mappedFields',
        'label': 'Mapped field evidence',
        'passed': boundaryCount > 0,
        'value': boundaryCount,
      },
      {
        'key': 'farmMarkers',
        'label': 'Farm markers recorded',
        'passed': markerCount > 0,
        'value': markerCount,
      },
      {
        'key': 'cropLots',
        'label': 'Crop lots available',
        'passed': crops.isNotEmpty,
        'value': crops.length,
      },
      {
        'key': 'documents',
        'label': 'Documents uploaded',
        'passed': documents.isNotEmpty,
        'value': documents.length,
      },
      {
        'key': 'buyerReadyLots',
        'label': 'Buyer-ready traceability lots',
        'passed': buyerReadyLots > 0,
        'value': lots.length,
      },
    ];

    final passed = checklist.where((c) => c['passed'] == true).length;

    return ComplianceData.fromJson({
      'checklist': checklist,
      'lots': lots,
      'readinessPct': (passed / checklist.length * 100).round(),
    });
  }

  Future<List<TraceabilityLot>> getTraceability() async {
    final crops = await (_db.select(_db.cropFields)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();

    final lots = <Map<String, dynamic>>[];
    for (final crop in crops) {
      final field = await (_db.select(_db.fields)
            ..where((t) => t.id.equals(crop.fieldId)))
          .getSingleOrNull();
      final cropType = await (_db.select(_db.cropTypes)
            ..where((t) => t.id.equals(crop.cropTypeId)))
          .getSingleOrNull();
      final activities = await (_db.select(_db.activities)
            ..where((t) => t.cropFieldId.equals(crop.id)))
          .get();
      final sprayRecords = activities
          .where((a) =>
              _sprayActivityTypes.contains(a.activityType.toLowerCase()))
          .length;
      final yields = await (_db.select(_db.harvestYields)
            ..where((t) => t.cropFieldId.equals(crop.id)))
          .get();
      final sales = await _salesForCrop(crop.id);
      final revenue = sales.fold<double>(0, (s, sale) => s + sale.totalAmount);

      lots.add({
        'id': crop.id,
        'lotId': _lotId(crop, cropType?.name ?? 'Crop', field?.name ?? 'Field'),
        'cropName': cropType?.name ?? 'Crop',
        'variety': crop.variety,
        'fieldName': field?.name ?? 'Field',
        'season': crop.season,
        'status': crop.status,
        'activityCount': activities.length,
        'sprayRecordCount': sprayRecords,
        'harvestCount': yields.length,
        'saleCount': sales.length,
        'revenue': revenue,
        'checklist': {
          'activities': activities.isNotEmpty,
          'sprayRecords': sprayRecords > 0,
          'harvestLinked': yields.isNotEmpty,
          'salesLinked': sales.isNotEmpty,
          'buyerReady':
              activities.isNotEmpty && yields.isNotEmpty && sales.isNotEmpty,
        },
      });
    }

    return lots.map((json) => TraceabilityLot.fromJson(json)).toList();
  }

  String _code(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    return cleaned.substring(0, cleaned.length.clamp(0, 4));
  }

  String _lotId(CropField crop, String cropName, String fieldName) {
    final suffix = crop.id.length >= 5
        ? crop.id.substring(crop.id.length - 5).toUpperCase()
        : crop.id.toUpperCase();
    return '${crop.season}-${_code(fieldName)}-${_code(cropName)}-$suffix';
  }

  Future<CreditReadinessData> getCreditReadiness() async {
    final fieldCount = (await _db.select(_db.fields).get()).length;
    final cropCount = (await _db.select(_db.cropFields).get()).length;
    final transactions = await _db.select(_db.transactions).get();
    final documentCount = (await _db.select(_db.farmDocuments).get()).length;

    final income = transactions
        .where((t) => t.type == 'Income')
        .fold<double>(0, (s, t) => s + t.amount);
    final expense = transactions
        .where((t) => t.type == 'Expense')
        .fold<double>(0, (s, t) => s + t.amount);
    final net = income - expense;

    final checks = [
      {
        'key': 'fields',
        'label': 'Fields recorded',
        'passed': fieldCount > 0,
        'value': fieldCount,
      },
      {
        'key': 'crops',
        'label': 'Crop history',
        'passed': cropCount > 0,
        'value': cropCount,
      },
      {
        'key': 'transactions',
        'label': 'Finance records',
        'passed': transactions.length >= 3,
        'value': transactions.length,
      },
      {
        'key': 'documents',
        'label': 'Evidence documents',
        'passed': documentCount > 0,
        'value': documentCount,
      },
      {
        'key': 'profitability',
        'label': 'Positive net activity',
        'passed': net > 0,
        'value': net,
      },
    ];
    final passed = checks.where((c) => c['passed'] == true).length;
    final readinessScore = (passed / checks.length * 100).round();

    return CreditReadinessData.fromJson({
      'readinessScore': readinessScore,
      'grade': readinessScore >= 80
          ? 'A'
          : readinessScore >= 60
              ? 'B'
              : readinessScore >= 40
                  ? 'C'
                  : 'D',
      'checks': checks,
      'summary': {
        'fields': fieldCount,
        'crops': cropCount,
        'transactionCount': transactions.length,
        'documents': documentCount,
        'income': income,
        'expense': expense,
        'net': net,
      },
    });
  }
}
