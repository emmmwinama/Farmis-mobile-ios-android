import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/limits/limits_gate.dart';
import '../../core/theme/app_theme.dart';
import '../../models/activity.dart';
import '../../models/field.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_shimmer.dart';
import '../../shared/widgets/farmio_summary_bar.dart';
import '../fields/fields_provider.dart';
import 'activities_provider.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() =>
      _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  String  _typeFilter   = 'All';
  String  _fieldFilter  = 'All';
  String  _seasonFilter = 'All';
  bool    _showFilters  = false;
  bool    _showAnalytics = false;
  String? _expandedId;

  void _clearFilters() => setState(() {
    _typeFilter   = 'All';
    _fieldFilter  = 'All';
    _seasonFilter = 'All';
  });

  int get _activeFilterCount => [
    _typeFilter, _fieldFilter, _seasonFilter,
  ].where((f) => f != 'All').length;

  @override
  Widget build(BuildContext context) {
    final dataAsync   = ref.watch(activitiesDataProvider);
    final fieldsAsync = ref.watch(fieldsProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Activities',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: dataAsync.when(
        loading: () => const _Skeleton(),
        error:   (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(activitiesDataProvider),
        ),
        data: (data) {
          // Client-side filtering
          final filtered = data.activities.where((a) {
            if (_typeFilter   != 'All' && a.activityType != _typeFilter)   return false;
            if (_fieldFilter  != 'All' && a.fieldId      != _fieldFilter)  return false;
            if (_seasonFilter != 'All' && a.season       != _seasonFilter) return false;
            return true;
          }).toList();

          final totalCost   = filtered.fold(0.0, (s, a) => s + a.totalCost);
          final totalLabour = filtered.fold(0.0, (s, a) => s + a.totalLabourCost);
          final totalInputs = filtered.fold(0.0, (s, a) => s + a.totalInputCost);
          final totalOther  = filtered.fold(0.0, (s, a) => s + a.totalOtherCost);

          final List<FieldModel> fields =
              fieldsAsync.whenOrNull(data: (f) => f) ?? [];

          return RefreshIndicator(
            color:     FarmioColors.primary,
            onRefresh: () async => ref.invalidate(activitiesDataProvider),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [

                // Summary
                FarmioSummaryBar(stats: [
                  FarmioSummaryStat(
                      label: 'Total cost', value: Fmt.mwk(totalCost)),
                  FarmioSummaryStat(
                      label: 'Labour',
                      value: Fmt.mwk(totalLabour),
                      color: Colors.lightBlueAccent),
                  FarmioSummaryStat(
                      label: 'Inputs',
                      value: Fmt.mwk(totalInputs),
                      color: Colors.greenAccent),
                  FarmioSummaryStat(
                      label: 'Other',
                      value: Fmt.mwk(totalOther),
                      color: Colors.orangeAccent),
                ]),
                const SizedBox(height: 14),

                // Toolbar
                Row(children: [
                  _ToolbarButton(
                    label:   'Filters',
                    icon:    Icons.filter_list,
                    active:  _showFilters || _activeFilterCount > 0,
                    badge:   _activeFilterCount > 0
                        ? '$_activeFilterCount'
                        : null,
                    onTap: () => setState(
                            () => _showFilters = !_showFilters),
                  ),
                  const SizedBox(width: 8),
                  _ToolbarButton(
                    label:  'Analytics',
                    icon:   Icons.bar_chart,
                    active: _showAnalytics,
                    onTap:  () => setState(
                            () => _showAnalytics = !_showAnalytics),
                  ),
                  if (_activeFilterCount > 0) ...[
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon:  const Icon(Icons.close, size: 14),
                      label: const Text('Clear',
                          style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: FarmioColors.textMuted,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                      ),
                    ),
                  ],
                ]),
                const SizedBox(height: 10),

                // Filter panel
                if (_showFilters)
                  _FilterPanel(
                    typeFilter:   _typeFilter,
                    fieldFilter:  _fieldFilter,
                    seasonFilter: _seasonFilter,
                    allSeasons:   data.allSeasons,
                    fields:       fields,
                    onTypeChanged:   (v) => setState(() => _typeFilter   = v),
                    onFieldChanged:  (v) => setState(() => _fieldFilter  = v),
                    onSeasonChanged: (v) => setState(() => _seasonFilter = v),
                  ),

                // Analytics panel
                if (_showAnalytics)
                  _AnalyticsPanel(data: data),

                // Count line
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '${filtered.length} activit${filtered.length != 1 ? "ies" : "y"}'
                        '${_activeFilterCount > 0 ? " (filtered)" : ""}',
                    style: const TextStyle(
                      fontSize: 12,
                      color:    FarmioColors.textMuted,
                    ),
                  ),
                ),

                // List
                if (filtered.isEmpty)
                  _EmptyState(
                    hasFilters: _activeFilterCount > 0,
                    onClear:    _clearFilters,
                  )
                else
                  ...filtered.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child:   _ActivityCard(
                      activity:   a,
                      expanded:   _expandedId == a.id,
                      onTap: () => setState(() =>
                      _expandedId =
                      _expandedId == a.id ? null : a.id),
                      onOpenDetail: () async {
                        await context.push('/activities/${a.id}');
                        ref.invalidate(activitiesDataProvider);
                      },
                      onDelete: () =>
                          _confirmDelete(context, ref, a),
                    ),
                  )),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: FarmioColors.primary,
        onPressed: () async {
          if (!await ensureCanAdd(context, ref, LimitResource.activities)) return;
          if (!context.mounted) return;
          await context.push('/activities/new');
          ref.invalidate(activitiesDataProvider);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, ActivityModel a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title:   const Text('Delete activity'),
        content: Text(
            'Delete "${a.activityType}" on ${a.fieldName}? '
                'All inputs, labour and costs will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete',
                style: TextStyle(color: FarmioColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref
          .read(activitiesRepositoryProvider)
          .deleteActivity(a.id);
      ref.invalidate(activitiesDataProvider);
    }
  }
}

