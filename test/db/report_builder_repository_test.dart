import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/report_builder/report_builder_repository.dart';
import 'package:farmio_mobile/features/report_builder/pdf_export_service.dart';
import 'package:farmio_mobile/features/fields/fields_repository.dart';
import 'package:farmio_mobile/features/crops/crops_repository.dart';
import 'package:farmio_mobile/features/finance/finance_repository.dart';
import 'package:farmio_mobile/features/reports/reports_repository.dart';
import 'package:farmio_mobile/shared/filters/report_record_filters.dart';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.dir);
  final Directory dir;

  @override
  Future<String?> getTemporaryPath() async => dir.path;
}

void main() {
  late AppDatabase db;
  late ReportBuilderRepository repo;
  late FieldsRepository fields;
  late CropsRepository crops;
  late FinanceRepository finance;
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('report_builder_test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir);
    db = AppDatabase(NativeDatabase.memory());
    repo = ReportBuilderRepository(db);
    fields = FieldsRepository(db);
    crops = CropsRepository(db);
    finance = FinanceRepository(db);
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('getReportBuilder ranks crops by net profit descending', () async {
    final field = await fields.createField({
      'name': 'North Field',
      'totalArea': '10',
      'cultivatableArea': '9',
      'soilType': 'Loam',
    });
    final cropType = await crops.createCropType('Maize');
    final profitable = await crops.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': field.id,
      'variety': 'Profitable',
      'areaPlanted': '2',
      'season': '2026 Rain',
      'plantingDate': DateTime(2026, 1, 1).toIso8601String(),
      'expectedHarvestDate': DateTime(2026, 5, 1).toIso8601String(),
    });
    final unprofitable = await crops.createCrop({
      'cropTypeId': cropType.id,
      'fieldId': field.id,
      'variety': 'Unprofitable',
      'areaPlanted': '2',
      'season': '2026 Rain',
      'plantingDate': DateTime(2026, 1, 1).toIso8601String(),
      'expectedHarvestDate': DateTime(2026, 5, 1).toIso8601String(),
    });

    await finance.createTransaction({
      'type': 'Income',
      'category': 'Crop sales',
      'amount': '200000',
      'date': DateTime(2026, 5, 1).toIso8601String(),
      'description': 'Sale',
      'cropFieldId': profitable.id,
    });
    await finance.createTransaction({
      'type': 'Income',
      'category': 'Crop sales',
      'amount': '1000',
      'date': DateTime(2026, 5, 1).toIso8601String(),
      'description': 'Sale',
      'cropFieldId': unprofitable.id,
    });

    final data = await repo.getReportBuilder();

    expect(data.cropProfitability, hasLength(2));
    expect(data.cropProfitability.first.variety, 'Profitable');
    expect(data.cropProfitability.first.netProfit, 200000);
    expect(data.fields, hasLength(1));
    expect(data.fields.first.crops, 2);
  });

  test('exportPdf writes a non-empty PDF file to a temp path', () async {
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
      'areaPlanted': '2',
      'season': '2026 Rain',
      'plantingDate': DateTime(2026, 1, 1).toIso8601String(),
      'expectedHarvestDate': DateTime(2026, 5, 1).toIso8601String(),
    });

    final path = await repo.exportPdf(['season', 'crop']);

    final file = File(path);
    expect(file.existsSync(), isTrue);
    expect(file.lengthSync(), greaterThan(0));
  });

  test('buildReportPdf produces valid PDF bytes with an empty report', () async {
    final reportsRepo = ReportsRepository(db);
    final data = await reportsRepo.getReport(const ReportRecordFilters());

    final bytes = await buildReportPdf(
      farmName: 'Test Farm',
      data: data,
      filters: const ReportRecordFilters(),
      sections: {'season', 'crop', 'field', 'cropField', 'labour', 'inputs', 'yields'},
    );

    expect(bytes, isNotEmpty);
    // PDF files start with the "%PDF-" magic bytes.
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
