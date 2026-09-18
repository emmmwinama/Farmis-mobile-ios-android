import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/crop_detail.dart';
import '../../models/crop_timeline.dart';
import '../../shared/agronomy/crop_timeline_catalog.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/utils/yield_pricing.dart';
import '../../shared/widgets/farmio_card.dart';
import '../../shared/widgets/farmio_summary_bar.dart';
import '../yields/yields_provider.dart';
import 'crops_provider.dart';
import '../../core/theme/app_spacing.dart';

class CropDetailScreen extends ConsumerWidget {
  final String cropId;
  const CropDetailScreen({super.key, required this.cropId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(cropDetailProvider(cropId));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Crop detail',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          detail.whenOrNull(
            data: (crop) => PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'harvested') {
                  await ref
                      .read(cropsRepositoryProvider)
                      .markHarvested(cropId);
                  if (context.mounted) context.pop();
                }
                if (v == 'archive') {
                  await ref
                      .read(cropsRepositoryProvider)
                      .archiveCrop(cropId);
                  if (context.mounted) context.pop();
                }
                if (v == 'restore') {
                  await ref
                      .read(cropsRepositoryProvider)
                      .restoreCrop(cropId);
                  if (context.mounted) context.pop();
                }
                if (v == 'edit') {
                  final existing = await ref.read(cropsRepositoryProvider).getCropField(cropId);
                  if (context.mounted) context.push('/crops/new', extra: existing);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Edit crop'),
                  ]),
                ),
                if (crop.isActive)
                  const PopupMenuItem(
                    value: 'harvested',
                    child: Row(children: [
                      Icon(Icons.check_circle_outline, size: 18),
                      SizedBox(width: 8),
                      Text('Mark as harvested'),
                    ]),
                  ),
                if (!crop.isActive)
                  const PopupMenuItem(
                    value: 'restore',
                    child: Row(children: [
                      Icon(Icons.replay_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Mark as active'),
                    ]),
                  ),
                if (!crop.isArchived)
                  const PopupMenuItem(
                    value: 'archive',
                    child: Row(children: [
                      Icon(Icons.archive_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Archive crop'),
                    ]),
                  ),
              ],
            ),
          ) ?? const SizedBox(),
        ],
      ),
      body: detail.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: FarmioColors.primary)),
        error:   (e, _) => Center(child: Text(e.toString())),
        data:    (crop) => _DetailContent(crop: crop),
      ),
    );
  }
}

class _DetailContent extends ConsumerStatefulWidget {
  final CropDetail crop;
  const _DetailContent({required this.crop});