// ── Activity card (expandable) ────────────────────────────────────────────────
class _ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final bool          expanded;
  final VoidCallback  onTap;
  final VoidCallback  onOpenDetail;
  final VoidCallback  onDelete;

  const _ActivityCard({
    required this.activity,
    required this.expanded,
    required this.onTap,
    required this.onOpenDetail,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha:0.03),
            blurRadius: 6,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row — tappable to expand
          InkWell(
            onTap:        onTap,
            borderRadius: BorderRadius.vertical(
              top:    const Radius.circular(16),
              bottom: expanded
                  ? Radius.zero
                  : const Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                // Icon
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color:        FarmioColors.primary.withValues(alpha:0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Fmt.activityIconData(activity.activityType),
                    color: FarmioColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title line
                    Row(children: [
                      Flexible(
                        child: Text(activity.activityType,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize:   13,
                              fontWeight: FontWeight.w800,
                              color:      FarmioColors.textPrimary,
                            )),
                      ),
                      const Text(' — ',
                          style: TextStyle(
                              color: FarmioColors.textMuted,
                              fontSize: 13)),
                      Expanded(
                        child: Text(activity.fieldName,
                            style: const TextStyle(
                              fontSize: 13,
                              color:    FarmioColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    const SizedBox(height: 4),

                    // Meta chips
                    Wrap(
                      spacing:    6,
                      runSpacing: 4,
                      children: [
                        _MetaChip(
                          label: Fmt.dateShort(activity.date),
                        ),
                        if (activity.cropName != null)
                          _MetaChip(
                            label: activity.cropName! +
                                (activity.cropVariety != null
                                    ? ' (${activity.cropVariety})'
                                    : ''),
                            color: FarmioColors.success,
                          ),
                        if (activity.season != null)
                          _MetaChip(
                            label: activity.season!,
                            color: FarmioColors.warning,
                          ),
                        if (activity.labourCount > 0)
                          _MetaChip(
                            icon: Icons.people_outline_rounded,
                            label:
                            '${activity.labourCount} worker${activity.labourCount != 1 ? "s" : ""}',
                          ),
                        if (activity.inputCount > 0)
                          _MetaChip(
                            icon: Icons.inventory_2_outlined,
                            label:
                            '${activity.inputCount} input${activity.inputCount != 1 ? "s" : ""}',
                          ),
                      ],
                    ),
                  ],
                )),
                const SizedBox(width: 8),

                // Right side
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (activity.totalCost > 0)
                      Text(Fmt.mwk(activity.totalCost),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize:   12,
                            fontWeight: FontWeight.w800,
                            color:      FarmioColors.textPrimary,
                          )),
                    const SizedBox(height: 4),
                    Row(children: [
                      InkWell(
                        onTap:        onDelete,
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.delete_outline,
                              size: 16, color: FarmioColors.danger),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size:  18,
                        color: FarmioColors.textMuted,
                      ),
                    ]),
                  ],
                ),
              ]),
            ),
          ),

          // Expanded detail section
          if (expanded) ...[
            Container(
              decoration: const BoxDecoration(
                color: FarmioColors.background,
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  const Divider(
                      height: 1, color: FarmioColors.border),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        // Cost summary row
                        Row(children: [
                          _CostChip(
                            label: 'Labour',
                            value: activity.totalLabourCost,
                            color: FarmioColors.info,
                          ),
                          const SizedBox(width: 8),
                          _CostChip(
                            label: 'Inputs',
                            value: activity.totalInputCost,
                            color: FarmioColors.success,
                          ),
                          const SizedBox(width: 8),
                          _CostChip(
                            label: 'Other',
                            value: activity.totalOtherCost,
                            color: FarmioColors.warning,
                          ),
                        ]),
                        const SizedBox(height: 12),

                        // Labour records
                        if (activity.labourRecords.isNotEmpty) ...[
                          _SectionLabel(
                            label: 'Labour',
                            total: activity.totalLabourCost,
                          ),
                          ...activity.labourRecords.map(
                                (l) => _LabourRow(labour: l),
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Inputs
                        if (activity.inputs.isNotEmpty) ...[
                          _SectionLabel(
                            label: 'Inputs',
                            total: activity.totalInputCost,
                          ),
                          ...activity.inputs.map(
                                (i) => _InputRow(input: i),
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Other costs
                        if (activity.otherCosts.isNotEmpty) ...[
                          _SectionLabel(
                            label: 'Other costs',
                            total: activity.totalOtherCost,
                          ),
                          ...activity.otherCosts.map(
                                (o) => _OtherCostRow(cost: o),
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Notes
                        if (activity.notes != null &&
                            activity.notes!.isNotEmpty) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text('NOTES',
                                    style: TextStyle(
                                      fontSize:   10,
                                      fontWeight: FontWeight.w700,
                                      color: FarmioColors.textMuted,
                                      letterSpacing: 0.8,
                                    )),
                                const SizedBox(height: 4),
                                Text(activity.notes!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color:
                                      FarmioColors.textPrimary,
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        // View full detail button
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: onOpenDetail,
                            child: const Text('View full detail →',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: FarmioColors.primary,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final double total;
  const _SectionLabel({required this.label, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                fontSize:    10,
                fontWeight:  FontWeight.w700,
                color:       FarmioColors.textMuted,
                letterSpacing: 0.8,
              )),
          Text(Fmt.mwk(total),
              style: const TextStyle(
                fontSize:   10,
                fontWeight: FontWeight.w700,
                color:      FarmioColors.textMuted,
              )),
        ],
      ),
    );
  }
}

// ── Inline detail rows ────────────────────────────────────────────────────────
class _LabourRow extends StatelessWidget {
  final ActivityLabourSummary labour;
  const _LabourRow({required this.labour});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: FarmioColors.border),
      ),
      child: Row(children: [
        const Icon(Icons.person_outline,
            size: 14, color: FarmioColors.textMuted),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(labour.employeeName,
                style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: FarmioColors.textPrimary,
                )),
            if (labour.daysWorked > 0 || labour.hoursWorked > 0)
              Text(
                [
                  if (labour.daysWorked  > 0)
                    '${labour.daysWorked} days',
                  if (labour.hoursWorked > 0)
                    '${labour.hoursWorked} hrs',
                ].join(' · '),
                style: const TextStyle(
                  fontSize: 11, color: FarmioColors.textMuted,
                ),
              ),
          ],
        )),
        Text(Fmt.mwk(labour.totalCost),
            style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800,
              color: FarmioColors.textPrimary,
            )),
      ]),
    );
  }
}

