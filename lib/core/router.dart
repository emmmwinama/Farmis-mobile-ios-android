import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/pin_setup_screen.dart';
import '../features/auth/pin_unlock_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/fields/fields_screen.dart';
import '../features/fields/field_detail_screen.dart';
import '../features/fields/field_form_screen.dart';
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
import 'auth/pin_provider.dart';
import 'auth/secure_storage.dart';
import 'onboarding/onboarding_provider.dart';

/// Notifies go_router to re-run [redirect] whenever [pinProvider] or
/// [onboardingProvider] changes, so completing onboarding or entering the
/// correct PIN immediately re-evaluates routing instead of only on the
/// next manual navigation.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(pinProvider, (_, __) => notifyListeners());
    ref.listen(onboardingProvider, (prev, next) {
      debugPrint('ONBOARDING_DEBUG: onboardingProvider changed $prev -> $next');
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: refreshNotifier,
    redirect: (context, state) async {
      final hasProfile = ref.read(onboardingProvider);
      final hasPin = await SecureStorage.hasPin();
      final isUnlocked = ref.read(pinProvider).isUnlocked;
      final onOnboarding = state.matchedLocation == '/onboarding';
      final onSetup  = state.matchedLocation == '/pin-setup';
      final onUnlock = state.matchedLocation == '/pin-unlock';
      debugPrint('ONBOARDING_DEBUG: redirect eval loc=${state.matchedLocation} '
          'hasProfile=$hasProfile hasPin=$hasPin isUnlocked=$isUnlocked');

      if (!hasProfile) return onOnboarding ? null : '/onboarding';
      if (!hasPin) return onSetup ? null : '/pin-setup';
      if (!isUnlocked) return onUnlock ? null : '/pin-unlock';
      if (onOnboarding || onSetup || onUnlock) return '/dashboard';
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
      // Account sign-in is optional and layered on top of the PIN-gated
      // local flow — reached only via the Profile screen's "Account & Sync"
      // section, never part of the redirect chain above.
      GoRoute(
        path:    '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path:    '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      // Full-screen drill-down routes for Fields — deliberately outside the
      // ShellRoute (no bottom nav/rail while editing or viewing a single
      // field), matching how these screens looked when reached via
      // Navigator.push before this migration to go_router paths.
      GoRoute(
        path:    '/fields/new',
        builder: (_, __) => const FieldFormScreen(),
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
        builder: (_, __) => const CropFormScreen(),
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
        builder: (_, __) => const ActivityFormScreen(),
      ),
      GoRoute(
        path:    '/activities/:id',
        builder: (_, state) =>
            ActivityDetailScreen(activityId: state.pathParameters['id']!),
      ),
      GoRoute(
        path:    '/finance/new-transaction',
        builder: (_, __) => const TransactionFormScreen(),
      ),
      GoRoute(
        path:    '/finance/new-overhead',
        builder: (_, __) => const OverheadFormScreen(),
      ),
      GoRoute(
        path:    '/animals/new',
        builder: (_, __) => const AnimalFormScreen(),
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
        builder: (_, __) => const InventoryItemFormScreen(),
      ),
      GoRoute(
        path:    '/employees/new',
        builder: (_, __) => const EmployeeFormScreen(),
      ),
      GoRoute(
        path:    '/equipment/new',
        builder: (_, __) => const EquipmentFormScreen(),
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