  @override
  ConsumerState<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends ConsumerState<_DetailContent> {
  bool _showPriceSuggestion = false;
  double _targetMargin = 30;

  CropDetail get crop => widget.crop;

  Future<void> _addHarvest(BuildContext context) async {
    await context.push('/yields/new?cropFieldId=${crop.id}');
    if (mounted) ref.invalidate(cropDetailProvider(crop.id));
  }

  @override
  Widget build(BuildContext context) {
    final days      = crop.daysToHarvest;
    final isOverdue = crop.isOverdue;
    final isDueSoon = crop.isDueSoon;

    Color accentColor = FarmioColors.primary;
    if (!crop.isActive) accentColor = context.colors.textMuted;
    if (isOverdue)       accentColor = FarmioColors.danger;
    if (isDueSoon)       accentColor = FarmioColors.warning;

    double progressValue = 0;
    if (crop.isActive) {
      final total   = crop.expectedHarvestDate
          .difference(crop.plantingDate).inDays;
      final elapsed = DateTime.now()
          .difference(crop.plantingDate).inDays;
      progressValue = total > 0
          ? (elapsed / total).clamp(0.0, 1.0)
          : 0;
    }
    final timelinePlan = CropTimelineCatalog.buildPlan(crop: crop);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        if (crop.isActive && timelinePlan.entries.isNotEmpty) ...[
          _TimelineSummaryRow(plan: timelinePlan),
          const SizedBox(height: 12),
        ],
        _TimelineRecommendationCard(plan: timelinePlan),
        const SizedBox(height: 16),

        // Main info card
        FarmioCard(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.grass_outlined,
                  size: 32, color: FarmioColors.primary),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${crop.cropTypeName} - ${crop.variety}',
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800,
                        color: context.colors.textPrimary,
                      )),
                  Text('${crop.fieldName} - ${crop.season}',
                      style: TextStyle(
                        fontSize: 13, color: context.colors.textMuted,
                      )),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color:        accentColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  crop.isArchived ? 'Archived' : crop.status,
                  style: TextStyle(
                    fontSize:   11, fontWeight: FontWeight.w700,
                    color:      accentColor,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Divider(color: context.colors.border),
            const SizedBox(height: 16),

            Row(children: [
              _InfoItem(label: 'Area planted',
                  value: Fmt.haShort(crop.areaPlanted)),
              _InfoItem(label: 'Planted',
                  value: Fmt.date(crop.plantingDate)),
              _InfoItem(label: 'Harvest date',
                  value: Fmt.date(crop.expectedHarvestDate)),
            ]),

            if (crop.isActive) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Growth progress',
                      style: TextStyle(
                        fontSize: 12, color: context.colors.textMuted,
                      )),
                  Text(
                    isOverdue
                        ? '${days.abs()}d overdue'
                        : isDueSoon
                        ? 'Due in ${days}d'
                        : '${days}d remaining',
                    style: TextStyle(
                      fontSize: 12, color: accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value:           progressValue,
                  minHeight:       8,
                  backgroundColor: context.colors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
            ],
          ],
        )),
        const SizedBox(height: 16),
        _CropTimelineCard(plan: timelinePlan),
        const SizedBox(height: 16),

        // Cost breakdown
        FarmioCard(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cost breakdown',
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                )),
            const SizedBox(height: 12),
            _CostRow(label: 'Inputs',    value: crop.costs.inputs,
                icon: Icons.science_outlined),
            _CostRow(label: 'Labour',    value: crop.costs.labour,
                icon: Icons.people_outline),
            _CostRow(label: 'Other',     value: crop.costs.other,
                icon: Icons.more_horiz),
            Divider(color: context.colors.border),
            _CostRow(label: 'Total',     value: crop.costs.total,
                icon: Icons.account_balance_outlined,
                isBold: true),
          ],
        )),
        const SizedBox(height: 16),

        // Yields
        Row(
          children: [
            Expanded(
              child: Text('Harvests recorded',
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  )),
            ),
            TextButton.icon(
              onPressed: () => _addHarvest(context),
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add harvest'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 6),
            OutlinedButton.icon(
              onPressed: () => setState(
                  () => _showPriceSuggestion = !_showPriceSuggestion),
              icon: const Icon(Icons.trending_up_rounded,
                  size: 14, color: FarmioColors.info),
              label: const Text('Price suggestion'),
              style: OutlinedButton.styleFrom(
                foregroundColor: FarmioColors.info,
                backgroundColor: _showPriceSuggestion
                    ? FarmioColors.infoBg
                    : Colors.transparent,
                side: const BorderSide(color: FarmioColors.primaryLight),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (_showPriceSuggestion)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _PriceSuggestionPanel(
              totalCost: crop.costs.total,
              totalYieldKg: crop.totalYieldKg,
              margin: _targetMargin,
              onMarginChanged: (v) => setState(() => _targetMargin = v),
            ),
          ),

        if (crop.yields.isEmpty)
          FarmioCard(child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text('No harvests recorded yet',
                  style: TextStyle(color: context.colors.textMuted)),
            ),
          ))
        else ...[
          ...crop.yields.map((y) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child:   _YieldTile(y: y, cropId: crop.id),
          )),
          FarmioCard(child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total yield',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  )),
              Text(Fmt.kg(crop.totalYieldKg),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: FarmioColors.primary,
                    fontSize: 16,
                  )),
            ],
          )),
        ],

        const SizedBox(height: 16),

        // Activities
        Text('Activities',
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            )),
        const SizedBox(height: 10),

        if (crop.activities.isEmpty)
          FarmioCard(child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text('No activities recorded',
                  style: TextStyle(color: context.colors.textMuted)),
            ),
          ))
        else
          ...crop.activities.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child:   _ActivityTile(a: a, onTap: () => context.push('/activities/${a.id}')),
          )),

        const SizedBox(height: 20),
      ],
    );
  }
}

class _TimelineSummaryRow extends StatelessWidget {
  final CropTimelinePlan plan;
  const _TimelineSummaryRow({required this.plan});

