import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/pin_setup_screen.dart';
import '../features/auth/pin_unlock_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/fields/fields_screen.dart';
import '../features/field_map/field_map_screen.dart';
import '../features/crops/crops_screen.dart';
import '../features/activities/activities_screen.dart';
import '../features/finance/finance_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/import_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/employees/employees_screen.dart';
import '../features/templates/templates_screen.dart';
import '../features/records/records_screen.dart';
import '../features/hubs/capture_hub_screen.dart';
import '../features/seasons/seasons_screen.dart';
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
import 'auth/pin_provider.dart';
import 'auth/secure_storage.dart';

/// Notifies go_router to re-run [redirect] whenever [pinProvider] changes,
/// so entering the correct PIN (or resetting it) immediately re-evaluates
/// routing instead of only on the next manual navigation.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(pinProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: refreshNotifier,
    redirect: (context, state) async {
      final hasPin = await SecureStorage.hasPin();
      final isUnlocked = ref.read(pinProvider).isUnlocked;
      final onSetup  = state.matchedLocation == '/pin-setup';
      final onUnlock = state.matchedLocation == '/pin-unlock';

      if (!hasPin) return onSetup ? null : '/pin-setup';
      if (!isUnlocked) return onUnlock ? null : '/pin-unlock';
      if (onSetup || onUnlock) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path:    '/pin-setup',
        builder: (_, __) => const PinSetupScreen(),
      ),
      GoRoute(
        path:    '/pin-unlock',
        builder: (_, __) => const PinUnlockScreen(),
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
