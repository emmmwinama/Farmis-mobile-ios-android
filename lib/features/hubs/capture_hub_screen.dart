import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/farmio_card.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/sync_status_indicator.dart';

class CaptureHubScreen extends StatelessWidget {
  const CaptureHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _HubScaffold(
      title: 'Capture',
      subtitle: 'Use original forms. Failed online submissions should queue for sync.',
      actions: const [SyncStatusIndicator()],
      children: [
        _ActionCard(
          icon: Icons.assignment_outlined,
          title: 'Log activity',
          body: 'Field work, labour, inputs and notes.',
          route: '/activities',
          color: FarmioColors.primary,
        ),
        _ActionCard(
          icon: Icons.agriculture_outlined,
          title: 'Record harvest',
          body: 'Log a harvest from a crop\'s detail page.',
          route: '/crops',
          color: FarmioColors.success,
        ),
        _ActionCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Add transaction',
          body: 'Income, expense and sales records.',
          route: '/finance',
          color: FarmioColors.info,
        ),
        _ActionCard(
          icon: Icons.attach_file_outlined,
          title: 'Add evidence',
          body: 'Photos, receipts, contracts and certificates.',
          route: '/documents',
          color: FarmioColors.info,
        ),
        _ActionCard(
          icon: Icons.pets_outlined,
          title: 'Livestock record',
          body: 'Animal register and livestock records.',
          route: '/livestock-detail',
          color: FarmioColors.success,
        ),
        _ActionCard(
          icon: Icons.inventory_2_outlined,
          title: 'Inventory sale',
          body: 'Stock purchases and inventory sales.',
          route: '/inventory',
          color: FarmioColors.warning,
        ),
      ],
    );
  }
}

class FarmHubScreen extends StatelessWidget {
  const FarmHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _HubScaffold(
      title: 'Farm',
      subtitle: 'Fields, crops, activities, harvests and seasonal planning.',
      children: [
        _ActionCard(
          icon: Icons.map_outlined,
          title: 'Fields',
          body: 'Field area, soil and allocation.',
          route: '/fields',
          color: FarmioColors.primary,
        ),
        _ActionCard(
          icon: Icons.gps_fixed_outlined,
          title: 'GPS map',
          body: 'Boundaries, zones and markers.',
          route: '/field-map',
          color: FarmioColors.info,
        ),
        _ActionCard(
          icon: Icons.grass_outlined,
          title: 'Crops',
          body: 'Crop cycles, status, timeline and harvest records — open a '
              'crop to see its details.',
          route: '/crops',
          color: FarmioColors.success,
        ),
        _ActionCard(
          icon: Icons.assignment_outlined,
          title: 'Activities',
          body: 'Work by crop or field.',
          route: '/activities',
          color: FarmioColors.purple,
        ),
        _ActionCard(
          icon: Icons.fact_check_outlined,
          title: 'Templates',
          body: 'Guided seasonal workflows.',
          route: '/templates',
          color: FarmioColors.info,
        ),
        _ActionCard(
          icon: Icons.archive_outlined,
          title: 'Seasons',
          body: 'Active and archived season comparison.',
          route: '/seasons',
          color: FarmioColors.warning,
        ),
      ],
    );
  }
}

class BusinessHubScreen extends StatelessWidget {
  const BusinessHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _HubScaffold(
      title: 'Business',
      subtitle: 'Finance, payroll, inventory, sales and operational cost control.',
      children: [
        _ActionCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Finance',
          body: 'Transactions, overhead and cash position.',
          route: '/finance',
          color: FarmioColors.info,
        ),
        _ActionCard(
          icon: Icons.people_alt_outlined,
          title: 'Employees',
          body: 'Payroll roles and labour capacity.',
          route: '/employees',
          color: FarmioColors.primary,
        ),
        _ActionCard(
          icon: Icons.groups_outlined,
          title: 'Team permissions',
          body: 'Members, roles and access readiness.',
          route: '/team',
          color: FarmioColors.info,
        ),
        _ActionCard(
          icon: Icons.inventory_2_outlined,
          title: 'Inventory stock',
          body: 'Harvest inventory, stock value and inventory sales.',
          route: '/inventory',
          color: FarmioColors.info,
        ),
        _ActionCard(
          icon: Icons.precision_manufacturing_outlined,
          title: 'Equipment',
          body: 'Equipment, fuel and service logs.',
          route: '/equipment',
          color: FarmioColors.warning,
        ),
        _ActionCard(
          icon: Icons.show_chart_outlined,
          title: 'Cashflow chart',
          body: 'Cashflow and profitability are available in reports.',
          route: '/reports',
          color: FarmioColors.primary,
        ),
      ],
    );
  }
}

