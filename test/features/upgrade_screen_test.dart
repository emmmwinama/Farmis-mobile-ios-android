import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:farmio_mobile/core/auth/account_models.dart';
import 'package:farmio_mobile/core/auth/account_provider.dart';
import 'package:farmio_mobile/features/profile/upgrade_screen.dart';

// Covers only what renders from account state — checkout itself needs a
// live Dio call (see AccountRepository.startCheckout), so the buttons here
// are checked for presence, never tapped.
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

  Override signedInAs(Account account) => accountProvider.overrideWith((ref) {
        final notifier = AccountNotifier(ref);
        // ignore: invalid_use_of_protected_member
        notifier.state = AccountState(hydrated: true, account: account);
        return notifier;
      });

  testWidgets('signed out prompts to sign in instead of showing plans', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Sign in first'), findsOneWidget);
    expect(find.text('Choose a plan'), findsNothing);
  });

  testWidgets('signed in on the free tier shows both plans', (tester) async {
    final freeAccount = Account(
      user: const AccountUser(id: 'u1', name: 'Jane', email: 'jane@example.com'),
      farm: const AccountFarm(id: 'f1', name: 'Jane Farm'),
      subscription: const AccountSubscription(status: 'active', tierName: 'Mobile Free'),
    );

    await tester.pumpWidget(wrap(overrides: [signedInAs(freeAccount)]));
    await tester.pumpAndSettle();

    expect(find.text('Choose a plan'), findsOneWidget);
    expect(find.text('Subscribe'), findsOneWidget);
    expect(find.text('Buy'), findsOneWidget);
    expect(find.text('\$5'), findsOneWidget);
    expect(find.text('\$30'), findsOneWidget);
  });

  testWidgets('signed in on a paid tier shows the already-upgraded state', (tester) async {
    final paidAccount = Account(
      user: const AccountUser(id: 'u1', name: 'Jane', email: 'jane@example.com'),
      farm: const AccountFarm(id: 'f1', name: 'Jane Farm'),
      subscription: const AccountSubscription(status: 'active', tierName: 'Mobile Monthly'),
    );

    await tester.pumpWidget(wrap(overrides: [signedInAs(paidAccount)]));
    await tester.pumpAndSettle();

    expect(find.text("You're already upgraded"), findsOneWidget);
    expect(find.text('Choose a plan'), findsNothing);
  });
}
