import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/core/db/database_provider.dart';
import 'package:farmio_mobile/features/farm/farm_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  Widget wrap() => ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: FarmScreen()),
      );

  testWidgets('renders all 5 section pills', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    for (final label in ['Fields', 'Crops', 'Livestock', 'Equipment', 'Employees']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('lands on Fields by default', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('No fields yet'), findsOneWidget);
  });

  testWidgets('tapping Crops switches to the crops empty state', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crops'));
    await tester.pumpAndSettle();

    expect(find.text('No crops match your filters'), findsOneWidget);
  });
}
