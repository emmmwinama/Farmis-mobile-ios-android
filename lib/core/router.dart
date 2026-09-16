import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/pin_setup_screen.dart';
import '../features/auth/pin_unlock_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/fields/fields_screen.dart';
import '../features/fields/field_detail_screen.dart';
import '../features/fields/field_form_screen.dart';
import '../models/activity_detail.dart';
import '../models/crop_field.dart';
import '../models/employee.dart';
import '../models/equipment.dart';
import '../models/field.dart';
import '../models/inventory_item.dart';
import '../models/livestock.dart';
import '../models/overhead.dart';
import '../models/transaction.dart';
import '../features/field_map/field_map_screen.dart';
import '../features/field_map/field_boundary_editor_screen.dart';
import '../features/crops/crops_screen.dart';
import '../features/crops/crop_detail_screen.dart';
import '../features/crops/crop_form_screen.dart';
import '../features/yields/yield_form_screen.dart';
import '../features/activities/activity_detail_screen.dart';
import '../features/activities/activity_form_screen.dart';
import '../features/seasons/seasons_provider.dart';
import '../features/finance/transaction_form_screen.dart';
import '../features/finance/overhead_form_screen.dart';
import '../features/activities/activities_screen.dart';
import '../features/finance/finance_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/import_screen.dart';
import '../features/profile/upgrade_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/employees/employees_screen.dart';
import '../features/employees/employee_form_screen.dart';
import '../features/templates/templates_screen.dart';
import '../features/records/records_screen.dart';
import '../features/hubs/capture_hub_screen.dart';
import '../features/farm/farm_screen.dart';
import '../features/money/money_screen.dart';
import '../features/seasons/seasons_screen.dart';
import '../features/equipment/equipment_screen.dart';
import '../features/equipment/equipment_form_screen.dart';
import '../features/equipment/equipment_detail_screen.dart';
import '../features/weather/weather_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/livestock/livestock_screen.dart';
import '../features/livestock/livestock_detail_screen.dart';
import '../features/livestock/animal_form_screen.dart';
import '../features/inventory/inventory_screen.dart';
import '../features/inventory/inventory_item_form_screen.dart';
import '../features/documents/documents_screen.dart';
import '../features/documents/document_form_screen.dart';
import '../features/compliance/compliance_screen.dart';
import '../features/compliance/traceability_screen.dart';
import '../features/compliance/credit_score_screen.dart';
import '../features/report_builder/report_builder_screen.dart';
import '../shared/widgets/agri_vault_shell.dart';
import 'auth/account_provider.dart';
import 'auth/pin_provider.dart';
import 'auth/secure_storage.dart';
import 'onboarding/onboarding_provider.dart';

