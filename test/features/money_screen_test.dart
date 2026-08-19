import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/core/db/database_provider.dart';
import 'package:farmio_mobile/features/money/money_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  Widget wrap() => ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: MoneyScreen()),
      );

  testWidgets('renders all 3 section pills', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    for (final label in ['Finance', 'Inventory', 'Credit']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('lands on Finance by default', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('No transactions yet'), findsOneWidget);
  });

  testWidgets('tapping Inventory switches to the inventory empty state', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Inventory'));
    await tester.pumpAndSettle();

    expect(find.text('No inventory items yet.'), findsOneWidget);
  });
}
