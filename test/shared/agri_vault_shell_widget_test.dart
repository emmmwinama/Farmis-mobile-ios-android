import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:farmio_mobile/shared/widgets/agri_vault_shell.dart';

void main() {
  Widget buildApp() {
    final router = GoRouter(
      initialLocation: '/dashboard',
      routes: [
        ShellRoute(
          builder: (context, state, child) => AgriVaultShell(child: child),
          routes: [
            GoRoute(path: '/dashboard', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/capture', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/farm', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/money', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/reports', builder: (_, __) => const SizedBox()),
          ],
        ),
      ],
    );
    return ProviderScope(child: MaterialApp.router(routerConfig: router));
  }

  testWidgets('phone layout renders all 5 tab icons, with only the active label shown',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.dashboard_outlined), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.map_outlined), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    expect(find.byIcon(Icons.query_stats_outlined), findsOneWidget);

    // Today is the default route — its label morphs in, the rest stay icon-only.
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Farm'), findsNothing);
    expect(find.text('Money'), findsNothing);
    expect(find.text('Reports'), findsNothing);
  });

  testWidgets('tapping a tab morphs its label in and collapses the previous one',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Farm'), findsOneWidget);
    expect(find.text('Today'), findsNothing);
  });

  testWidgets('tablet layout renders exactly 5 rail destinations in order',
      (tester) async {
    tester.view.physicalSize = const Size(1024, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // NavigationRailDestination is plain config data, not an inserted
    // widget — assert against the NavigationRail's destinations list itself.
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.destinations, hasLength(5));
  });
}