  @override
  Widget build(BuildContext context) {
    final overdue = plan.entries
        .where((e) => e.status == CropTimelineStatus.overdue)
        .length;
    final due = plan.entries
        .where((e) => e.status == CropTimelineStatus.due)
        .length;
    final upcoming = plan.entries
        .where((e) => e.status == CropTimelineStatus.upcoming)
        .length;

    return FarmioSummaryBar(stats: [
      FarmioSummaryStat(
        label: 'Overdue',
        value: '$overdue',
        color: overdue > 0 ? Colors.redAccent : null,
      ),
      FarmioSummaryStat(
        label: 'Due now',
        value: '$due',
        color: due > 0 ? Colors.orangeAccent : null,
      ),
      FarmioSummaryStat(
        label: 'Upcoming',
        value: '$upcoming',
        color: Colors.lightBlueAccent,
      ),
      FarmioSummaryStat(
        label: 'Completed',
        value: '${plan.completedCount}',
        color: Colors.greenAccent,
      ),
    ]);
  }
}

class _TimelineRecommendationCard extends StatelessWidget {
  final CropTimelinePlan plan;
  const _TimelineRecommendationCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final next = plan.nextAction;
    if (next == null) {
      return FarmioCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.verified_outlined, color: FarmioColors.success),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'All expected crop timeline activities are recorded.',
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _showRecommendedActivities(context, plan),
                icon: const Icon(Icons.info_outline, size: 16),
                label: const Text('View expected activities'),
              ),
            ),
          ],
        ),
      );
    }

    final isOverdue = next.status == CropTimelineStatus.overdue;
    final isDue = next.status == CropTimelineStatus.due;
    final color = isOverdue
        ? FarmioColors.danger
        : isDue
            ? FarmioColors.warning
            : FarmioColors.primary;
    final label = isOverdue
        ? 'Overdue'
        : isDue
            ? 'Due now'
            : 'Next activity';

    return FarmioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.notification_important_outlined,
                  color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      )),
                  Text(next.step.title,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      )),
                ],
              ),
            ),
            Text(Fmt.dateShort(next.dueDate),
                style: TextStyle(
                  color: context.colors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                )),
          ]),
          const SizedBox(height: 10),
          Text(next.step.recommendation,
              style: TextStyle(
                color: context.colors.textSecond,
                height: 1.35,
              )),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _showTimelineEntryDetails(context, next),
              icon: const Icon(Icons.info_outline, size: 16),
              label: const Text('View activity details'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CropTimelineCard extends StatelessWidget {
  final CropTimelinePlan plan;
  const _CropTimelineCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return FarmioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text('Crop activity timeline',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  )),
            ),
            Text('${plan.completedCount}/${plan.entries.length} done',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textMuted,
                )),
          ]),
          const SizedBox(height: 4),
          Text(
            '${plan.sourceLabel}. Timings are general and should be adjusted for local advice, variety and weather.',
            style: TextStyle(
              fontSize: 11,
              height: 1.35,
              color: context.colors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          ...plan.entries.map(
            (entry) => _TimelineStepRow(
              entry: entry,
              onTap: () => _showTimelineEntryDetails(context, entry),
            ),
          ),
          const SizedBox(height: 2),
          TextButton.icon(
            onPressed: () => _showRecommendedActivities(context, plan),
            icon: const Icon(Icons.fact_check_outlined, size: 16),
            label: const Text('View all recommended activities'),
          ),
        ],
      ),
    );
  }
}

class _TimelineStepRow extends StatelessWidget {
  final CropTimelineEntry entry;
  final VoidCallback onTap;
  const _TimelineStepRow({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context, entry.status);
    final icon = _statusIcon(entry.status);
    final label = _statusLabel(entry);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(entry.step.title,
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          )),
                    ),
                    Text(label,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        )),
                  ]),
                  const SizedBox(height: 2),
                  Text(
                    entry.completedDate == null
                        ? 'Due ${Fmt.dateShort(entry.dueDate)}'
                        : 'Recorded ${Fmt.dateShort(entry.completedDate!)}',
                    style: TextStyle(
                      color: context.colors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right,
                size: 18, color: context.colors.textMuted),
          ],
        ),
      ),
    );
  }

  static Color _statusColor(BuildContext context, CropTimelineStatus status) {
    switch (status) {
      case CropTimelineStatus.done:
        return FarmioColors.success;
      case CropTimelineStatus.overdue:
        return FarmioColors.danger;
      case CropTimelineStatus.due:
        return FarmioColors.warning;
      case CropTimelineStatus.upcoming:
        return context.colors.textMuted;
    }
  }

  static IconData _statusIcon(CropTimelineStatus status) {
    switch (status) {
      case CropTimelineStatus.done:
        return Icons.check_circle_outline;
      case CropTimelineStatus.overdue:
        return Icons.error_outline;
      case CropTimelineStatus.due:
        return Icons.event_available_outlined;
      case CropTimelineStatus.upcoming:
        return Icons.schedule_outlined;
    }
  }

  static String _statusLabel(CropTimelineEntry entry) {
    switch (entry.status) {
      case CropTimelineStatus.done:
        return 'Done';
      case CropTimelineStatus.overdue:
        return 'Overdue';
      case CropTimelineStatus.due:
        return 'Due';
      case CropTimelineStatus.upcoming:
        return 'Upcoming';
    }
  }
}

