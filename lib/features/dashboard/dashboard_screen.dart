import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_mode_provider.dart';
import '../../models/crop_detail.dart';
import '../../models/crop_field.dart';
import '../../models/crop_timeline.dart';
import '../../models/dashboard_data.dart';
import '../../shared/agronomy/crop_timeline_catalog.dart';
import '../../shared/filters/report_record_filters.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_card.dart';
import '../../shared/widgets/glass_panel.dart';
import '../crops/crops_provider.dart';
import 'dashboard_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  ReportRecordFilters _filters = const ReportRecordFilters();
  DashboardData? _lastData;
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(dashboardProvider(_filters));
    final currentData = dashboard.valueOrNull;
    if (currentData != null) {
      _lastData = currentData;
    }
    final visibleData = currentData ?? _lastData;
    final name = visibleData?.userName ?? 'Farmer';

    return Scaffold(
      backgroundColor: FarmioColors.background,
      body: FrostedScaffoldBackground(
        child: visibleData != null
          ? Stack(
              children: [
                _buildDashboardBody(visibleData, name),
                if (dashboard.isLoading)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
              ],
            )
          : dashboard.when(
              loading: () => const _Skeleton(),
              error:   (e, _) => _ErrorView(
                error: e,
                onRetry: () => ref.invalidate(dashboardProvider(_filters)),
              ),
              data: (data) => _buildDashboardBody(data, name),
            ),
      ),
    );
  }

  Widget _buildDashboardBody(DashboardData data, String name) {
    return RefreshIndicator(
      color: FarmioColors.primary,
      onRefresh: () async => ref.invalidate(dashboardProvider(_filters)),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            floating: false,
            backgroundColor: FarmioColors.primaryDark,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              titlePadding: EdgeInsets.zero,
              background: _HeroBanner(
                name: name,
                farmName: data.farmName,
                net: data.net,
                onNotifications: () => _showDashboardAlerts(context),
              ),
            ),
            title: const SizedBox.shrink(),
            actions: [
              IconButton(
                tooltip: 'Toggle theme',
                icon: Icon(
                  ref.watch(themeModeProvider) == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  final notifier = ref.read(themeModeProvider.notifier);
                  notifier.state = notifier.state == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                },
              ),
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _DashboardFilterToggle(
                  value: _filters,
                  expanded: _showFilters,
                  onTap: () => setState(() => _showFilters = !_showFilters),
                ),
                if (_showFilters) ...[
                  const SizedBox(height: 10),
                  _DashboardFilterPanel(
                    value: _filters,
                    crops: _dashboardCrops(data),
                    seasons: _dashboardSeasons(data),
                    onChanged: (filters) =>
                        setState(() => _filters = filters),
                    onClear: () =>
                        setState(() => _filters = const ReportRecordFilters()),
                  ),
                ],
                const SizedBox(height: 12),
                _StatGrid(data: data),
                const SizedBox(height: 12),
                _ExpenseBreakdownCard(data: data),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Quick actions',
                  onMore: null,
                ),
                const SizedBox(height: 8),
                _QuickActionsGrid(),
                const SizedBox(height: 16),
                if (data.fieldLandUse.isNotEmpty) ...[
                  _SectionTitle(title: 'Land use'),
                  const SizedBox(height: 8),
                  ...data.fieldLandUse.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _LandUseRow(field: f),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _SectionTitle(
                  title: 'Recent activities',
                  onMore: () => context.push('/activities'),
                ),
                const SizedBox(height: 8),
                if (data.recentActivities.isEmpty)
                  _EmptyCard(
                    icon: 'A',
                    label: 'No activities yet',
                    sub: 'Open Farm to log today\'s work',
                  )
                else
                  ...data.recentActivities.map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ActivityRow(activity: a),
                      )),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _dashboardCrops(DashboardData data) {
    return {
      ...data.recentActivities
          .map((item) => item.cropName)
          .whereType<String>(),
    }.toList();
  }

  List<String> _dashboardSeasons(DashboardData data) {
    if (data.seasons.isNotEmpty) return data.seasons;
    return {
      ...data.recentActivities.map((item) => '${item.date.year}'),
    }.toList();
  }

  void _showDashboardAlerts(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _DashboardAlertsSheet(),
    );
  }
}

