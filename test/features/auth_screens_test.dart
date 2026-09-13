import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:farmio_mobile/features/auth/login_screen.dart';
import 'package:farmio_mobile/features/auth/register_screen.dart';
import 'package:farmio_mobile/features/auth/forgot_password_screen.dart';

// LoginScreen's validation is covered here (client-side, short-circuits
// before any network call). RegisterScreen/ForgotPasswordScreen have no
// form at all — there's no mobile register or password-reset endpoint, so
// they just point to the web app; covered by presence checks only.
void main() {
  Widget wrap(Widget home) => ProviderScope(
        child: MaterialApp.router(
          routerConfig: GoRouter(routes: [
            GoRoute(path: '/', builder: (_, __) => home),
            GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('Login screen'))),
          ]),
        ),
      );

  group('LoginScreen', () {
    testWidgets('rejects an invalid email format before calling the API', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreen()));
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'not-an-email');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email and password.'), findsOneWidget);
    });

    testWidgets('has a Forgot password link', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreen()));
      expect(find.text('Forgot password?'), findsOneWidget);
    });
  });

  group('RegisterScreen', () {
    testWidgets('points to the web app instead of a form', (tester) async {
      await tester.pumpWidget(wrap(const RegisterScreen()));
      expect(find.text('Create your account on the web'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('ForgotPasswordScreen', () {
    testWidgets('points to the web app instead of a form', (tester) async {
      await tester.pumpWidget(wrap(const ForgotPasswordScreen()));
      expect(find.text('Reset your password on the web'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });
  });
}