void _showTimelineEntryDetails(
  BuildContext context,
  CropTimelineEntry entry,
) {
  final color = _TimelineStepRow._statusColor(context, entry.status);
  final status = _TimelineStepRow._statusLabel(entry);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _TimelineStepRow._statusIcon(entry.status),
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(status,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        )),
                    Text(entry.step.title,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        )),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _DetailLine(
              label: 'Activity type',
              value: entry.step.activityType,
            ),
            _DetailLine(
              label: 'Expected window',
              value:
                  '${Fmt.dateShort(entry.startDate)} - ${Fmt.dateShort(entry.endDate)}',
            ),
            _DetailLine(
              label: 'Generally due',
              value: Fmt.date(entry.dueDate),
            ),
            if (entry.completedDate != null)
              _DetailLine(
                label: 'Recorded',
                value: Fmt.date(entry.completedDate!),
              ),
            const SizedBox(height: 14),
            Text('Recommendation',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w800,
                )),
            const SizedBox(height: 6),
            Text(entry.step.recommendation,
                style: TextStyle(
                  color: context.colors.textSecond,
                  height: 1.4,
                )),
            const SizedBox(height: 12),
            Text(
              'This is guidance only. Adjust for local extension advice, variety, rainfall, irrigation and field conditions.',
              style: TextStyle(
                color: context.colors.textMuted,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showRecommendedActivities(
  BuildContext context,
  CropTimelinePlan plan,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, controller) => SafeArea(
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl2),
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Recommended activities',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                )),
            const SizedBox(height: 4),
            Text(
              '${plan.sourceLabel}. Tap an item for details.',
              style: TextStyle(
                color: context.colors.textMuted,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            ...plan.entries.map(
              (entry) => _RecommendedActivitySheetRow(entry: entry),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RecommendedActivitySheetRow extends StatelessWidget {
  final CropTimelineEntry entry;
  const _RecommendedActivitySheetRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = _TimelineStepRow._statusColor(context, entry.status);
    final status = _TimelineStepRow._statusLabel(entry);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => _showTimelineEntryDetails(context, entry),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(children: [
            Icon(_TimelineStepRow._statusIcon(entry.status),
                color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.step.title,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      )),
                  Text(
                    '${entry.step.activityType} - due ${Fmt.dateShort(entry.dueDate)}',
                    style: TextStyle(
                      color: context.colors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(status,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                )),
          ]),
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;
  const _DetailLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(label,
                style: TextStyle(
                  color: context.colors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                )),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                )),
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String   label;
  final double   value;
  final IconData icon;
  final bool     isBold;

  const _CostRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(children: [
        Icon(icon, size: 16, color: context.colors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: TextStyle(
                fontSize:   13,
                fontWeight: isBold
                    ? FontWeight.w800
                    : FontWeight.w500,
                color: context.colors.textPrimary,
              )),
        ),
        Text(Fmt.mwk(value),
            style: TextStyle(
              fontSize:   13,
              fontWeight: isBold
                  ? FontWeight.w800
                  : FontWeight.w600,
              color: isBold
                  ? FarmioColors.primary
                  : context.colors.textPrimary,
            )),
      ]),
    );
  }
}