/// Notifies go_router to re-run [redirect] whenever [accountProvider],
/// [pinProvider] or [onboardingProvider] changes, so signing in, completing
/// onboarding, or entering the correct PIN immediately re-evaluates routing
/// instead of only on the next manual navigation.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(accountProvider, (_, __) => notifyListeners());
    ref.listen(pinProvider, (_, __) => notifyListeners());
    ref.listen(onboardingProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: refreshNotifier,
    redirect: (context, state) async {
      final isLoggedIn = ref.read(accountProvider).isLoggedIn;
      final onLogin = state.matchedLocation == '/login';
      // No mobile register/password-reset endpoints exist — these are
      // informational screens reachable from /login while signed out, not
      // part of the gate below.
      final onAuthInfo = state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';
      if (!isLoggedIn) return (onLogin || onAuthInfo) ? null : '/login';

      final hasProfile = ref.read(onboardingProvider);
      final hasPin = await SecureStorage.hasPin();
      final isUnlocked = ref.read(pinProvider).isUnlocked;
      final onOnboarding = state.matchedLocation == '/onboarding';
      final onSetup  = state.matchedLocation == '/pin-setup';
      final onUnlock = state.matchedLocation == '/pin-unlock';

      if (!hasProfile) return onOnboarding ? null : '/onboarding';
      if (!hasPin) return onSetup ? null : '/pin-setup';
      if (!isUnlocked) return onUnlock ? null : '/pin-unlock';
      if (onLogin || onAuthInfo || onOnboarding || onSetup || onUnlock) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path:    '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path:    '/pin-setup',
        builder: (_, __) => const PinSetupScreen(),
      ),
      GoRoute(
        path:    '/pin-unlock',
        builder: (_, __) => const PinUnlockScreen(),
      ),
      // Signing in is mandatory (see the redirect above) — every data screen
      // reads from Ulimi's mobile API, which requires a session. The PIN
      // lock still gates on top of that, as a fast local re-unlock.
      GoRoute(
        path:    '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path:    '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path:    '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path:    '/upgrade',
        builder: (_, __) => const UpgradeScreen(),
      ),
      // Full-screen drill-down routes for Fields — deliberately outside the
      // ShellRoute (no bottom nav/rail while editing or viewing a single
      // field), matching how these screens looked when reached via
      // Navigator.push before this migration to go_router paths.
      GoRoute(
        path:    '/fields/new',
        builder: (_, state) => FieldFormScreen(existing: state.extra as FieldModel?),
      ),
      GoRoute(
        path:    '/fields/:id',
        builder: (_, state) =>
            FieldDetailScreen(fieldId: state.pathParameters['id']!),
      ),
      GoRoute(
        path:    '/fields/:id/boundary',
        builder: (_, state) =>
            FieldBoundaryEditorScreen(fieldId: state.pathParameters['id']!),
      ),
      GoRoute(
        path:    '/crops/new',
        builder: (_, state) => CropFormScreen(existing: state.extra as CropFieldModel?),
      ),
      GoRoute(
        path:    '/crops/:id',
        builder: (_, state) =>
            CropDetailScreen(cropId: state.pathParameters['id']!),
      ),
      GoRoute(
        path:    '/yields/new',
        builder: (_, state) => YieldFormScreen(
          preselectedCropFieldId: state.uri.queryParameters['cropFieldId'],
        ),
      ),
      GoRoute(
        path:    '/activities/new',
        builder: (_, state) => ActivityFormScreen(existing: state.extra as ActivityDetail?),
      ),
      GoRoute(
        path:    '/activities/:id',
        builder: (_, state) =>
            ActivityDetailScreen(activityId: state.pathParameters['id']!),
      ),
      GoRoute(
        path:    '/finance/new-transaction',
        builder: (_, state) => TransactionFormScreen(existing: state.extra as TransactionModel?),
      ),
      GoRoute(
        path:    '/finance/new-overhead',
        builder: (_, state) => OverheadFormScreen(existing: state.extra as OverheadExpense?),
      ),
      GoRoute(
        path:    '/animals/new',
        builder: (_, state) => AnimalFormScreen(existing: state.extra as Animal?),
      ),
      GoRoute(
        path:    '/animals/:id',
        builder: (_, state) =>
            AnimalDetailScreen(animalId: state.pathParameters['id']!),
      ),
      GoRoute(
        path:    '/documents/new',
        builder: (_, __) => const DocumentFormScreen(),
      ),
      GoRoute(
        path:    '/inventory/new',
        builder: (_, state) => InventoryItemFormScreen(existing: state.extra as InventoryItem?),
      ),
      GoRoute(
        path:    '/employees/new',
        builder: (_, state) => EmployeeFormScreen(existing: state.extra as EmployeeModel?),
      ),
      GoRoute(
        path:    '/equipment/new',
        builder: (_, state) => EquipmentFormScreen(existing: state.extra as EquipmentModel?),
      ),
      GoRoute(
        path:    '/equipment/:id',
        builder: (_, state) =>
            EquipmentDetailScreen(equipmentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path:    '/seasons/compare',
        builder: (_, state) => SeasonCompareScreen(
          pair: SeasonComparePair(
            state.uri.queryParameters['a']!,
            state.uri.queryParameters['b']!,
          ),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AgriVaultShell(child: child),
        routes: [
          GoRoute(
            path:    '/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path:    '/capture',
            builder: (_, __) => const CaptureHubScreen(),
          ),
          GoRoute(
            path:    '/farm',
            builder: (_, __) => const FarmScreen(),
          ),
          GoRoute(
            path:    '/livestock',
            builder: (_, __) => const LivestockScreen(),
          ),
          GoRoute(
            path:    '/money',
            builder: (_, __) => const MoneyScreen(),
          ),
          GoRoute(
            path:    '/fields',
            builder: (_, __) => const FieldsScreen(),
          ),
          GoRoute(
            path:    '/field-map',
            builder: (_, __) => const FieldMapScreen(),
          ),
          GoRoute(
            path:    '/crops',
            builder: (_, __) => const CropsScreen(),
          ),
          GoRoute(
            path:    '/activities',
            builder: (_, __) => const ActivitiesScreen(),
          ),
          GoRoute(
            path:    '/finance',
            builder: (_, __) => const FinanceScreen(),
          ),
          GoRoute(
            path:    '/reports',
            builder: (_, __) => const ReportsScreen(),
          ),
          GoRoute(
            path:    '/records',
            builder: (_, __) => const RecordsScreen(),
          ),
          GoRoute(
            path:    '/employees',
            builder: (_, __) => const EmployeesScreen(),
          ),
          GoRoute(
            path:    '/templates',
            builder: (_, __) => const TemplatesScreen(),
          ),
          GoRoute(
            path: '/inventory',
            builder: (_, __) => const InventoryScreen(),
          ),
          GoRoute(
            path: '/equipment',
            builder: (_, __) => const EquipmentScreen(),
          ),
          GoRoute(
            path: '/livestock-detail',
            builder: (_, __) => const LivestockScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/traceability',
            builder: (_, __) => const TraceabilityScreen(),
          ),
          GoRoute(
            path: '/credit-score',
            builder: (_, __) => const CreditScoreScreen(),
          ),
          GoRoute(
            path: '/weather',
            builder: (_, __) => const WeatherScreen(),
          ),
          GoRoute(
            path: '/documents',
            builder: (_, __) => const DocumentsScreen(),
          ),
          GoRoute(
            path: '/compliance',
            builder: (_, __) => const ComplianceScreen(),
          ),
          GoRoute(
            path: '/seasons',
            builder: (_, __) => const SeasonsScreen(),
          ),
          GoRoute(
            path: '/report-builder',
            builder: (_, __) => const ReportBuilderScreen(),
          ),
          GoRoute(
            path:    '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
          GoRoute(
            path:    '/import',
            builder: (_, __) => const ImportScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
