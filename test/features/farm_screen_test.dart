import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/api/api_client.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/core/db/database_provider.dart';
import 'package:farmio_mobile/features/farm/farm_screen.dart';
import '../support/fake_mobile_api.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  // FarmScreen's IndexedStack builds every pill's screen eagerly (so tab
  // state survives switching), so every resource all five pills' screens
  // touch needs a fake here, not just whichever pill is on-screen at a
  // given moment — leaving one out doesn't fail loudly, it silently
  // sends a real request to the (unreachable in tests) production host,
  // which reads exactly like a hang.
  Widget wrap() => ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          apiClientProvider.overrideWithValue(fakeApiDio([
            FakeRestResource('/api/mobile/fields'),
            fakeCropsResource(),
            FakeRestResource('/api/mobile/employees'),
            FakeEquipmentResource('/api/mobile/equipment'),
            ...fakeLivestockResources(),
          ])),
        ],
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
