import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/core/db/database_provider.dart';
import 'package:farmio_mobile/core/limits/free_tier_limits.dart';
import 'package:farmio_mobile/features/crops/crop_form_screen.dart';
import 'package:farmio_mobile/features/crops/crops_repository.dart';
import 'package:farmio_mobile/features/fields/fields_repository.dart';
import 'package:farmio_mobile/models/crop_type.dart';

void main() {
  late AppDatabase db;
  late String fieldId;
  late CropType cropType;

  const season = '2024/25';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final field = await FieldsRepository(db).createField({
      'name': 'North block',
      'totalArea': 10.0,
      'cultivatableArea': 9.0,
      'soilType': 'Loam',
    });
    fieldId = field.id;
    cropType = await CropsRepository(db).createCropType('Maize');
  });

  tearDown(() async => db.close());

  Widget wrap() {
    final router = GoRouter(
      initialLocation: '/crops/new',
      routes: [GoRoute(path: '/crops/new', builder: (_, __) => const CropFormScreen())],
    );
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> fillAndSave(WidgetTester tester) async {
    // The form is taller than the default 800x600 test surface, which makes
    // the dropdowns/save button land outside the hit-testable viewport —
    // widen it so everything is reachable without manual scrolling.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpAndSettle();

    // warnIfMissed: false — the dropdown's InputDecorator chrome receives
    // the hit-test-level tap ahead of the Text it's wrapping, which is
    // benign (the dropdown opens either way) but noisy in test output.
    await tester.tap(find.text('Select field'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('North block').last, warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select crop type'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Maize').last, warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'e.g. SC403, Chitedze'), 'SC403');
    await tester.enterText(find.widgetWithText(TextField, '1.5'), '1.0');
    await tester.enterText(find.widgetWithText(TextField, '2024/25'), season);

    await tester.tap(find.text('Save crop'));
    await tester.pumpAndSettle();
  }

  testWidgets('saving is blocked with an upgrade sheet once the season hits the free crop limit',
      (tester) async {
    for (var i = 0; i < FreeTierLimits.maxCropFieldsPerSeason; i++) {
      await CropsRepository(db).createCrop({
        'fieldId': fieldId,
        'cropTypeId': cropType.id,
        'variety': 'Existing $i',
        'areaPlanted': '1.0',
        'season': season,
        'plantingDate': DateTime.now().toIso8601String(),
        'expectedHarvestDate': DateTime.now().toIso8601String(),
      });
    }

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await fillAndSave(tester);

    expect(find.text("You've reached your Free plan limit"), findsOneWidget);
    expect(find.byType(CropFormScreen), findsOneWidget);

    final crops = await CropsRepository(db).getCrops(archived: 'false');
    expect(crops.where((c) => c.season == season).length, FreeTierLimits.maxCropFieldsPerSeason);
  });

  testWidgets('saving proceeds normally while under the free per-season crop limit', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await fillAndSave(tester);

    expect(find.text("You've reached your Free plan limit"), findsNothing);

    final crops = await CropsRepository(db).getCrops(archived: 'false');
    expect(crops.where((c) => c.season == season).length, 1);
  });
}
