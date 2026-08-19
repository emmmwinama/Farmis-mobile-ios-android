import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/core/db/database_provider.dart';
import 'package:farmio_mobile/features/reports/reports_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  Widget wrap() {
    final router = GoRouter(
      initialLocation: '/reports',
      routes: [
        GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
        GoRoute(path: '/records', builder: (_, __) => const Text('records-screen')),
        GoRoute(path: '/compliance', builder: (_, __) => const Text('compliance-screen')),
        GoRoute(path: '/traceability', builder: (_, __) => const Text('traceability-screen')),
        GoRoute(path: '/report-builder', builder: (_, __) => const Text('report-builder-screen')),
        GoRoute(path: '/weather', builder: (_, __) => const Text('weather-screen')),
        GoRoute(path: '/seasons', builder: (_, __) => const Text('seasons-screen')),
        GoRoute(path: '/templates', builder: (_, __) => const Text('templates-screen')),
      ],
    );
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('renders a quick-link chip for every secondary destination',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    for (final label in [
      'Records',
      'Compliance',
      'Traceability',
      'Report builder',
      'Weather',
      'Seasons',
      'Templates',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('tapping a quick link navigates to its route', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Seasons'),
      find.byKey(const Key('reports_quick_links_scroll')),
      const Offset(-100, 0),
    );
    await tester.tap(find.text('Seasons'));
    await tester.pumpAndSettle();

    expect(find.text('seasons-screen'), findsOneWidget);
  });
}