class _InputRow extends StatelessWidget {
  final ActivityInputSummary input;
  const _InputRow({required this.input});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: FarmioColors.border),
      ),
      child: Row(children: [
        const Icon(Icons.science_outlined,
            size: 14, color: FarmioColors.textMuted),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(input.inputName,
                style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: FarmioColors.textPrimary,
                )),
            Text(
              '${input.quantity} ${input.unit} × ${Fmt.mwk(input.unitCost)}',
              style: const TextStyle(
                fontSize: 11, color: FarmioColors.textMuted,
              ),
            ),
          ],
        )),
        Text(Fmt.mwk(input.totalCost),
            style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800,
              color: FarmioColors.textPrimary,
            )),
      ]),
    );
  }
}

class _OtherCostRow extends StatelessWidget {
  final ActivityOtherCostSummary cost;
  const _OtherCostRow({required this.cost});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: FarmioColors.border),
      ),
      child: Row(children: [
        const Icon(Icons.receipt_outlined,
            size: 14, color: FarmioColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(cost.description,
              style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: FarmioColors.textPrimary,
              )),
        ),
        Text(Fmt.mwk(cost.amount),
            style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800,
              color: FarmioColors.textPrimary,
            )),
      ]),
    );
  }
}

// ── Filter panel ──────────────────────────────────────────────────────────────
class _FilterPanel extends StatelessWidget {
  final String            typeFilter;
  final String            fieldFilter;
  final String            seasonFilter;
  final List<String>      allSeasons;
  final List<FieldModel>     fields;
  final void Function(String) onTypeChanged;
  final void Function(String) onFieldChanged;
  final void Function(String) onSeasonChanged;

