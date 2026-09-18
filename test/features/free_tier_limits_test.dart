import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:farmio_mobile/core/api/api_client.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/core/db/database_provider.dart';
import 'package:farmio_mobile/core/limits/free_tier_limits.dart';
import 'package:farmio_mobile/features/fields/fields_repository.dart';
import 'package:farmio_mobile/features/fields/fields_screen.dart';
import '../support/fake_mobile_api.dart';

void main() {
  late AppDatabase db;
  late FieldsRepository fieldsRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    fieldsRepo = FieldsRepository(db, fakeApiDio([FakeRestResource('/api/mobile/fields')]));
  });

  tearDown(() async => db.close());

  Future<void> seedFields(int count) async {
    for (var i = 0; i < count; i++) {
      await fieldsRepo.createField({
        'name': 'Field $i',
        'totalArea': 4.0,
        'cultivatableArea': 3.5,
        'soilType': 'Loam',
      });
    }
  }

  Widget wrap({required List<Override> overrides}) {
    final router = GoRouter(
      initialLocation: '/fields',
      routes: [
        ShellRoute(
          builder: (context, state, child) => Scaffold(body: child),
          routes: [
            GoRoute(path: '/fields', builder: (_, __) => const FieldsScreen()),
            GoRoute(path: '/fields/new', builder: (_, __) => const Scaffold(body: Text('New field form'))),
            GoRoute(path: '/profile', builder: (_, __) => const Scaffold(body: Text('Profile'))),
          ],
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        apiClientProvider.overrideWithValue(fakeApiDio([FakeRestResource('/api/mobile/fields')])),
        ...overrides,
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('tapping add is blocked with an upgrade sheet once the free field limit is reached',
      (tester) async {
    await tester.runAsync(() => seedFields(FreeTierLimits.maxFields));

    await tester.pumpWidget(wrap(overrides: []));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text("You've reached your Free plan limit"), findsOneWidget);
    expect(find.text('New field form'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping add proceeds normally while under the free field limit', (tester) async {
    await tester.runAsync(() => seedFields(FreeTierLimits.maxFields - 1));

    await tester.pumpWidget(wrap(overrides: []));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('New field form'), findsOneWidget);
    expect(find.text("You've reached your Free plan limit"), findsNothing);
  });
}
