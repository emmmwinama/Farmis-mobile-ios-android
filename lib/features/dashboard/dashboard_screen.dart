import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_mode_provider.dart';
import '../../models/app_notification.dart';
import '../../models/dashboard_data.dart';
import '../../models/weather.dart';
import '../../shared/filters/report_record_filters.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_card.dart';
import '../../shared/widgets/farmio_shimmer.dart';
import '../../shared/widgets/glass_panel.dart';
import '../notifications/notifications_provider.dart';
import '../weather/weather_provider.dart';
import 'dashboard_provider.dart';
import 'sync_status_icon.dart';

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
      backgroundColor: context.colors.background,
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
                onNotifications: () => context.push('/notifications'),
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
                onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
              ),
              const SyncStatusIcon(),
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
                _StatStrip(data: data),
                const SizedBox(height: 12),
                const _WeatherLine(),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Needs attention',
                  onMore: () => context.push('/notifications'),
                ),
                const SizedBox(height: 8),
                const _NeedsAttentionSection(),
                const SizedBox(height: 16),
                _ExpenseBreakdownCard(data: data),
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
                        child: _ActivityRow(
                          activity: a,
                          onTap: () => context.push('/activities/${a.id}'),
                        ),
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
    final fill = HeroFill(
      context,
      colors: const [
        FarmioColors.primaryDark,
        FarmioColors.primary,
        FarmioColors.success,
      ],
      flat: FarmioColors.primaryDark,
    );
    return Container(
      decoration: BoxDecoration(
        color: fill.color,
        gradient: fill.gradient,
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

// ── Needs attention (on-device notifications feed) ─────────────────────────────
class _NeedsAttentionSection extends ConsumerWidget {
  const _NeedsAttentionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    return notifications.when(
      loading: () => const FarmioShimmerCard(),
      error: (error, _) => _EmptyCard(
        icon: '!',
        label: 'Could not load alerts',
        sub: _cleanError(error),
      ),
      data: (data) {
        final items = data.notifications.take(5).toList();
        if (items.isEmpty) {
          return const _EmptyCard(
            icon: 'OK',
            label: 'All caught up',
            sub: 'No overdue activities, low stock or harvest alerts.',
          );
        }
        return Column(
          children: items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _NeedsAttentionRow(item: item),
                  ))
              .toList(),
        );
      },
    );
  }

  static String _cleanError(Object error) {
    final message = error.toString();
    if (message.length <= 140) return message;
    return '${message.substring(0, 137)}...';
  }
}

class _NeedsAttentionRow extends StatelessWidget {
  final AppNotification item;
  const _NeedsAttentionRow({required this.item});

  IconData get _icon {
    switch (item.type) {
      case 'harvest_due':
        return Icons.agriculture_outlined;
      case 'low_inventory':
        return Icons.inventory_2_outlined;
      case 'no_activity':
        return Icons.event_busy_outlined;
      default:
        return Icons.priority_high_rounded;
    }
  }