// ── Hero banner ───────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  final String name, farmName;
  final double net;
  final VoidCallback onNotifications;
  const _HeroBanner({
    required this.name,
    required this.farmName,
    required this.net,
    required this.onNotifications,
  });

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FarmioColors.primaryDark,
            Color(0xFF075985),
            FarmioColors.success,
          ],
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 36, 76, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_greeting,
                      style: const TextStyle(
                        color:    Colors.white60,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 8),
                  Text(name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:      Colors.white,
                        fontSize:   24,
                        fontWeight: FontWeight.w900,
                      )),
                  const Spacer(),
                  Text(farmName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:      Colors.white70,
                        fontSize:   14,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 6),
                  _NetBadge(net: net),
                ],
              ),
            ),
            Positioned(
              right: 20,
              bottom: 22,
              child: Tooltip(
                message: 'Activity alerts',
                child: Material(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: onNotifications,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          ),
      ),
    );
  }
}

class _NetBadge extends StatelessWidget {
  final double net;
  const _NetBadge({required this.net});

  @override
  Widget build(BuildContext context) {
    final positive = net >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:        Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          positive
              ? Icons.trending_up_rounded
              : Icons.trending_down_rounded,
          size:  14,
          color: positive ? Colors.greenAccent : Colors.redAccent,
        ),
        const SizedBox(width: 6),
        Text(
          'Net ${Fmt.mwk(net)}',
          style: TextStyle(
            color:      positive
                ? Colors.greenAccent
                : Colors.redAccent,
            fontSize:   12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ]),
    );
  }
}

