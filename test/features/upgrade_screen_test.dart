import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:farmio_mobile/core/auth/account_models.dart';
import 'package:farmio_mobile/core/auth/account_provider.dart';
import 'package:farmio_mobile/core/auth/farm_context_models.dart';
import 'package:farmio_mobile/features/profile/upgrade_screen.dart';

// There's no mobile checkout or subscription-status endpoint yet — the
// screen just points a signed-in user to the web dashboard, and a
// signed-out one to /login. See upgrade_screen.dart's doc comment.
void main() {
  Widget wrap({List<Override> overrides = const []}) => ProviderScope(
        overrides: overrides,
        child: MaterialApp.router(
          routerConfig: GoRouter(routes: [
            GoRoute(path: '/', builder: (_, __) => const UpgradeScreen()),
            GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('Login screen'))),
          ]),
        ),
      );

  Override signedInAs(AccountUser user) => accountProvider.overrideWith((ref) {
        final notifier = AccountNotifier(ref);
        // ignore: invalid_use_of_protected_member
        notifier.state = AccountState(
          hydrated: true,
          user: user,
          farmContext: const FarmContext(activeFarmId: 'f1', role: 'owner', farms: []),
        );
        return notifier;
      });

  testWidgets('signed out prompts to sign in', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Sign in first'), findsOneWidget);
    expect(find.text('Manage your plan on the web'), findsNothing);
  });

  testWidgets('signed in points to the web dashboard', (tester) async {
    const user = AccountUser(id: 'u1', name: 'Jane', email: 'jane@example.com');

    await tester.pumpWidget(wrap(overrides: [signedInAs(user)]));
    await tester.pumpAndSettle();

    expect(find.text('Manage your plan on the web'), findsOneWidget);
    expect(find.text('Sign in first'), findsNothing);
  });
}