  Color get _color {
    switch (item.type) {
      case 'harvest_due':
        return FarmioColors.success;
      case 'low_inventory':
        return FarmioColors.warning;
      case 'no_activity':
        return FarmioColors.textMuted;
      default:
        return FarmioColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: item.link == null ? null : () => context.push(item.link!),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.softBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon, color: _color, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.link != null) ...[
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: colors.textMuted),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Weather line ─────────────────────────────────────────────────────────────
class _WeatherLine extends ConsumerWidget {
  const _WeatherLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider);
    return weather.when(
      loading: () => const FarmioShimmer(width: double.infinity, height: 56, radius: 16),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        final current = data.current;
        if (current == null) return const SizedBox.shrink();
        return FarmioCard(
          onTap: () => context.push('/weather'),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          radius: 16,
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: FarmioColors.info.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.wb_cloudy_outlined,
                    size: 18, color: FarmioColors.info),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${current.temp.round()}° · ${weatherCodeLabel(current.code)} in ${data.farmName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: context.colors.textMuted),
            ],
          ),
        );
      },
    );
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
                Text('Filters',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textMuted,
                    )),
                Text(
                  _summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
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
            child: Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: context.colors.textMuted),
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
              Expanded(
                child: Text('Filter dashboard',
                    style: TextStyle(
                      color: context.colors.textPrimary,
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
                    foregroundColor: context.colors.textMuted,
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
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: context.colors.textMuted,
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
              backgroundColor: context.colors.background,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : context.colors.textSecond,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected ? FarmioColors.primary : context.colors.border,
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
              Expanded(
                child: Text(
                  'Expense breakdown',
                  style: TextStyle(
                    color: context.colors.textPrimary,
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
            Text(
              'No expense categories returned for this period.',
              style: TextStyle(
                color: context.colors.textMuted,
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
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          Fmt.mwk(item.amount),
                          style: TextStyle(
                            color: context.colors.textSecond,
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

class _StatStrip extends StatelessWidget {
  final DashboardData data;
  const _StatStrip({required this.data});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem(
        icon:    Icons.map_outlined,
        label:   'Fields',
        value:   '${data.totalFields}',
        sub:     Fmt.haShort(data.totalArea),
        color:   FarmioColors.primary,
        gradient: [FarmioColors.primary, FarmioColors.primary.darken()],
        onTap:   () => context.push('/fields'),
      ),
      _StatItem(
        icon:    Icons.grass_rounded,
        label:   'Crops',
        value:   '${data.activeCrops}',
        sub:     'active',
        color:   FarmioColors.success,
        gradient: [FarmioColors.success, FarmioColors.success.darken()],
        onTap:   () => context.push('/crops'),
      ),
      _StatItem(
        icon:    Icons.arrow_downward_rounded,
        label:   'Income',
        value:   Fmt.mwk(data.income),
        sub:     'total',
        color:   FarmioColors.success,
        gradient: [FarmioColors.success, FarmioColors.success.darken()],
        onTap:   () => context.push('/finance'),
      ),
      _StatItem(
        icon:    Icons.arrow_upward_rounded,
        label:   'Expenses',
        value:   Fmt.mwk(data.expense),
        sub:     'total',
        color:   FarmioColors.danger,
        gradient: [FarmioColors.danger, FarmioColors.danger.darken()],
        onTap:   () => context.push('/finance'),
      ),
      _StatItem(
        icon:    Icons.people_outline_rounded,
        label:   'Employees',
        value:   '${data.activeEmployees}',
        sub:     'of ${data.totalEmployees}',
        color:   FarmioColors.info,
        gradient: [FarmioColors.info, FarmioColors.info.darken()],
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
            ? [FarmioColors.success, FarmioColors.success.darken()]
            : [FarmioColors.danger, FarmioColors.danger.darken()],
        onTap:   () => context.push('/finance'),
      ),
    ];

    return SizedBox(
      height: 106,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final stat in stats)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  width: 108,
                  child: _StatCard(item: stat),
                ),
              ),
          ],
        ),
      ),
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
    final badgeFill = HeroFill(context, colors: item.gradient, flat: item.gradient.first);
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
                    color: badgeFill.color,
                    gradient: badgeFill.gradient,
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
                    style: TextStyle(
                      fontSize:   10,
                      fontWeight: FontWeight.w600,
                      color:      context.colors.textPrimary,
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
                style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w700,
                  color:      context.colors.textPrimary,
                )),
          ),
          Text(
            '${Fmt.haShort(field.allocated)} / '
                '${Fmt.haShort(field.cultivatableArea)}',
            style: TextStyle(
              fontSize: 11,
              color:    context.colors.textMuted,
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
              style: TextStyle(
                fontSize: 10,
                color:    context.colors.textMuted,
              ),
            ),
            Text(
              '${Fmt.haShort(field.available)} free',
              style: TextStyle(
                fontSize: 10,
                color:    context.colors.textMuted,
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
  final VoidCallback onTap;
  const _ActivityRow({required this.activity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FarmioCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      radius: 12,
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
                  style: TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w700,
                    color:      colors.textPrimary,
                  )),
              Text(
                activity.fieldName +
                    (activity.cropName != null
                        ? ' · ${activity.cropName}'
                        : ''),
                style: TextStyle(
                  fontSize: 11,
                  color:    colors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:        colors.background,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            Fmt.timeAgo(activity.date),
            style: TextStyle(
              fontSize:   10,
              fontWeight: FontWeight.w600,
              color:      colors.textMuted,
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
            style: TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.w800,
              color:      context.colors.textPrimary,
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
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:        colors.surface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: colors.border),
      ),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
              fontSize:   14,
              fontWeight: FontWeight.w700,
              color:      colors.textPrimary,
            )),
        const SizedBox(height: 4),
        Text(sub,
            style: TextStyle(
              fontSize: 12,
              color:    colors.textMuted,
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
                itemBuilder: (_, __) => const FarmioShimmer(
                  width: double.infinity,
                  height: double.infinity,
                  radius: 16,
                ),
              ),
            ]),
          ),
        ),
      ],
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
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: FarmioColors.danger),
          const SizedBox(height: 12),
          Text('Could not load dashboard',
              style: TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.w700,
                color:      colors.textPrimary,
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
              style: TextStyle(
                color: colors.textMuted,
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
