import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/field_detail.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_card.dart';
import '../../shared/widgets/farmio_summary_bar.dart';
import 'fields_provider.dart';

class FieldDetailScreen extends ConsumerWidget {
  final String fieldId;
  const FieldDetailScreen({super.key, required this.fieldId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(fieldDetailProvider(fieldId));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Field detail',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.gps_fixed_outlined),
            tooltip: 'Boundary & zones',
            onPressed: () => context.push('/fields/$fieldId/boundary'),
          ),
        ],
      ),
      body: detail.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: FarmioColors.primary)),
        error:   (e, _) => _FieldErrorView(
          error: e,
          onRetry: () => ref.invalidate(fieldDetailProvider(fieldId)),
        ),
        data:    (f)    => _DetailContent(field: f),
      ),
    );
  }
}

class _FieldErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _FieldErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 46, color: FarmioColors.danger),
            const SizedBox(height: 12),
            Text('Could not load field',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                )),
            const SizedBox(height: 8),
            Text(
              _messageFor(error),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textMuted,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  static String _messageFor(Object error) =>
      'The field details could not be loaded.';
}

class _DetailContent extends StatelessWidget {
  final FieldDetail field;
  const _DetailContent({required this.field});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final usedPct = field.cultivatableArea > 0
        ? (field.allocatedArea / field.cultivatableArea).clamp(0.0, 1.0)
        : 0.0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [

        // Summary
        FarmioSummaryBar(
          stats: [
            FarmioSummaryStat(
                label: 'Cultivatable', value: Fmt.haShort(field.cultivatableArea)),
            FarmioSummaryStat(
                label: 'Allocated', value: Fmt.haShort(field.allocatedArea)),
            FarmioSummaryStat(
              label: 'Active crops',
              value: '${field.crops.where((c) => c.status == 'Active').length}',
            ),
            FarmioSummaryStat(
                label: 'Activities', value: '${field.recentActivities.length}'),
          ],
        ),
        const SizedBox(height: 16),

        // Info card
        FarmioCard(
          padding: const EdgeInsets.all(18),
          radius: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color:        FarmioColors.primary.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.map_outlined,
                      color: FarmioColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(field.name,
                        style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        )),
                    Text(field.soilType,
                        style: TextStyle(
                          fontSize: 13, color: colors.textMuted,
                        )),
                  ],
                )),
              ]),
              const SizedBox(height: 16),
              Divider(color: colors.border),
              const SizedBox(height: 16),
              Row(children: [
                _InfoItem(label: 'Total area',       value: Fmt.haShort(field.totalArea)),
                _InfoItem(label: 'Cultivatable',     value: Fmt.haShort(field.cultivatableArea)),
                _InfoItem(label: 'Available',        value: Fmt.haShort(field.availableArea)),
              ]),
              const SizedBox(height: 16),

              // Progress bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Land allocated',
                      style: TextStyle(fontSize: 12, color: colors.textMuted)),
                  Text('${(usedPct * 100).toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 12, color: colors.textMuted)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value:           usedPct,
                  minHeight:       8,
                  backgroundColor: colors.border,
                  valueColor:      AlwaysStoppedAnimation<Color>(
                    usedPct >= 1.0 ? FarmioColors.danger : FarmioColors.primary,
                  ),
                ),
              ),

              if (field.notes != null && field.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Notes',
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: colors.textMuted,
                    )),
                const SizedBox(height: 4),
                Text(field.notes!,
                    style: TextStyle(
                      fontSize: 13, color: colors.textPrimary,
                    )),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Crops
        Text('Crops on this field',
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            )),
        const SizedBox(height: 10),

        if (field.crops.isEmpty)
          FarmioCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text('No crops on this field',
                    style: TextStyle(color: colors.textMuted)),
              ),
            ),
          )
        else
          ...field.crops.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child:   _CropTile(crop: c),
          )),

        const SizedBox(height: 16),

        // Recent activities
        Text('Recent activities',
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            )),
        const SizedBox(height: 10),

        if (field.recentActivities.isEmpty)
          FarmioCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text('No activities recorded',
                    style: TextStyle(color: colors.textMuted)),
              ),
            ),
          )
        else
          ...field.recentActivities.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child:   _ActivityTile(activity: a),
          )),
      ],
    );
  }
}

class _CropTile extends StatelessWidget {
  final FieldCrop crop;
  const _CropTile({required this.crop});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final days     = crop.daysToHarvest;
    final isActive = crop.status == 'Active';
    final isOverdue = isActive && days < 0;
    final isDueSoon = isActive && days >= 0 && days <= 14;

    Color statusColor = FarmioColors.primary;
    if (isOverdue)  statusColor = FarmioColors.danger;
    if (isDueSoon)  statusColor = FarmioColors.warning;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        colors.surface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color:        statusColor.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.grass_outlined,
                  size: 18, color: FarmioColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${crop.cropTypeName} · ${crop.variety}',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    )),
                Text('${crop.season} · ${Fmt.haShort(crop.areaPlanted)}',
                    style: TextStyle(
                      fontSize: 12, color: colors.textMuted,
                    )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:        statusColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(crop.status,
                    style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: statusColor,
                    )),
              ),
              const SizedBox(height: 4),
              Text(
                isOverdue
                    ? '${days.abs()}d overdue'
                    : isDueSoon
                    ? 'Due in ${days}d'
                    : 'Harvest ${Fmt.dateShort(crop.expectedHarvestDate)}',
                style: TextStyle(
                  fontSize: 10, color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final FieldActivity activity;
  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        colors.surface,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(
            Fmt.activityIconData(activity.activityType),
            size: 20,
            color: FarmioColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.activityType,
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    )),
                if (activity.cropName != null)
                  Text(activity.cropName!,
                      style: TextStyle(
                        fontSize: 12, color: colors.textMuted,
                      )),
              ],
            ),
          ),
          Text(Fmt.dateShort(activity.date),
              style: TextStyle(
                fontSize: 11, color: colors.textMuted,
              )),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label, value;
  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 10, color: colors.textMuted,
              )),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              )),
        ],
      ),
    );
  }
}
