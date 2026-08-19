import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/core/db/database_provider.dart';
import 'package:farmio_mobile/features/inventory/inventory_repository.dart';
import 'package:farmio_mobile/features/inventory/inventory_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  Widget wrap() => ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: InventoryScreen()),
      );

  testWidgets('selecting a category filter hides items from other categories',
      (tester) async {
    final repo = InventoryRepository(db);
    await repo.createItem({
      'name': 'Maize bags',
      'category': 'Grain',
      'unit': 'bag',
      'quantity': '40',
    });
    await repo.createItem({
      'name': 'DAP fertilizer',
      'category': 'Input',
      'unit': 'kg',
      'quantity': '200',
    });

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Maize bags'), findsOneWidget);
    expect(find.text('DAP fertilizer'), findsOneWidget);

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grain').last);
    await tester.pumpAndSettle();

    expect(find.text('Maize bags'), findsOneWidget);
    expect(find.text('DAP fertilizer'), findsNothing);
  });
}