class LivestockHubScreen extends StatelessWidget {
  const LivestockHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _HubScaffold(
      title: 'Livestock',
      subtitle: 'Animal records, health, production, weight, expenses and sales.',
      children: const [
        _ActionCard(
          icon: Icons.pets_outlined,
          title: 'Animal list',
          body: 'View animal register and recent records.',
          route: '/livestock-detail',
          color: FarmioColors.success,
        ),
        _ActionCard(
          icon: Icons.medical_services_outlined,
          title: 'Health records',
          body: 'Review recent livestock health records.',
          route: '/livestock-detail',
          color: FarmioColors.warning,
        ),
        _ActionCard(
          icon: Icons.monitor_weight_outlined,
          title: 'Weight records',
          body: 'Review animal weight and production records.',
          route: '/livestock-detail',
          color: FarmioColors.info,
        ),
        _ActionCard(
          icon: Icons.query_stats_outlined,
          title: 'Profitability',
          body: 'See livestock costs and sales evidence.',
          route: '/livestock-detail',
          color: FarmioColors.primary,
        ),
      ],
    );
  }
}

class InsightsHubScreen extends StatelessWidget {
  const InsightsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _HubScaffold(
      title: 'Insights',
      subtitle: 'Reports, traceability, compliance, alerts and export readiness.',
      children: [
        _ActionCard(
          icon: Icons.bar_chart_outlined,
          title: 'Reports',
          body: 'Profitability, costs, labour, inputs and yields.',
          route: '/reports',
          color: FarmioColors.primary,
        ),
        _ActionCard(
          icon: Icons.file_present_outlined,
          title: 'Records',
          body: 'Loan, buyer, audit and insurance evidence packs.',
          route: '/records',
          color: FarmioColors.info,
        ),
        _ActionCard(
          icon: Icons.qr_code_2_outlined,
          title: 'Traceability',
          body: 'Buyer-ready lots and evidence checklist.',
          route: '/traceability',
          color: FarmioColors.success,
        ),
        _ActionCard(
          icon: Icons.verified_user_outlined,
          title: 'Compliance',
          body: 'Audit, buyer and insurance readiness.',
          route: '/compliance',
          color: FarmioColors.primary,
        ),
        _ActionCard(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          body: 'Alerts, due work and read status.',
          route: '/notifications',
          color: FarmioColors.warning,
        ),
        _ActionCard(
          icon: Icons.wb_cloudy_outlined,
          title: 'Weather',
          body: 'Current conditions, 7-day forecast and field guidance.',
          route: '/weather',
          color: FarmioColors.info,
        ),
        _ActionCard(
          icon: Icons.post_add_outlined,
          title: 'Report builder',
          body: 'Select report sections and export filters.',
          route: '/report-builder',
          color: FarmioColors.purple,
        ),
        _ActionCard(
          icon: Icons.analytics_outlined,
          title: 'Graph catalog',
          body: 'Charts, maps and export visualizations.',
          route: '/graph-catalog',
          color: FarmioColors.info,
        ),
      ],
    );
  }
}

class MoreHubScreen extends StatelessWidget {
  const MoreHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _HubScaffold(
      title: 'More',
      subtitle: 'Account, subscription, function coverage and locked modules.',
      children: [
        _ActionCard(
          icon: Icons.person_outline,
          title: 'Profile',
          body: 'User, farm and subscription details.',
          route: '/profile',
          color: FarmioColors.primary,
        ),
        _ActionCard(
          icon: Icons.apps_outlined,
          title: 'Function map',
          body: 'See mobile coverage for every web module.',
          route: '/functions',
          color: FarmioColors.info,
        ),
        _ActionCard(
          icon: Icons.workspace_premium_outlined,
          title: 'Subscription',
          body: 'Plan limits and tier status.',
          route: '/subscriptions',
          color: FarmioColors.purple,
        ),
        _ActionCard(
          icon: Icons.settings_outlined,
          title: 'Settings',
          body: 'Farm switching, password and profile settings.',
          route: '/settings',
          color: FarmioColors.slate500,
        ),
        _ActionCard(
          icon: Icons.api_outlined,
          title: 'Mobile API',
          body: 'Endpoint coverage for mobile features and sync.',
          route: '/mobile-api',
          color: FarmioColors.primary,
        ),
      ],
    );
  }
}

class _HubScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final List<Widget> actions;

  const _HubScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final tablet = MediaQuery.of(context).size.width >= 760;

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: Text(title),
        actions: [
          ...actions,
          const SizedBox(width: 12),
        ],
      ),
      body: FrostedScaffoldBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 96),
          children: [
            GlassPanel(
              padding: const EdgeInsets.all(18),
              radius: 24,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  FarmioColors.primaryDark.withValues(alpha: 0.94),
                  FarmioColors.primary.withValues(alpha: 0.82),
                  FarmioColors.cyan.withValues(alpha: 0.52),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: tablet ? 3 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: tablet ? 1.45 : 0.96,
              children: children,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? route;
  final Color color;
  final bool locked;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.route,
    required this.color,
  }) : locked = false;

  @override
  Widget build(BuildContext context) {
    return FarmioCard(
      onTap: route == null ? null : () => context.push(route!),
      padding: const EdgeInsets.all(15),
      radius: 18,
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const Spacer(),
                  Icon(
                    locked ? Icons.lock_outline : Icons.chevron_right_rounded,
                    color: locked ? FarmioColors.textMuted : color,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: FarmioColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: Text(
                  body,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: FarmioColors.textMuted,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ),
              if (locked)
                const Text(
                  'Endpoint needed',
                  style: TextStyle(
                    color: FarmioColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
    );
  }
}