  const _FilterPanel({
    required this.typeFilter,
    required this.fieldFilter,
    required this.seasonFilter,
    required this.allSeasons,
    required this.fields,
    required this.onTypeChanged,
    required this.onFieldChanged,
    required this.onSeasonChanged,
  });

  static const _activityTypes = [
    'All', 'Planting', 'Irrigation', 'Spraying', 'Weeding',
    'Harvesting', 'Fertilizing', 'Soil Preparation',
    'Pest Control', 'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: FarmioColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Activity type
          const _FilterLabel(label: 'Activity type'),
          const SizedBox(height: 8),
          Wrap(
            spacing:    6,
            runSpacing: 6,
            children: _activityTypes.map((t) => _FilterChip(
              label:    t,
              selected: typeFilter == t,
              onTap:    () => onTypeChanged(t),
            )).toList(),
          ),
          const SizedBox(height: 14),

          // Field
          const _FilterLabel(label: 'Field'),
          const SizedBox(height: 8),
          Wrap(
            spacing:    6,
            runSpacing: 6,
            children: [
              _FilterChip(
                label:    'All',
                selected: fieldFilter == 'All',
                onTap:    () => onFieldChanged('All'),
              ),
              ...fields.map((f) => _FilterChip(
                label:    f.name,
                selected: fieldFilter == f.id,
                onTap:    () => onFieldChanged(f.id),
              )),
            ],
          ),
          const SizedBox(height: 14),

          // Season
          const _FilterLabel(label: 'Season'),
          const SizedBox(height: 8),
          Wrap(
            spacing:    6,
            runSpacing: 6,
            children: [
              _FilterChip(
                label:    'All',
                selected: seasonFilter == 'All',
                onTap:    () => onSeasonChanged('All'),
              ),
              ...allSeasons.map((s) => _FilterChip(
                label:    s,
                selected: seasonFilter == s,
                onTap:    () => onSeasonChanged(s),
              )),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Analytics panel ───────────────────────────────────────────────────────────
class _AnalyticsPanel extends StatelessWidget {
  final ActivitiesData data;
  const _AnalyticsPanel({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: FarmioColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // By type
          const _FilterLabel(label: 'By activity type'),
          const SizedBox(height: 10),
          if (data.byType.isEmpty)
            const Text('No data yet',
                style: TextStyle(
                  fontSize: 12, color: FarmioColors.textMuted,
                ))
          else
            ...data.byType.map((t) => _AnalyticsBar(
              label:    t.type,
              count:    t.count,
              maxCount: data.byType.first.count,
              cost:     t.totalCost,
              color:    FarmioColors.primary,
            )),

          const SizedBox(height: 14),

          // By field
          const _FilterLabel(label: 'By field'),
          const SizedBox(height: 10),
          if (data.byField.isEmpty)
            const Text('No data yet',
                style: TextStyle(
                  fontSize: 12, color: FarmioColors.textMuted,
                ))
          else
            ...data.byField.map((f) => _AnalyticsBar(
              label:    f.name,
              count:    f.count,
              maxCount: data.byField.first.count,
              cost:     f.totalCost,
              color:    FarmioColors.success,
            )),

          const SizedBox(height: 14),

          // By season
          const _FilterLabel(label: 'By season'),
          const SizedBox(height: 10),
          if (data.bySeason.isEmpty)
            const Text('No season data yet',
                style: TextStyle(
                  fontSize: 12, color: FarmioColors.textMuted,
                ))
          else
            ...data.bySeason.map((s) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AnalyticsBar(
                  label:    s.season,
                  count:    s.count,
                  maxCount: data.bySeason.first.count,
                  cost:     s.totalCost,
                  color:    FarmioColors.warning,
                ),
                if (s.types.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 4, bottom: 8),
                    child: Wrap(
                      spacing: 6,
                      children: s.types
                          .map((type) => Icon(
                                Fmt.activityIconData(type),
                                size: 16,
                                color: FarmioColors.textMuted,
                              ))
                          .toList(),
                    ),
                  ),
              ],
            )),
        ],
      ),
    );
  }
}

