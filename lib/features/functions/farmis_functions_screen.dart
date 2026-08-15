import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/farmio_card.dart';
import '../../shared/widgets/glass_panel.dart';

class FarmisFunctionsScreen extends StatelessWidget {
  const FarmisFunctionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Farmis Functions',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: FrostedScaffoldBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
          children: [
            GlassPanel(
              padding: const EdgeInsets.all(18),
              radius: 22,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  FarmioColors.primaryDark.withValues(alpha: 0.94),
                  FarmioColors.primary.withValues(alpha: 0.72),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mobile function map',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This mirrors the Farmis web dashboard. Native sections open in-app and use the mobile API where available.',
                    style: TextStyle(color: Colors.white70, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const _SectionTitle('Main functions'),
            const SizedBox(height: 10),
            ..._tilesFor(_FunctionCategory.main),
            const SizedBox(height: 22),
            const _SectionTitle('Reports'),
            const SizedBox(height: 10),
            ..._tilesFor(_FunctionCategory.reports),
            const SizedBox(height: 22),
            const _SectionTitle('Graphs and maps'),
            const SizedBox(height: 10),
            ..._tilesFor(_FunctionCategory.graphs),
            const SizedBox(height: 22),
            const _SectionTitle('Web and admin'),
            const SizedBox(height: 10),
            ..._tilesFor(_FunctionCategory.webAdmin),
          ],
        ),
      ),
    );
  }

  List<Widget> _tilesFor(_FunctionCategory category) {
    return _functions
        .where((item) => item.category == category)
        .map((item) => _FunctionTile(item: item))
        .toList();
  }
}

enum _FunctionStatus { mobile, partial, planned, web }
enum _FunctionCategory { main, reports, graphs, webAdmin }

class _FarmisFunction {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? route;
  final _FunctionStatus status;
  final _FunctionCategory category;

  const _FarmisFunction({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.route,
    this.status = _FunctionStatus.mobile,
    this.category = _FunctionCategory.main,
  });
}