// ── Stat grid ─────────────────────────────────────────────────────────────────
class _DashboardAlertsSheet extends ConsumerWidget {
  const _DashboardAlertsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crops = ref.watch(allCropsProvider);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: crops.when(
          loading: () => const _AlertsMessage(
            icon: Icons.notifications_active_outlined,
            title: 'Checking crop timelines',
            message: 'Preparing recommended activity alerts.',
          ),
          error: (error, _) => _AlertsMessage(
            icon: Icons.error_outline_rounded,
            title: 'Could not load alerts',
            message: _cleanError(error),
          ),
          data: (items) {
            final alerts = _buildCropAlerts(items);
            if (alerts.isEmpty) {
              return const _AlertsMessage(
                icon: Icons.task_alt_rounded,
                title: 'No activity alerts',
                message:
                    'There are no due crop timeline activities for active crops right now.',
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 12),
                const Text(
                  'Activity alerts',
                  style: TextStyle(
                    color: FarmioColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Recommended next work from crop timelines.',
                  style: TextStyle(
                    color: FarmioColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: alerts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _DashboardAlertRow(
                      alert: alerts[index],
                      onTap: () => _showAlertDetail(context, alerts[index]),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static List<_CropActivityAlert> _buildCropAlerts(
      List<CropFieldModel> crops) {
    final today = DateTime.now();
    final alerts = <_CropActivityAlert>[];
    for (final crop in crops.where((crop) => crop.status == 'Active')) {
      final detail = CropDetail(
        id: crop.id,
        cropTypeName: crop.cropTypeName,
        variety: crop.variety,
        areaPlanted: crop.areaPlanted,
        season: crop.season,
        plantingDate: crop.plantingDate,
        expectedHarvestDate: crop.expectedHarvestDate,
        status: crop.status,
        fieldId: crop.fieldId,
        fieldName: crop.fieldName,
        costs: const CropCosts(inputs: 0, labour: 0, other: 0, total: 0),
        yields: const [],
        activities: const [],
      );
      final plan = CropTimelineCatalog.buildPlan(crop: detail, today: today);
      final due = plan.entries.where((entry) => entry.isActionable).toList();
      final selected = due.isNotEmpty
          ? due
          : plan.nextAction == null
              ? <CropTimelineEntry>[]
              : [plan.nextAction!];
      for (final entry in selected) {
        alerts.add(_CropActivityAlert(crop: crop, entry: entry));
      }
    }

    alerts.sort((a, b) => a.entry.dueDate.compareTo(b.entry.dueDate));
    return alerts.take(10).toList();
  }

  static void _showAlertDetail(
    BuildContext context,
    _CropActivityAlert alert,
  ) {
    final entry = alert.entry;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _timelineStatusColor(entry.status)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _timelineStatusIcon(entry.status),
                      color: _timelineStatusColor(entry.status),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.step.title,
                          style: const TextStyle(
                            color: FarmioColors.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _timelineStatusLabel(entry.status),
                          style: TextStyle(
                            color: _timelineStatusColor(entry.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _AlertDetailLine(
                label: 'Crop',
                value:
                    '${alert.crop.cropTypeName}${alert.crop.variety.isEmpty ? '' : ' - ${alert.crop.variety}'}',
              ),
              _AlertDetailLine(label: 'Field', value: alert.crop.fieldName),
              _AlertDetailLine(label: 'Season', value: alert.crop.season),
              _AlertDetailLine(
                label: 'Activity type',
                value: entry.step.activityType,
              ),
              _AlertDetailLine(
                label: 'Expected window',
                value:
                    '${Fmt.date(entry.startDate)} - ${Fmt.date(entry.endDate)}',
              ),
              _AlertDetailLine(
                label: 'Due date',
                value: Fmt.date(entry.dueDate),
              ),
              const SizedBox(height: 12),
              const Text(
                'Recommendation',
                style: TextStyle(
                  color: FarmioColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                entry.step.recommendation,
                style: const TextStyle(
                  color: FarmioColors.textSecond,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _cleanError(Object error) {
    final message = error.toString();
    if (message.length <= 140) return message;
    return '${message.substring(0, 137)}...';
  }
}

class _DashboardAlertRow extends StatelessWidget {
  final _CropActivityAlert alert;
  final VoidCallback onTap;

  const _DashboardAlertRow({required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _timelineStatusColor(alert.entry.status);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: FarmioColors.softBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_timelineStatusIcon(alert.entry.status),
                    color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.entry.step.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: FarmioColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${alert.crop.cropTypeName} - ${alert.crop.fieldName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: FarmioColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                Fmt.date(alert.entry.dueDate),
                style: const TextStyle(
                  color: FarmioColors.textSecond,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertsMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _AlertsMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 28),
          Icon(icon, size: 42, color: FarmioColors.primary),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: FarmioColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: FarmioColors.textMuted,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: FarmioColors.softBorder,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _CropActivityAlert {
  final CropFieldModel crop;
  final CropTimelineEntry entry;

  const _CropActivityAlert({
    required this.crop,
    required this.entry,
  });
}

class _AlertDetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _AlertDetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(
                color: FarmioColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: FarmioColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _timelineStatusColor(CropTimelineStatus status) {
  switch (status) {
    case CropTimelineStatus.done:
      return FarmioColors.success;
    case CropTimelineStatus.due:
      return FarmioColors.primary;
    case CropTimelineStatus.overdue:
      return FarmioColors.danger;
    case CropTimelineStatus.upcoming:
      return FarmioColors.textMuted;
  }
}

IconData _timelineStatusIcon(CropTimelineStatus status) {
  switch (status) {
    case CropTimelineStatus.done:
      return Icons.check_circle_outline_rounded;
    case CropTimelineStatus.due:
      return Icons.notifications_active_outlined;
    case CropTimelineStatus.overdue:
      return Icons.priority_high_rounded;
    case CropTimelineStatus.upcoming:
      return Icons.schedule_rounded;
  }
}

String _timelineStatusLabel(CropTimelineStatus status) {
  switch (status) {
    case CropTimelineStatus.done:
      return 'Completed';
    case CropTimelineStatus.due:
      return 'Due now';
    case CropTimelineStatus.overdue:
      return 'Overdue';
    case CropTimelineStatus.upcoming:
      return 'Upcoming';
  }
}

class _DashboardFilterToggle extends StatelessWidget {
  final ReportRecordFilters value;
  final bool expanded;
  final VoidCallback onTap;

  const _DashboardFilterToggle({
    required this.value,
    required this.expanded,
    required this.onTap,
  });

  bool get _hasActiveFilters => value.crop != 'All' || value.season != 'All';

  String get _summary {
    final bits = <String>[
      value.period,
      if (value.crop != 'All') value.crop,
      if (value.season != 'All') value.season,
    ];
    return bits.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return FarmioCard(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: FarmioColors.primaryBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune_rounded,
                size: 18, color: FarmioColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filters',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: FarmioColors.textMuted,
                    )),
                Text(
                  _summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: FarmioColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (_hasActiveFilters)
            Container(
              margin: const EdgeInsets.only(right: 8),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: FarmioColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          AnimatedRotation(
            turns: expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: FarmioColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _DashboardFilterPanel extends StatelessWidget {
  final ReportRecordFilters value;
  final List<String> crops;
  final List<String> seasons;
  final ValueChanged<ReportRecordFilters> onChanged;
  final VoidCallback onClear;

  const _DashboardFilterPanel({
    required this.value,
    required this.crops,
    required this.seasons,
    required this.onChanged,
    required this.onClear,
  });

  static const _periods = [
    'Today',
    'This week',
    'This month',
    'This year',
    'This season',
  ];

  bool get _hasActiveFilters => value.crop != 'All' || value.season != 'All';

  @override
  Widget build(BuildContext context) {
    return FarmioCard(
      radius: 16,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Filter dashboard',
                    style: TextStyle(
                      color: FarmioColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    )),
              ),
              if (_hasActiveFilters)
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.close, size: 14),
                  label: const Text('Clear', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: FarmioColors.textMuted,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _FilterSection(
            title: 'Period',
            options: _periods,
            selected: value.period,
            onSelected: (v) =>
                onChanged(value.copyWith(period: v, clearDateRange: true)),
          ),
          const SizedBox(height: 14),
          _FilterSection(
            title: 'Crop',
            options: _withAll(crops),
            selected: value.crop,
            onSelected: (v) => onChanged(value.copyWith(crop: v)),
          ),
          const SizedBox(height: 14),
          _FilterSection(
            title: 'Season',
            options: _withAll(seasons),
            selected: value.season,
            onSelected: (v) => onChanged(value.copyWith(season: v)),
          ),
        ],
      ),
    );
  }

  static List<String> _withAll(List<String> items) {
    final values = {...items.where((item) => item.trim().isNotEmpty)}.toList()
      ..sort();
    return ['All', ...values.where((item) => item != 'All')];
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: FarmioColors.textMuted,
              letterSpacing: 0.4,
            )),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option == selected;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
              selectedColor: FarmioColors.primary,
              backgroundColor: FarmioColors.background,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : FarmioColors.textSecond,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected ? FarmioColors.primary : FarmioColors.border,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ExpenseBreakdownCard extends StatelessWidget {
  final DashboardData data;

  const _ExpenseBreakdownCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final items = data.expenseBreakdown
        .where((item) => item.amount > 0)
        .toList();

    return FarmioCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Expense breakdown',
                  style: TextStyle(
                    color: FarmioColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                Fmt.mwk(data.expense),
                style: const TextStyle(
                  color: FarmioColors.danger,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Text(
              'No expense categories returned for this period.',
              style: TextStyle(
                color: FarmioColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            ...items.map((item) {
              final pct = data.expense > 0
                  ? (item.amount / data.expense).clamp(0.0, 1.0)
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.label,
                            style: const TextStyle(
                              color: FarmioColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          Fmt.mwk(item.amount),
                          style: const TextStyle(
                            color: FarmioColors.textSecond,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 7,
                        backgroundColor: FarmioColors.slate100,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          FarmioColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final DashboardData data;
  const _StatGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem(
        icon:    Icons.map_outlined,
        label:   'Fields',
        value:   '${data.totalFields}',
        sub:     Fmt.haShort(data.totalArea),
        color:   FarmioColors.primary,
        gradient: [const Color(0xFF0D9488), const Color(0xFF0F766E)],
        onTap:   () => context.push('/fields'),
      ),
      _StatItem(
        icon:    Icons.grass_rounded,
        label:   'Crops',
        value:   '${data.activeCrops}',
        sub:     'active',
        color:   FarmioColors.success,
        gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
        onTap:   () => context.push('/crops'),
      ),
      _StatItem(
        icon:    Icons.arrow_downward_rounded,
        label:   'Income',
        value:   Fmt.mwk(data.income),
        sub:     'total',
        color:   FarmioColors.success,
        gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
        onTap:   () => context.push('/finance'),
      ),
      _StatItem(
        icon:    Icons.arrow_upward_rounded,
        label:   'Expenses',
        value:   Fmt.mwk(data.expense),
        sub:     'total',
        color:   FarmioColors.danger,
        gradient: [const Color(0xFFEF4444), const Color(0xFFDC2626)],
        onTap:   () => context.push('/finance'),
      ),
      _StatItem(
        icon:    Icons.people_outline_rounded,
        label:   'Employees',
        value:   '${data.activeEmployees}',
        sub:     'of ${data.totalEmployees}',
        color:   FarmioColors.info,
        gradient: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
        onTap:   () => context.push('/employees'),
      ),
      _StatItem(
        icon:    Icons.account_balance_outlined,
        label:   'Net P&L',
        value:   Fmt.mwk(data.net),
        sub:     data.net >= 0 ? 'profit' : 'loss',
        color:   data.net >= 0
            ? FarmioColors.success
            : FarmioColors.danger,
        gradient: data.net >= 0
            ? [const Color(0xFF10B981), const Color(0xFF059669)]
            : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
        onTap:   () => context.push('/finance'),
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < stats.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < stats.length ? 12 : 0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 106,
                    child: _StatCard(item: stats[i]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < stats.length
                      ? SizedBox(
                          height: 106,
                          child: _StatCard(item: stats[i + 1]),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StatItem {
  final IconData     icon;
  final String       label, value, sub;
  final Color        color;
  final List<Color>  gradient;
  final VoidCallback onTap;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.gradient,
    required this.onTap,
  });
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return FarmioCard(
      onTap: item.onTap,
        padding: const EdgeInsets.all(12),
      radius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:  MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width:  28, height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: item.gradient,
                      begin:  Alignment.topLeft,
                      end:    Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.icon,
                      size: 15, color: Colors.white),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 10, color: FarmioColors.slate300),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.value,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize:   15,
                      fontWeight: FontWeight.w800,
                      color:      item.color,
                    ),
                  ),
                ),
                Text(item.label,
                    style: const TextStyle(
                      fontSize:   10,
                      fontWeight: FontWeight.w600,
                      color:      FarmioColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
    );
  }
}

// ── Quick actions ─────────────────────────────────────────────────────────────
class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action('Fields',      Icons.map_rounded,
          const Color(0xFF0D9488), '/fields'),
      _Action('Crops',       Icons.grass_rounded,
          const Color(0xFF10B981), '/crops'),
      _Action('Activities',  Icons.assignment_rounded,
          const Color(0xFF8B5CF6), '/activities'),
      _Action('Finance',     Icons.account_balance_wallet_rounded,
          const Color(0xFFF59E0B), '/finance'),
      _Action('Reports',     Icons.bar_chart_rounded,
          const Color(0xFF3B82F6), '/reports'),
      _Action('Records',     Icons.file_present_rounded,
          const Color(0xFF0D9488), '/records'),
      _Action('Employees',   Icons.people_alt_rounded,
          const Color(0xFF2563EB), '/employees'),
      _Action('Templates',   Icons.fact_check_rounded,
          const Color(0xFF7C3AED), '/templates'),
      _Action('Profile',     Icons.person_rounded,
          const Color(0xFF64748B), '/profile'),
    ];

    return Column(
      children: [
        for (var i = 0; i < actions.length; i += 4)
          Padding(
            padding: EdgeInsets.only(bottom: i + 4 < actions.length ? 8 : 0),
            child: Row(
              children: [
                for (var j = i; j < i + 4; j++) ...[
                  if (j > i) const SizedBox(width: 8),
                  Expanded(
                    child: j < actions.length
                        ? SizedBox(
                            height: 84,
                            child: _ActionTile(action: actions[j]),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _Action {
  final String label, route;
  final IconData icon;
  final Color    color;
  const _Action(this.label, this.icon, this.color, this.route);
}

class _ActionTile extends StatelessWidget {
  final _Action action;
  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return FarmioCard(
      onTap: () => context.push(action.route),
      padding: EdgeInsets.zero,
      radius: 14,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:  36, height: 36,
              decoration: BoxDecoration(
                color:        action.color
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(action.icon,
                  color: action.color, size: 18),
            ),
            const SizedBox(height: 5),
            Text(action.label,
                style: const TextStyle(
                  fontSize:   10,
                  fontWeight: FontWeight.w700,
                  color:      FarmioColors.textPrimary,
                ),
                textAlign: TextAlign.center),
          ],
        ),
    );
  }
}

// ── Land use ──────────────────────────────────────────────────────────────────
class _LandUseRow extends StatelessWidget {
  final FieldLandUse field;
  const _LandUseRow({required this.field});

  @override
  Widget build(BuildContext context) {
    final pct = field.cultivatableArea > 0
        ? (field.allocated / field.cultivatableArea)
        .clamp(0.0, 1.0)
        : 0.0;

    return FarmioCard(
      padding: const EdgeInsets.all(14),
      radius: 16,
      child: Column(children: [
        Row(children: [
          Expanded(
            child: Text(field.name,
                style: const TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w700,
                  color:      FarmioColors.textPrimary,
                )),
          ),
          Text(
            '${Fmt.haShort(field.allocated)} / '
                '${Fmt.haShort(field.cultivatableArea)}',
            style: const TextStyle(
              fontSize: 11,
              color:    FarmioColors.textMuted,
            ),
          ),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value:           pct,
            minHeight:       7,
            backgroundColor: FarmioColors.slate100,
            valueColor:      AlwaysStoppedAnimation<Color>(
              pct >= 1.0
                  ? FarmioColors.danger
                  : FarmioColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(pct * 100).toStringAsFixed(0)}% allocated',
              style: const TextStyle(
                fontSize: 10,
                color:    FarmioColors.textMuted,
              ),
            ),
            Text(
              '${Fmt.haShort(field.available)} free',
              style: const TextStyle(
                fontSize: 10,
                color:    FarmioColors.textMuted,
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

// ── Activity row ──────────────────────────────────────────────────────────────
class _ActivityRow extends StatelessWidget {
  final RecentActivity activity;
  const _ActivityRow({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: FarmioColors.border),
      ),
      child: Row(children: [
        Container(
          width:  38, height: 38,
          decoration: BoxDecoration(
            color:        FarmioColors.primaryBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Fmt.activityIconData(activity.activityType),
            size: 18,
            color: FarmioColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(activity.activityType,
                  style: const TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w700,
                    color:      FarmioColors.textPrimary,
                  )),
              Text(
                activity.fieldName +
                    (activity.cropName != null
                        ? ' · ${activity.cropName}'
                        : ''),
                style: const TextStyle(
                  fontSize: 11,
                  color:    FarmioColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:        FarmioColors.slate100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            Fmt.timeAgo(activity.date),
            style: const TextStyle(
              fontSize:   10,
              fontWeight: FontWeight.w600,
              color:      FarmioColors.textMuted,
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String       title;
  final VoidCallback? onMore;
  const _SectionTitle({required this.title, this.onMore});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.w800,
              color:      FarmioColors.textPrimary,
              letterSpacing: -0.3,
            )),
        if (onMore != null)
          GestureDetector(
            onTap: onMore,
            child: const Text('See all',
                style: TextStyle(
                  fontSize:   12,
                  fontWeight: FontWeight.w600,
                  color:      FarmioColors.primary,
                )),
          ),
      ],
    );
  }
}

// ── Empty card ────────────────────────────────────────────────────────────────
class _EmptyCard extends StatelessWidget {
  final String icon, label, sub;
  const _EmptyCard({
    required this.icon,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: FarmioColors.border),
      ),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(
              fontSize:   14,
              fontWeight: FontWeight.w700,
              color:      FarmioColors.textPrimary,
            )),
        const SizedBox(height: 4),
        Text(sub,
            style: const TextStyle(
              fontSize: 12,
              color:    FarmioColors.textMuted,
            )),
      ]),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight:  200,
          backgroundColor: FarmioColors.primaryDark,
          flexibleSpace:   const FlexibleSpaceBar(),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver:  SliverList(
            delegate: SliverChildListDelegate([
              GridView.builder(
                shrinkWrap: true,
                physics:    const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:   2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing:  12,
                  childAspectRatio: 1.6,
                ),
                itemCount:   6,
                itemBuilder: (_, __) => _ShimmerBox(radius: 16),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double? height;
  final double  radius;
  const _ShimmerBox({this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      height:     height,
      decoration: BoxDecoration(
        color:        FarmioColors.slate200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final message = _messageFor(error);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: FarmioColors.danger),
          const SizedBox(height: 12),
          const Text('Could not load dashboard',
              style: TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.w700,
                color:      FarmioColors.textPrimary,
              )),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon:      const Icon(Icons.refresh),
            label:     const Text('Try again'),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: FarmioColors.textMuted,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _messageFor(Object error) => error.toString();
}
