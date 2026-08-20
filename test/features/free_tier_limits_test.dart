import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:farmio_mobile/core/auth/account_models.dart';
import 'package:farmio_mobile/core/auth/account_provider.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/core/db/database_provider.dart';
import 'package:farmio_mobile/core/limits/free_tier_limits.dart';
import 'package:farmio_mobile/features/fields/fields_repository.dart';
import 'package:farmio_mobile/features/fields/fields_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  Future<void> seedFields(int count) async {
    final repo = FieldsRepository(db);
    for (var i = 0; i < count; i++) {
      await repo.createField({
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
      overrides: [databaseProvider.overrideWithValue(db), ...overrides],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('tapping add is blocked with an upgrade sheet once the free field limit is reached',
      (tester) async {
    await seedFields(FreeTierLimits.maxFields);

    await tester.pumpWidget(wrap(overrides: []));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text("You've reached your Free plan limit"), findsOneWidget);
    expect(find.text('New field form'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping add proceeds normally while under the free field limit', (tester) async {
    await seedFields(FreeTierLimits.maxFields - 1);

    await tester.pumpWidget(wrap(overrides: []));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('New field form'), findsOneWidget);
    expect(find.text("You've reached your Free plan limit"), findsNothing);
  });

  testWidgets('a paid account is never blocked, even past the free field limit', (tester) async {
    await seedFields(FreeTierLimits.maxFields + 3);

    final premiumAccount = Account(
      user: const AccountUser(id: 'u1', name: 'Jane', email: 'jane@example.com'),
      farm: const AccountFarm(id: 'f1', name: 'Jane Farm'),
      subscription: const AccountSubscription(status: 'active', tierName: 'Mobile Monthly'),
    );

    await tester.pumpWidget(wrap(overrides: [
      accountProvider.overrideWith((ref) {
        final notifier = AccountNotifier(ref);
        // ignore: invalid_use_of_protected_member
        notifier.state = AccountState(hydrated: true, account: premiumAccount);
        return notifier;
      }),
    ]));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('New field form'), findsOneWidget);
    expect(find.text("You've reached your Free plan limit"), findsNothing);
  });
}