class _YieldTile extends ConsumerWidget {
  final CropYield y;
  final String cropId;
  const _YieldTile({required this.y, required this.cropId});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete harvest record'),
        content: Text(
            'Delete ${y.quantity} ${y.unit} harvested on '
            '${Fmt.dateShort(y.harvestDate)}?'),
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
      await ref.read(yieldsRepositoryProvider).deleteYield(y.id);
      ref.invalidate(cropDetailProvider(cropId));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:        context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: context.colors.border),
      ),
      child: Row(children: [
        const Icon(Icons.agriculture_outlined,
            size: 24, color: FarmioColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${y.quantity} ${y.unit}',
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                )),
            Text(Fmt.kg(y.totalKg),
                style: TextStyle(
                  fontSize: 12, color: context.colors.textMuted,
                )),
          ],
        )),
        Text(Fmt.dateShort(y.harvestDate),
            style: TextStyle(
              fontSize: 11, color: context.colors.textMuted,
            )),
        IconButton(
          onPressed: () => _confirmDelete(context, ref),
          icon: const Icon(Icons.delete_outline,
              size: 18, color: FarmioColors.danger),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
        ),
      ]),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final CropActivity a;
  final VoidCallback onTap;
  const _ActivityTile({required this.a, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FarmioCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      radius: 12,
      child: Row(children: [
        Icon(
          Fmt.activityIconData(a.activityType),
          size: 20,
          color: FarmioColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a.activityType,
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                )),
            Text(Fmt.date(a.date),
                style: TextStyle(
                  fontSize: 12, color: context.colors.textMuted,
                )),
          ],
        )),
        if (a.totalCost > 0)
          Text(Fmt.mwk(a.totalCost),
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              )),
      ]),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label, value;
  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 10, color: context.colors.textMuted,
              )),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              )),
        ],
      ),
    );
  }
}

// ── Price suggestion panel (break-even / selling price) ──────────────────────
class _PriceSuggestionPanel extends StatelessWidget {
  final double totalCost;
  final double totalYieldKg;
  final double margin;
  final ValueChanged<double> onMarginChanged;

  const _PriceSuggestionPanel({
    required this.totalCost,
    required this.totalYieldKg,
    required this.margin,
    required this.onMarginChanged,
  });

  @override
  Widget build(BuildContext context) {
    final suggestion = YieldPriceSuggestion.compute(
      totalCost:    totalCost,
      totalYieldKg: totalYieldKg,
      marginPercent: margin,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:        FarmioColors.infoBg,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: FarmioColors.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Selling price suggestion',
                    style: TextStyle(
                      fontSize:   13,
                      fontWeight: FontWeight.w800,
                      color:      FarmioColors.info,
                    )),
              ),
              const Text('Target margin:',
                  style: TextStyle(
                    fontSize:   11,
                    fontWeight: FontWeight.w700,
                    color:      FarmioColors.info,
                  )),
              const SizedBox(width: 6),
              SizedBox(
                width: 52,
                height: 30,
                child: TextFormField(
                  initialValue: margin.round().toString(),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize:   12,
                    fontWeight: FontWeight.w700,
                    color:      FarmioColors.info,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    filled: true,
                    fillColor: context.colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: FarmioColors.primaryLight),
                    ),
                  ),
                  onChanged: (v) =>
                      onMarginChanged(double.tryParse(v) ?? margin),
                ),
              ),
              const SizedBox(width: 4),
              const Text('%',
                  style: TextStyle(
                    fontSize:   11,
                    fontWeight: FontWeight.w700,
                    color:      FarmioColors.info,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          if (totalYieldKg <= 0)
            const Text(
              'Record a harvest to see break-even and pricing suggestions.',
              style: TextStyle(fontSize: 12, color: FarmioColors.info),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PriceTile(
                    label: 'Break-even / kg',
                    value: suggestion.breakEvenPerKg),
                _PriceTile(
                    label: 'Break-even / 50 kg bag',
                    value: suggestion.breakEvenPerBag50),
                _PriceTile(
                    label: 'Break-even / tonne',
                    value: suggestion.breakEvenPerTonne),
                _PriceTile(
                    label: 'Suggested / kg (${margin.round()}%)',
                    value: suggestion.suggestedPerKg),
                _PriceTile(
                    label: 'Suggested / 50 kg bag',
                    value: suggestion.suggestedPerBag50),
                _PriceTile(
                    label: 'Projected profit',
                    value: suggestion.projectedProfit),
              ],
            ),
        ],
      ),
    );
  }
}

class _PriceTile extends StatelessWidget {
  final String label;
  final double? value;
  const _PriceTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color:        context.colors.surface,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: FarmioColors.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                fontSize:   10,
                fontWeight: FontWeight.w800,
                color:      FarmioColors.info,
              )),
          const SizedBox(height: 2),
          Text(value != null ? Fmt.mwk(value!) : '—',
              style: const TextStyle(
                fontSize:   13,
                fontWeight: FontWeight.w800,
                color:      FarmioColors.info,
              )),
        ],
      ),
    );
  }
}
