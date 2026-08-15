import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/fields/fields_screen.dart';
import '../features/field_map/field_map_screen.dart';
import '../features/crops/crops_screen.dart';
import '../features/activities/activities_screen.dart';
import '../features/finance/finance_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/subscriptions/subscriptions_screen.dart';
import '../features/employees/employees_screen.dart';
import '../features/templates/templates_screen.dart';
import '../features/functions/farmis_functions_screen.dart';
import '../features/functions/mobile_function_detail_screen.dart';
import '../features/records/records_screen.dart';
import '../features/hubs/capture_hub_screen.dart';
import '../features/seasons/seasons_screen.dart';
import '../features/team/team_screen.dart';
import '../features/equipment/equipment_screen.dart';
import '../features/weather/weather_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/livestock/livestock_screen.dart';
import '../features/inventory/inventory_screen.dart';
import '../features/documents/documents_screen.dart';
import '../features/compliance/compliance_screen.dart';
import '../features/compliance/traceability_screen.dart';
import '../features/compliance/credit_score_screen.dart';
import '../features/report_builder/report_builder_screen.dart';
import '../shared/widgets/agri_vault_shell.dart';
import 'auth/auth_provider.dart';
import 'auth/secure_storage.dart';

/// Notifies go_router to re-run [redirect] whenever [authProvider] changes,
/// so a forced logout (e.g. a 401 response) kicks the user back to /login
/// immediately instead of only on the next manual navigation.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: refreshNotifier,
    redirect: (context, state) async {
      final loggedIn = await SecureStorage.isLoggedIn();
      final onLogin  = state.matchedLocation == '/login';
      if (!loggedIn && !onLogin) return '/login';
      if (loggedIn  &&  onLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path:    '/login',
        builder: (_, __) => const LoginScreen(),
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
            builder: (_, __) => const FarmHubScreen(),
          ),
          GoRoute(
            path:    '/business',
            builder: (_, __) => const BusinessHubScreen(),
          ),
          GoRoute(
            path:    '/livestock',
            builder: (_, __) => const LivestockHubScreen(),
          ),
          GoRoute(
            path:    '/insights',
            builder: (_, __) => const InsightsHubScreen(),
          ),
          GoRoute(
            path:    '/more',
            builder: (_, __) => const MoreHubScreen(),
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
            path:    '/functions',
            builder: (_, __) => const FarmisFunctionsScreen(),
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
            path: '/ai-insights',
            builder: (_, __) => const MobileFunctionDetailScreen(
              kind: MobileFunctionKind.aiInsights,
            ),
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
            path: '/team',
            builder: (_, __) => const TeamScreen(),
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
            path: '/graph-catalog',
            builder: (_, __) => const MobileFunctionDetailScreen(
              kind: MobileFunctionKind.graphCatalog,
            ),
          ),
          GoRoute(
            path: '/mobile-api',
            builder: (_, __) => const MobileFunctionDetailScreen(
              kind: MobileFunctionKind.mobileApi,
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const MobileFunctionDetailScreen(
              kind: MobileFunctionKind.settings,
            ),
          ),
          GoRoute(
            path:    '/subscriptions',
            builder: (_, __) => const SubscriptionsScreen(),
          ),
          GoRoute(
            path:    '/profile',
            builder: (_, __) => const ProfileScreen(),
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
