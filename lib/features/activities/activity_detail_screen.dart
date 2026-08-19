import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/activity_detail.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_card.dart';
import 'activities_provider.dart';

class ActivityDetailScreen extends ConsumerWidget {
  final String activityId;
  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(activityDetailProvider(activityId));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Activity detail',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          detail.whenOrNull(
            data: (a) => IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: FarmioColors.danger),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title:   const Text('Delete activity'),
                    content: const Text(
                        'This will delete all associated inputs, labour and costs.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Delete',
                            style: TextStyle(
                                color: FarmioColors.danger)),
                      ),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  await ref
                      .read(activitiesRepositoryProvider)
                      .deleteActivity(activityId);
                  if (context.mounted) context.pop();
                }
              },
            ),
          ) ?? const SizedBox(),
        ],
      ),
      body: detail.when(
        loading: () => const Center(
            child: CircularProgressIndicator(
                color: FarmioColors.primary)),
        error:   (e, _) => Center(child: Text(e.toString())),
        data:    (a)    => _DetailContent(activity: a),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final ActivityDetail activity;
  const _DetailContent({required this.activity});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [

        // Header card
        FarmioCard(child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color:        FarmioColors.primary.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Fmt.activityIconData(activity.activityType),
              color: FarmioColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(activity.activityType,
                  style: const TextStyle(
                    fontSize:   18,
                    fontWeight: FontWeight.w800,
                    color:      FarmioColors.textPrimary,
                  )),
              Text(activity.fieldName +
                  (activity.cropName != null
                      ? ' · ${activity.cropName}'
                      : ''),
                  style: const TextStyle(
                    fontSize: 13,
                    color:    FarmioColors.textMuted,
                  )),
              const SizedBox(height: 4),
              Text(Fmt.date(activity.date),
                  style: const TextStyle(
                    fontSize:   12,
                    color:      FarmioColors.textMuted,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          )),
        ])),

        if (activity.notes != null &&
            activity.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          FarmioCard(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notes',
                  style: TextStyle(
                    fontSize:   12,
                    fontWeight: FontWeight.w700,
                    color:      FarmioColors.textMuted,
                  )),
              const SizedBox(height: 6),
              Text(activity.notes!,
                  style: const TextStyle(
                    fontSize: 14,
                    color:    FarmioColors.textPrimary,
                  )),
            ],
          )),
        ],

        const SizedBox(height: 16),

        // Cost summary
        FarmioCard(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cost summary',
                style: TextStyle(
                  fontSize:   14,
                  fontWeight: FontWeight.w800,
                  color:      FarmioColors.textPrimary,
                )),
            const SizedBox(height: 12),
            _CostRow(
              label: 'Inputs',
              value: activity.costs.inputs,
              icon:  Icons.science_outlined,
            ),
            _CostRow(
              label: 'Labour',
              value: activity.costs.labour,
              icon:  Icons.people_outline,
            ),
            _CostRow(
              label: 'Other costs',
              value: activity.costs.other,
              icon:  Icons.more_horiz,
            ),
            const Divider(color: FarmioColors.border),
            _CostRow(
              label:  'Total',
              value:  activity.costs.total,
              icon:   Icons.account_balance_outlined,
              isBold: true,
            ),
          ],
        )),
        const SizedBox(height: 16),

        // Inputs
        _SectionHeader(
          title:   'Inputs (${activity.inputs.length})',
          icon:    Icons.science_outlined,
        ),
        const SizedBox(height: 10),
        if (activity.inputs.isEmpty)
          _EmptySection(label: 'No inputs recorded')
        else
          ...activity.inputs.map((i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child:   _InputTile(input: i),
          )),

        const SizedBox(height: 16),

        // Labour
        _SectionHeader(
          title: 'Labour (${activity.labourRecords.length})',
          icon:  Icons.people_outline,
        ),
        const SizedBox(height: 10),
        if (activity.labourRecords.isEmpty)
          _EmptySection(label: 'No labour recorded')
        else
          ...activity.labourRecords.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child:   _LabourTile(labour: l),
          )),

        const SizedBox(height: 16),

        // Other costs
        _SectionHeader(
          title: 'Other costs (${activity.otherCosts.length})',
          icon:  Icons.receipt_outlined,
        ),
        const SizedBox(height: 10),
        if (activity.otherCosts.isEmpty)
          _EmptySection(label: 'No other costs recorded')
        else
          ...activity.otherCosts.map((o) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child:   _OtherCostTile(cost: o),
          )),

        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────
class _InputTile extends StatelessWidget {
  final ActivityInput input;
  const _InputTile({required this.input});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(input.inputName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize:   13,
                      fontWeight: FontWeight.w700,
                      color:      FarmioColors.textPrimary,
                    )),
              ),
              const SizedBox(width: 8),
              Text(Fmt.mwk(input.totalCost),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w800,
                    color:      FarmioColors.primary,
                  )),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${input.quantity} ${input.unit} × ${Fmt.mwk(input.unitCost)} · ${input.category}',
            style: const TextStyle(
              fontSize: 12,
              color:    FarmioColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabourTile extends StatelessWidget {
  final ActivityLabour labour;
  const _LabourTile({required this.labour});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: context.colors.border),
      ),
      child: Row(children: [
        const Icon(Icons.person_outline,
            size: 20, color: FarmioColors.textMuted),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(labour.employeeName,
                style: const TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w700,
                  color:      FarmioColors.textPrimary,
                )),
            Text(
              '${labour.daysWorked} days · ${labour.hoursWorked} hrs',
              style: const TextStyle(
                fontSize: 12,
                color:    FarmioColors.textMuted,
              ),
            ),
          ],
        )),
        Text(Fmt.mwk(labour.totalCost),
            style: const TextStyle(
              fontSize:   13,
              fontWeight: FontWeight.w800,
              color:      FarmioColors.primary,
            )),
      ]),
    );
  }
}

class _OtherCostTile extends StatelessWidget {
  final ActivityOtherCost cost;
  const _OtherCostTile({required this.cost});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: context.colors.border),
      ),
      child: Row(children: [
        const Icon(Icons.receipt_outlined,
            size: 18, color: FarmioColors.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(cost.description,
              style: const TextStyle(
                fontSize:   13,
                fontWeight: FontWeight.w600,
                color:      FarmioColors.textPrimary,
              )),
        ),
        Text(Fmt.mwk(cost.amount),
            style: const TextStyle(
              fontSize:   13,
              fontWeight: FontWeight.w800,
              color:      FarmioColors.primary,
            )),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String   title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: FarmioColors.primary),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(
            fontSize:   16,
            fontWeight: FontWeight.w800,
            color:      FarmioColors.textPrimary,
          )),
    ]);
  }
}

class _EmptySection extends StatelessWidget {
  final String label;
  const _EmptySection({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: context.colors.border),
      ),
      child: Center(
        child: Text(label,
            style: const TextStyle(
              fontSize: 13,
              color:    FarmioColors.textMuted,
            )),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 16, color: FarmioColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: TextStyle(
                fontSize:   13,
                fontWeight: isBold
                    ? FontWeight.w800
                    : FontWeight.w500,
                color:      FarmioColors.textPrimary,
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
                  : FarmioColors.textPrimary,
            )),
      ]),
    );
  }
}