class _AnalyticsBar extends StatelessWidget {
  final String label;
  final int    count;
  final int    maxCount;
  final double cost;
  final Color  color;

  const _AnalyticsBar({
    required this.label,
    required this.count,
    required this.maxCount,
    required this.cost,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = maxCount > 0 ? count / maxCount : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                    fontSize: 12,
                    color:    FarmioColors.textPrimary,
                  )),
              Text('${count}x — ${Fmt.mwk(cost)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color:    FarmioColors.textMuted,
                  )),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value:           pct,
              minHeight:       5,
              backgroundColor: FarmioColors.border,
              valueColor:      AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────
class _FilterLabel extends StatelessWidget {
  final String label;
  const _FilterLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(),
        style: const TextStyle(
          fontSize:    10,
          fontWeight:  FontWeight.w700,
          color:       FarmioColors.textMuted,
          letterSpacing: 0.8,
        ));
  }
}

class _FilterChip extends StatelessWidget {
  final String   label;
  final bool     selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? FarmioColors.primary
              : FarmioColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? FarmioColors.primary
                : FarmioColors.border,
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize:   11,
              fontWeight: FontWeight.w700,
              color: selected
                  ? Colors.white
                  : FarmioColors.textMuted,
            )),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final String   label;
  final IconData icon;
  final bool     active;
  final String?  badge;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? FarmioColors.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? FarmioColors.primary
                : FarmioColors.border,
          ),
        ),
        child: Row(children: [
          Icon(icon,
              size:  14,
              color: active ? Colors.white : FarmioColors.textMuted),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                fontSize:   12,
                fontWeight: FontWeight.w700,
                color: active
                    ? Colors.white
                    : FarmioColors.textMuted,
              )),
          if (badge != null) ...[
            const SizedBox(width: 6),
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                color:       Colors.white,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(
                child: Text(badge!,
                    style: const TextStyle(
                      fontSize:   10,
                      fontWeight: FontWeight.w800,
                      color:      FarmioColors.primary,
                    )),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color  color;
  final IconData? icon;
  const _MetaChip({
    required this.label,
    this.color = FarmioColors.textMuted,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: TextStyle(
                fontSize:   10,
                fontWeight: FontWeight.w600,
                color:      color,
              )),
        ],
      ),
    );
  }
}

class _CostChip extends StatelessWidget {
  final String label;
  final double value;
  final Color  color;
  const _CostChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color:        color.withValues(alpha:0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                  fontSize: 10,
                  color:    color,
                  fontWeight: FontWeight.w600,
                )),
            Text(Fmt.mwk(value),
                style: TextStyle(
                  fontSize:   12,
                  fontWeight: FontWeight.w800,
                  color:      color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ── Empty / Skeleton / Error ──────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool         hasFilters;
  final VoidCallback onClear;
  const _EmptyState({required this.hasFilters, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined,
                size: 48, color: FarmioColors.primary),
            const SizedBox(height: 16),
            Text(
              hasFilters
                  ? 'No activities match these filters'
                  : 'No activities yet',
              style: const TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.w800,
                color:      FarmioColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              hasFilters
                  ? 'Try adjusting or clearing your filters'
                  : 'Tap + to log your first farm activity',
              textAlign: TextAlign.center,
              style: const TextStyle(color: FarmioColors.textMuted),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onClear,
                child:     const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding:          const EdgeInsets.all(20),
      itemCount:        5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const FarmioShimmer(
        width: double.infinity,
        height: 90,
        radius: 16,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: FarmioColors.danger),
          const SizedBox(height: 12),
          const Text('Could not load activities',
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
        ],
      ),
    );
  }
}
