import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/core/db/database_provider.dart';
import 'package:farmio_mobile/features/activities/activities_repository.dart';
import 'package:farmio_mobile/features/fields/fields_repository.dart';
import 'package:farmio_mobile/features/finance/finance_repository.dart';
import 'package:farmio_mobile/features/finance/finance_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  Widget wrap() => ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: FinanceScreen()),
      );

  testWidgets(
      'Summary tab folds field-activity labour/input costs into total expenses',
      (tester) async {
    final field = await FieldsRepository(db).createField({
      'name': 'North block',
      'totalArea': '5',
      'cultivatableArea': '4',
      'soilType': 'Loam',
    });
    // A field-only activity (no cropFieldId) — exercises the "ALL
    // activities, not just crop-tied ones" behaviour the Finance activity
    // cost total is meant to cover.
    await ActivitiesRepository(db).createActivity({
      'activityType': 'Weeding',
      'fieldId': field.id,
      'date': DateTime.now().toIso8601String(),
      'inputs': [
        {
          'inputName': 'Herbicide',
          'category': 'Herbicide',
          'quantity': '2',
          'unit': 'L',
          'unitCost': '15000',
        },
      ],
      'otherCosts': [],
    });
    await FinanceRepository(db).createTransaction({
      'type': 'Income',
      'category': 'Crop sales',
      'amount': '100000',
      'date': DateTime.now().toIso8601String(),
      'description': 'Sale',
    });

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();

    expect(find.text('Activity costs'), findsWidgets);
    // 30,000 = 2L x 15,000/L herbicide cost, must show up as an expense
    // component even though it was never entered as a transaction.
    expect(find.textContaining('30,000'), findsWidgets);
  });
}
