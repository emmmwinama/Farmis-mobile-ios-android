import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:farmio_mobile/shared/widgets/agri_vault_shell.dart';

// Ground-truth check: does a screen's own default-positioned FAB actually
// land above the floating pill on screen, not underneath it? The shell's
// extendBody/MediaQuery setup is indirect enough (multiple nested MediaQuery
// layers, Scaffold's own internal padding-removal rules) that reasoning
// about it in the abstract isn't trustworthy — measure the real rendered
// positions instead.
void main() {
  testWidgets("a screen's own FAB sits above the pill, not underneath it", (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/fields',
      routes: [
        ShellRoute(
          builder: (context, state, child) => AgriVaultShell(child: child),
          routes: [
            GoRoute(
              path: '/fields',
              builder: (_, __) => Scaffold(
                body: const Center(child: Text('Fields')),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(ProviderScope(child: MaterialApp.router(routerConfig: router)));
    await tester.pumpAndSettle();

    final fabRect = tester.getRect(find.byType(FloatingActionButton));
    // The pill is the rounded Container inside bottomNavigationBar — find it
    // by its BoxDecoration's borderRadius(28), which is distinctive to it.
    final pillFinder = find.byWidgetPredicate((w) =>
        w is Container &&
        w.decoration is BoxDecoration &&
        (w.decoration as BoxDecoration).borderRadius == BorderRadius.circular(28) &&
        (w.decoration as BoxDecoration).boxShadow != null);
    final pillRect = tester.getRect(pillFinder.first);

    expect(
      fabRect.bottom,
      lessThanOrEqualTo(pillRect.top),
      reason: 'FAB bottom edge (${fabRect.bottom}) overlaps the pill '
          '(top at ${pillRect.top}) instead of sitting above it',
    );
  });
}
