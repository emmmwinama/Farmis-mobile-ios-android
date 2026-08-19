import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/core/db/database_provider.dart';
import 'package:farmio_mobile/features/fields/fields_repository.dart';
import 'package:farmio_mobile/features/fields/fields_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  Widget wrap() {
    final router = GoRouter(
      initialLocation: '/fields',
      routes: [
        // Fields lives inside a ShellRoute in the real app, which gives it
        // its own nested Navigator distinct from the one showDialog's
        // default useRootNavigator:true pushes onto. A dialog whose buttons
        // pop with the wrong (outer) context pops that nested shell
        // Navigator instead of just the dialog — this shape is what
        // reproduces that.
        ShellRoute(
          builder: (context, state, child) => Scaffold(body: child),
          routes: [
            GoRoute(path: '/fields', builder: (_, __) => const FieldsScreen()),
          ],
        ),
      ],
    );
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets(
      'confirming delete from the popup menu removes the field without crashing the shell navigator',
      (tester) async {
    await FieldsRepository(db).createField({
      'name': 'North block',
      'totalArea': 4.0,
      'cultivatableArea': 3.5,
      'soilType': 'Loam',
    });

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('North block'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // The confirmation dialog's own "Delete" button.
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('North block'), findsNothing);
    expect(find.byType(FieldsScreen), findsOneWidget);
  });
}
