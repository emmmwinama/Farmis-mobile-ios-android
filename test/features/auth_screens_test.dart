import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:farmio_mobile/features/auth/login_screen.dart';
import 'package:farmio_mobile/features/auth/register_screen.dart';
import 'package:farmio_mobile/features/auth/forgot_password_screen.dart';

// These cover only client-side validation, which short-circuits before any
// network call — no dio/account-provider mocking needed since the
// repository is never reached when validation fails.
void main() {
  Widget wrap(Widget home) => ProviderScope(
        child: MaterialApp.router(
          routerConfig: GoRouter(routes: [GoRoute(path: '/', builder: (_, __) => home)]),
        ),
      );

  // RegisterScreen's form (5 fields + terms checkbox + button) is taller
  // than the default 800x600 test surface, which pushes the submit button
  // out of the hit-testable viewport — widen it for every test in this file.
  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(800, 1600);
    binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
    addTearDown(() {
      binding.platformDispatcher.views.first.resetPhysicalSize();
      binding.platformDispatcher.views.first.resetDevicePixelRatio();
    });
  });

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
    Future<void> fillValidFields(WidgetTester tester) async {
      await tester.enterText(find.widgetWithText(TextField, 'Your name'), 'Jane Farmer');
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'jane@example.com');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
    }

    testWidgets('rejects mismatched passwords', (tester) async {
      await tester.pumpWidget(wrap(const RegisterScreen()));
      await fillValidFields(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Confirm password'), 'different123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create account'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });

    testWidgets('requires terms acceptance before submitting', (tester) async {
      await tester.pumpWidget(wrap(const RegisterScreen()));
      await fillValidFields(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Confirm password'), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create account'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please accept the Terms of Service and Privacy Policy to continue.'),
        findsOneWidget,
      );
    });

    testWidgets('has a Farm name field', (tester) async {
      await tester.pumpWidget(wrap(const RegisterScreen()));
      expect(find.text('Farm name (optional)'), findsOneWidget);
    });
  });

  group('ForgotPasswordScreen', () {
    testWidgets('rejects an empty/invalid email before requesting a code', (tester) async {
      await tester.pumpWidget(wrap(const ForgotPasswordScreen()));
      await tester.tap(find.text('Send reset code'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
    });
  });
}