const _functions = [
  _FarmisFunction(
    title: 'Dashboard',
    description: 'Farm overview, land use, income, expenses and recent activity.',
    icon: Icons.dashboard_outlined,
    color: FarmioColors.primary,
    route: '/dashboard',
  ),
  _FarmisFunction(
    title: 'Fields',
    description: 'Field area, soil, location notes and crop allocation.',
    icon: Icons.map_outlined,
    color: FarmioColors.primary,
    route: '/fields',
  ),
  _FarmisFunction(
    title: 'Field GPS/maps',
    description: 'Field boundaries, zones, markers and GPS readiness.',
    icon: Icons.gps_fixed_outlined,
    color: FarmioColors.info,
    route: '/field-map',
  ),
  _FarmisFunction(
    title: 'Crops',
    description: 'Crop cycles, planting dates, status and harvest timing.',
    icon: Icons.grass_outlined,
    color: FarmioColors.success,
    route: '/crops',
  ),
  _FarmisFunction(
    title: 'Activities',
    description: 'Field work, inputs, labour and other activity costs.',
    icon: Icons.assignment_outlined,
    color: FarmioColors.purple,
    route: '/activities',
  ),
  _FarmisFunction(
    title: 'Yields',
    description: 'Harvest records and price suggestions, per crop.',
    icon: Icons.agriculture_outlined,
    color: FarmioColors.success,
    route: '/crops',
  ),
  _FarmisFunction(
    title: 'Seasons',
    description: 'Active and archived seasons with comparison trends.',
    icon: Icons.archive_outlined,
    color: FarmioColors.warning,
    route: '/seasons',
  ),
  _FarmisFunction(
    title: 'Finance',
    description: 'Income, expenses, overheads and net position.',
    icon: Icons.account_balance_wallet_outlined,
    color: FarmioColors.warning,
    route: '/finance',
  ),
  _FarmisFunction(
    title: 'Employees',
    description: 'Payroll roles, pay rates and labour capacity evidence.',
    icon: Icons.people_alt_outlined,
    color: FarmioColors.info,
    route: '/employees',
  ),
  _FarmisFunction(
    title: 'Reports',
    description: 'Season, crop, field, labour, input and yield analysis.',
    icon: Icons.bar_chart_outlined,
    color: FarmioColors.info,
    route: '/reports',
  ),
  _FarmisFunction(
    title: 'Report builder',
    description: 'Custom report selection, filters and export readiness.',
    icon: Icons.post_add_outlined,
    color: FarmioColors.purple,
    route: '/report-builder',
  ),
  _FarmisFunction(
    title: 'Record packs',
    description: 'Loan, buyer, audit and insurance evidence packs.',
    icon: Icons.file_present_outlined,
    color: FarmioColors.primary,
    route: '/records',
  ),
  _FarmisFunction(
    title: 'Documents',
    description: 'Receipts, field photos, vet records, contracts and certificates.',
    icon: Icons.folder_copy_outlined,
    color: FarmioColors.primary,
    route: '/documents',
  ),
  _FarmisFunction(
    title: 'Compliance',
    description: 'Audit, insurance, buyer and evidence readiness.',
    icon: Icons.verified_user_outlined,
    color: FarmioColors.success,
    route: '/compliance',
  ),
  _FarmisFunction(
    title: 'Seasonal templates',
    description: 'Guided crop workflows for activities, payroll and sales evidence.',
    icon: Icons.fact_check_outlined,
    color: FarmioColors.primary,
    route: '/templates',
  ),
  _FarmisFunction(
    title: 'Subscriptions',
    description: 'Plan limits and available Farmis tiers.',
    icon: Icons.workspace_premium_outlined,
    color: FarmioColors.warning,
    route: '/subscriptions',
  ),
  _FarmisFunction(
    title: 'Profile',
    description: 'Account, farm and subscription details.',
    icon: Icons.person_outline,
    color: FarmioColors.slate500,
    route: '/profile',
  ),
  _FarmisFunction(
    title: 'Inventory',
    description: 'Harvest inventory, stock value and inventory sales.',
    icon: Icons.inventory_2_outlined,
    color: FarmioColors.info,
    route: '/inventory',
  ),
  _FarmisFunction(
    title: 'Livestock',
    description: 'Animal records, types, health, expenses and production.',
    icon: Icons.pets_outlined,
    color: FarmioColors.success,
    route: '/livestock-detail',
  ),
  _FarmisFunction(
    title: 'Weather',
    description: 'Seven-day forecast with farm advice.',
    icon: Icons.wb_cloudy_outlined,
    color: FarmioColors.info,
    route: '/weather',
  ),
  _FarmisFunction(
    title: 'Notifications',
    description: 'Harvest due, missing activity and inventory alerts.',
    icon: Icons.notifications_outlined,
    color: FarmioColors.warning,
    route: '/notifications',
  ),
  _FarmisFunction(
    title: 'Credit score',
    description: 'Farm record readiness for lender review.',
    icon: Icons.credit_score_outlined,
    color: FarmioColors.info,
    route: '/credit-score',
  ),
  _FarmisFunction(
    title: 'AI insights',
    description: 'Web dashboard analysis from farm, finance and inventory data.',
    icon: Icons.auto_awesome_outlined,
    color: FarmioColors.purple,
    route: '/ai-insights',
  ),
  _FarmisFunction(
    title: 'Team',
    description: 'Multi-user access, permissions and farm switching.',
    icon: Icons.groups_outlined,
    color: FarmioColors.slate500,
    route: '/team',
  ),
  _FarmisFunction(
    title: 'Settings',
    description: 'Farm profile, account settings and web dashboard preferences.',
    icon: Icons.settings_outlined,
    color: FarmioColors.slate500,
    route: '/settings',
  ),
  _FarmisFunction(
    title: 'Equipment',
    description: 'Equipment, fuel and service cost records.',
    icon: Icons.precision_manufacturing_outlined,
    color: FarmioColors.warning,
    route: '/equipment',
  ),
  _FarmisFunction(
    title: 'Traceability',
    description: 'Buyer-ready lots and evidence completeness.',
    icon: Icons.qr_code_2_outlined,
    color: FarmioColors.success,
    route: '/traceability',
  ),
  _FarmisFunction(
    title: 'Mobile API',
    description: 'Mobile endpoint coverage for dashboard, records and sync.',
    icon: Icons.api_outlined,
    color: FarmioColors.primary,
    route: '/mobile-api',
  ),
  _FarmisFunction(
    title: 'Field zones',
    description: 'Crop zones, soil areas, drainage, irrigation and infrastructure zones.',
    icon: Icons.grid_on_outlined,
    color: FarmioColors.primary,
    route: '/field-map',
  ),
  _FarmisFunction(
    title: 'Field markers',
    description: 'Boreholes, sheds, roads, gates, trees and other points of interest.',
    icon: Icons.add_location_alt_outlined,
    color: FarmioColors.info,
    route: '/field-map',
  ),
  _FarmisFunction(
    title: 'Crop archive',
    description: 'Completed crops remain in history with activities, yields, costs and reports.',
    icon: Icons.archive_outlined,
    color: FarmioColors.warning,
    route: '/crops',
  ),
  _FarmisFunction(
    title: 'New activity',
    description: 'Quick crop or farm activity logging with inputs, labour, costs and notes.',
    icon: Icons.add_task_outlined,
    color: FarmioColors.purple,
    route: '/activities',
  ),
  _FarmisFunction(
    title: 'Calendar',
    description: 'Activity dates, crop timelines, due work and upcoming recommendations.',
    icon: Icons.calendar_month_outlined,
    color: FarmioColors.primary,
    route: '/crops',
  ),
  _FarmisFunction(
    title: 'Livestock detail',
    description: 'One-animal overview with health, production, expenses and sales records.',
    icon: Icons.badge_outlined,
    color: FarmioColors.success,
    route: '/livestock-detail',
  ),
  _FarmisFunction(
    title: 'Livestock health',
    description: 'Treatments, vaccinations, checkups and upcoming health actions.',
    icon: Icons.medical_services_outlined,
    color: FarmioColors.warning,
    route: '/livestock-detail',
  ),
  _FarmisFunction(
    title: 'Livestock weight',
    description: 'Animal weight history and due/upcoming weighing schedules.',
    icon: Icons.monitor_weight_outlined,
    color: FarmioColors.info,
    route: '/livestock-detail',
  ),
  _FarmisFunction(
    title: 'Livestock production',
    description: 'Milk, eggs, births and other production records.',
    icon: Icons.insights_outlined,
    color: FarmioColors.primary,
    route: '/livestock-detail',
  ),
  _FarmisFunction(
    title: 'Livestock expenses',
    description: 'Feed, vet, labour and other livestock costs.',
    icon: Icons.receipt_long_outlined,
    color: FarmioColors.danger,
    route: '/livestock-detail',
  ),
  _FarmisFunction(
    title: 'Livestock sales',
    description: 'Animal and production sales connected to profitability.',
    icon: Icons.sell_outlined,
    color: FarmioColors.success,
    route: '/livestock-detail',
  ),
  _FarmisFunction(
    title: 'Overhead',
    description: 'Shared farm costs allocated across active crop production by area or time.',
    icon: Icons.account_balance_wallet_outlined,
    color: FarmioColors.warning,
    route: '/finance',
  ),
  _FarmisFunction(
    title: 'Inventory sales',
    description: 'Sales from stock connected back to revenue and reports.',
    icon: Icons.point_of_sale_outlined,
    color: FarmioColors.success,
    route: '/inventory',
  ),
  _FarmisFunction(
    title: 'Season compare',
    description: 'Compare crops, area, costs, revenue, profit, yield and cost per hectare.',
    icon: Icons.compare_arrows_outlined,
    color: FarmioColors.primary,
    route: '/seasons',
  ),
  _FarmisFunction(
    title: 'Farm switcher',
    description: 'Switch between farms owned by or shared with the logged-in user.',
    icon: Icons.swap_horiz_outlined,
    color: FarmioColors.primary,
    route: '/settings',
  ),
  _FarmisFunction(
    title: 'Offline sync',
    description: 'Queues supported farm records offline and syncs when connectivity returns.',
    icon: Icons.sync_outlined,
    color: FarmioColors.success,
    route: '/mobile-api',
  ),
  _FarmisFunction(
    title: 'Farm',
    description: 'Command area for fields, crops, activities, yields, livestock and maps.',
    icon: Icons.map_outlined,
    color: FarmioColors.primary,
    route: '/farm',
  ),
  _FarmisFunction(
    title: 'Business',
    description: 'Command area for finance, inventory, employees, equipment and seasons.',
    icon: Icons.business_center_outlined,
    color: FarmioColors.warning,
    route: '/business',
  ),
  _FarmisFunction(
    title: 'Insights',
    description: 'Command area for reports, weather, credit readiness and record packs.',
    icon: Icons.query_stats_outlined,
    color: FarmioColors.info,
    route: '/insights',
  ),
  _FarmisFunction(
    title: 'Farm summary',
    description: 'Totals for crops, area, harvest, yield average, revenue, expenses and overhead.',
    icon: Icons.summarize_outlined,
    color: FarmioColors.primary,
    route: '/reports',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Crop records',
    description: 'Crop records by field, season, area, status, revenue, cost and net profit.',
    icon: Icons.grass_outlined,
    color: FarmioColors.success,
    route: '/reports',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Finance transactions',
    description: 'Income and expenses by date, type, category, amount, description and season.',
    icon: Icons.receipt_long_outlined,
    color: FarmioColors.warning,
    route: '/finance',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Cashflow by month',
    description: 'Income, expenses and net cashflow grouped by month.',
    icon: Icons.bar_chart_outlined,
    color: FarmioColors.primary,
    route: '/reports',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Yield records',
    description: 'Harvest records with crop, field, season, date, quantity and yield per hectare.',
    icon: Icons.agriculture_outlined,
    color: FarmioColors.success,
    route: '/crops',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Crop profitability',
    description: 'Ranks crops by revenue, cost, net profit and margin.',
    icon: Icons.trending_up_outlined,
    color: FarmioColors.success,
    route: '/reports',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Field profitability',
    description: 'Compares fields by area, revenue, cost, net profit and profit per hectare.',
    icon: Icons.map_outlined,
    color: FarmioColors.info,
    route: '/reports',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Input efficiency',
    description: 'Shows how input spending converts into yield.',
    icon: Icons.science_outlined,
    color: FarmioColors.purple,
    route: '/reports',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Livestock profitability',
    description: 'Summarizes livestock sales, production value, expenses, health costs and net profit.',
    icon: Icons.pets_outlined,
    color: FarmioColors.success,
    route: '/livestock-detail',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Overhead allocation',
    description: 'Shared overhead allocated to crops and remaining unallocated costs.',
    icon: Icons.account_balance_wallet_outlined,
    color: FarmioColors.warning,
    route: '/reports',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Break-even',
    description: 'Minimum price per kg needed to cover production costs.',
    icon: Icons.price_check_outlined,
    color: FarmioColors.danger,
    route: '/reports',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Crop performance',
    description: 'Season performance by yield, cost per hectare, cost per kg and trend.',
    icon: Icons.query_stats_outlined,
    color: FarmioColors.primary,
    route: '/reports',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Yield trends',
    description: 'Yield per hectare across seasons and crops.',
    icon: Icons.show_chart_outlined,
    color: FarmioColors.success,
    route: '/reports',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Traceability report',
    description: 'Crop and farm traceability evidence for stakeholders.',
    icon: Icons.qr_code_2_outlined,
    color: FarmioColors.primary,
    route: '/traceability',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Credit readiness report',
    description: 'Structured data and evidence strength for credit review.',
    icon: Icons.credit_score_outlined,
    color: FarmioColors.primary,
    route: '/credit-score',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Custom report builder',
    description: 'Tailored PDF/CSV reports for selected audiences.',
    icon: Icons.post_add_outlined,
    color: FarmioColors.purple,
    route: '/report-builder',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Record pack export',
    description: 'Evidence packs for audits, buyers, funders and compliance review.',
    icon: Icons.file_present_outlined,
    color: FarmioColors.info,
    route: '/records',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Mobile report export',
    description: 'Mobile-facing report exports using selected filters and sections.',
    icon: Icons.phone_iphone_outlined,
    color: FarmioColors.primary,
    route: '/report-builder',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Overview tab',
    description: 'High-level report summary before drilling into detailed report sections.',
    icon: Icons.dashboard_customize_outlined,
    color: FarmioColors.primary,
    route: '/reports',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Crop summary tab',
    description: 'Crop-level summary of area, costs, revenue, yields and status.',
    icon: Icons.grass_outlined,
    color: FarmioColors.success,
    route: '/reports',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Financials tab',
    description: 'Income, expenses, overhead, net position and cashflow analysis.',
    icon: Icons.account_balance_wallet_outlined,
    color: FarmioColors.warning,
    route: '/reports',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Analytics tab',
    description: 'Charts and comparisons for decision support.',
    icon: Icons.analytics_outlined,
    color: FarmioColors.info,
    route: '/reports',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Yields tab',
    description: 'Harvest records, yield per hectare and crop output analysis.',
    icon: Icons.agriculture_outlined,
    color: FarmioColors.success,
    route: '/reports',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Overhead tab',
    description: 'Shared farm costs and allocation analysis.',
    icon: Icons.account_tree_outlined,
    color: FarmioColors.purple,
    route: '/reports',
    category: _FunctionCategory.reports,
  ),
  _FarmisFunction(
    title: 'Cashflow bar chart',
    description: 'Monthly income, expenses and net cashflow.',
    icon: Icons.bar_chart_outlined,
    color: FarmioColors.primary,
    route: '/graph-catalog',
    category: _FunctionCategory.graphs,
  ),
  _FarmisFunction(
    title: 'Graph catalog',
    description: 'Endpoint-backed list of available charts, maps and report visualizations.',
    icon: Icons.analytics_outlined,
    color: FarmioColors.info,
    route: '/graph-catalog',
    category: _FunctionCategory.graphs,
  ),
  _FarmisFunction(
    title: 'Yield per hectare line chart',
    description: 'Yield per hectare changes across seasons.',
    icon: Icons.show_chart_outlined,
    color: FarmioColors.success,
    route: '/graph-catalog',
    category: _FunctionCategory.graphs,
  ),
  _FarmisFunction(
    title: 'Production cost per hectare',
    description: 'Production cost per hectare across seasons.',
    icon: Icons.stacked_line_chart_outlined,
    color: FarmioColors.warning,
    route: '/graph-catalog',
    category: _FunctionCategory.graphs,
  ),
  _FarmisFunction(
    title: 'Cost per kg line chart',
    description: 'Cost efficiency of production over time.',
    icon: Icons.timeline_outlined,
    color: FarmioColors.danger,
    route: '/graph-catalog',
    category: _FunctionCategory.graphs,
  ),
  _FarmisFunction(
    title: 'Revenue vs expenses',
    description: 'Season revenue compared against expenses.',
    icon: Icons.compare_arrows_outlined,
    color: FarmioColors.info,
    route: '/graph-catalog',
    category: _FunctionCategory.graphs,
  ),
  _FarmisFunction(
    title: 'Expense breakdown',
    description: 'Input, labour, other cost and overhead components by season.',
    icon: Icons.stacked_bar_chart_outlined,
    color: FarmioColors.purple,
    route: '/graph-catalog',
    category: _FunctionCategory.graphs,
  ),
  _FarmisFunction(
    title: 'PDF snapshot bars',
    description: 'Small bar summaries inside exported PDF reports.',
    icon: Icons.picture_as_pdf_outlined,
    color: FarmioColors.danger,
    route: '/graph-catalog',
    category: _FunctionCategory.graphs,
  ),
  _FarmisFunction(
    title: 'Farm map',
    description: 'Fields, boundaries, zones and markers on a farm map.',
    icon: Icons.map_outlined,
    color: FarmioColors.primary,
    route: '/field-map',
    category: _FunctionCategory.graphs,
  ),
  _FarmisFunction(
    title: 'Field boundary map',
    description: 'GPS boundary for a specific field.',
    icon: Icons.polyline_outlined,
    color: FarmioColors.info,
    route: '/field-map',
    category: _FunctionCategory.graphs,
  ),
  _FarmisFunction(
    title: 'Zone map',
    description: 'Internal zones for crops, poor soil, irrigation and infrastructure.',
    icon: Icons.grid_4x4_outlined,
    color: FarmioColors.warning,
    route: '/field-map',
    category: _FunctionCategory.graphs,
  ),
  _FarmisFunction(
    title: 'Marker map',
    description: 'Boreholes, roads, gates, sheds, trees and key points.',
    icon: Icons.location_on_outlined,
    color: FarmioColors.success,
    route: '/field-map',
    category: _FunctionCategory.graphs,
  ),
  _FarmisFunction(
    title: 'Season comparison table',
    description: 'Season metrics with change indicators.',
    icon: Icons.table_chart_outlined,
    color: FarmioColors.primary,
    route: '/seasons',
    category: _FunctionCategory.graphs,
  ),
  _FarmisFunction(
    title: 'Crop trend badges',
    description: 'Improving, declining or stable performance indicators.',
    icon: Icons.trending_flat_outlined,
    color: FarmioColors.info,
    route: '/reports',
    category: _FunctionCategory.graphs,
  ),
  _FarmisFunction(
    title: 'Registration',
    description: 'Account creation and plan selection before first farm setup.',
    icon: Icons.person_add_alt_outlined,
    color: FarmioColors.primary,
    status: _FunctionStatus.web,
    category: _FunctionCategory.webAdmin,
  ),
  _FarmisFunction(
    title: 'Login',
    description: 'Authenticates users into AgriVault/Farmis.',
    icon: Icons.login_outlined,
    color: FarmioColors.success,
    route: '/login',
    category: _FunctionCategory.webAdmin,
  ),
  _FarmisFunction(
    title: 'Activation',
    description: 'Account and subscription activation flow.',
    icon: Icons.verified_outlined,
    color: FarmioColors.warning,
    status: _FunctionStatus.web,
    category: _FunctionCategory.webAdmin,
  ),
  _FarmisFunction(
    title: 'Invite',
    description: 'Allows invited users to join a farm team.',
    icon: Icons.forward_to_inbox_outlined,
    color: FarmioColors.info,
    status: _FunctionStatus.web,
    category: _FunctionCategory.webAdmin,
  ),
  _FarmisFunction(
    title: 'Public landing page',
    description: 'Public site content, pricing, features, testimonials and calls to action.',
    icon: Icons.public_outlined,
    color: FarmioColors.primary,
    status: _FunctionStatus.web,
    category: _FunctionCategory.webAdmin,
  ),
  _FarmisFunction(
    title: 'CMS pages',
    description: 'Terms, privacy, security, support, roadmap, blog and public content.',
    icon: Icons.article_outlined,
    color: FarmioColors.purple,
    status: _FunctionStatus.web,
    category: _FunctionCategory.webAdmin,
  ),
  _FarmisFunction(
    title: 'Admin overview',
    description: 'High-level platform management dashboard.',
    icon: Icons.admin_panel_settings_outlined,
    color: FarmioColors.slate500,
    status: _FunctionStatus.web,
    category: _FunctionCategory.webAdmin,
  ),
  _FarmisFunction(
    title: 'Admin users',
    description: 'View, update, activate or delete users.',
    icon: Icons.manage_accounts_outlined,
    color: FarmioColors.slate500,
    status: _FunctionStatus.web,
    category: _FunctionCategory.webAdmin,
  ),
  _FarmisFunction(
    title: 'Admin subscriptions',
    description: 'Manage plans, trials, suspensions, expiry and assignments.',
    icon: Icons.workspace_premium_outlined,
    color: FarmioColors.warning,
    status: _FunctionStatus.web,
    category: _FunctionCategory.webAdmin,
  ),
  _FarmisFunction(
    title: 'Admin payments',
    description: 'Record and review platform payments.',
    icon: Icons.payments_outlined,
    color: FarmioColors.success,
    status: _FunctionStatus.web,
    category: _FunctionCategory.webAdmin,
  ),
  _FarmisFunction(
    title: 'Admin tiers',
    description: 'Configure pricing tiers, limits, public visibility and featured plans.',
    icon: Icons.tune_outlined,
    color: FarmioColors.primary,
    status: _FunctionStatus.web,
    category: _FunctionCategory.webAdmin,
  ),
  _FarmisFunction(
    title: 'Admin inquiries',
    description: 'Review contact and demo inquiries.',
    icon: Icons.contact_mail_outlined,
    color: FarmioColors.info,
    status: _FunctionStatus.web,
    category: _FunctionCategory.webAdmin,
  ),
  _FarmisFunction(
    title: 'Admin CMS',
    description: 'Edit landing page content, testimonials, tiers and public site copy.',
    icon: Icons.edit_document,
    color: FarmioColors.primary,
    status: _FunctionStatus.web,
    category: _FunctionCategory.webAdmin,
  ),
];

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: FarmioColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _FunctionTile extends StatelessWidget {
  final _FarmisFunction item;

  const _FunctionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final enabled = item.route != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FarmioCard(
        padding: EdgeInsets.zero,
        radius: 18,
        onTap: enabled ? () => context.push(item.route!) : null,
        child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, color: item.color),
        ),
        title: Text(item.title,
            style: const TextStyle(
              color: FarmioColors.textPrimary,
              fontWeight: FontWeight.w900,
            )),
        subtitle: Text(item.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusPill(status: item.status),
            if (enabled) ...[
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded),
            ],
          ],
        ),
      ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final _FunctionStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    switch (status) {
      case _FunctionStatus.mobile:
        label = 'Mobile';
        break;
      case _FunctionStatus.partial:
        label = 'Partial';
        break;
      case _FunctionStatus.planned:
        label = 'Planned';
        break;
      case _FunctionStatus.web:
        label = 'Web';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: FarmioColors.slate100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: FarmioColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
