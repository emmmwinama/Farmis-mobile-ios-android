import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/limits/limits_gate.dart';
import '../../core/theme/app_theme.dart';
import '../../models/field.dart';
import '../../shared/filters/entity_filter_bar.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_card.dart';
import '../../shared/widgets/farmio_shimmer.dart';
import '../../shared/widgets/farmio_summary_bar.dart';
import 'fields_provider.dart';

class FieldsScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const FieldsScreen({super.key, this.embedded = false});

  @override
  ConsumerState<FieldsScreen> createState() => _FieldsScreenState();
}

class _FieldsScreenState extends ConsumerState<FieldsScreen> {
  String _soilTypeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final fields = ref.watch(fieldsProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: widget.embedded
          ? null
          : AppBar(
              title: const Text('Fields',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addField(context, ref),
                ),
              ],
            ),
      body: fields.when(
        loading: () => const _FieldsSkeleton(),
        error:   (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(fieldsProvider),
        ),
        data: (list) {
          if (list.isEmpty) return const _EmptyState();

          final soilTypes = {...list.map((f) => f.soilType)}.toList();
          final filtered = _soilTypeFilter == 'All'
              ? list
              : list.where((f) => f.soilType == _soilTypeFilter).toList();

          return RefreshIndicator(
            color:     FarmioColors.primary,
            onRefresh: () async => ref.invalidate(fieldsProvider),
            child: ListView.separated(
              padding:   const EdgeInsets.all(20),
              itemCount: (filtered.isEmpty ? 1 : filtered.length) + 2,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                if (i == 0) return _FieldsSummary(fields: list);
                if (i == 1) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: EntityFilterBar(
                      dimensions: [
                        FilterDimension(
                          label: 'Soil type',
                          icon: Icons.grain_outlined,
                          value: _soilTypeFilter,
                          options: soilTypes,
                          onSelected: (v) =>
                              setState(() => _soilTypeFilter = v),
                        ),
                      ],
                    ),
                  );
                }
                if (filtered.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No fields match this filter',
                        style: TextStyle(color: FarmioColors.textMuted),
                      ),
                    ),
                  );
                }
                final field = filtered[i - 2];
                return _FieldCard(
                  field:   field,
                  onTap:   () => context.push('/fields/${field.id}'),
                  onDelete: () => _confirmDelete(context, ref, field),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: FarmioColors.primary,
        onPressed: () => _addField(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _addField(BuildContext context, WidgetRef ref) async {
    if (!await ensureCanAdd(context, ref, LimitResource.fields)) return;
    if (context.mounted) context.push('/fields/new');
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, FieldModel field) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete field'),
        content: Text('Delete "${field.name}"? This cannot be undone.'),
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
      await ref.read(fieldsRepositoryProvider).deleteField(field.id);
      ref.invalidate(fieldsProvider);
    }
  }
}

// ── Summary ───────────────────────────────────────────────────────────────────
class _FieldsSummary extends StatelessWidget {
  final List<FieldModel> fields;
  const _FieldsSummary({required this.fields});

  @override
  Widget build(BuildContext context) {
    final totalArea = fields.fold(0.0, (s, f) => s + f.totalArea);
    final allocated = fields.fold(0.0, (s, f) => s + f.allocatedArea);
    final available = fields.fold(0.0, (s, f) => s + f.availableArea);
    final pct = totalArea > 0 ? (allocated / totalArea).clamp(0.0, 1.0) : 0.0;

    return FarmioSummaryBar(
      stats: [
        FarmioSummaryStat(label: 'Fields', value: '${fields.length}'),
        FarmioSummaryStat(
            label: 'Total area', value: Fmt.haShort(totalArea)),
        FarmioSummaryStat(
            label: 'Allocated', value: Fmt.haShort(allocated)),
        FarmioSummaryStat(
            label: 'Available', value: Fmt.haShort(available)),
      ],
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Text('${(pct * 100).toStringAsFixed(0)}% of total area allocated',
              style: const TextStyle(fontSize: 11, color: Colors.white60)),
        ],
      ),
    );
  }
}

// ── Field card ────────────────────────────────────────────────────────────────
class _FieldCard extends StatelessWidget {
  final FieldModel  field;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FieldCard({
    required this.field,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final usedPct = field.cultivatableArea > 0
        ? (field.allocatedArea / field.cultivatableArea).clamp(0.0, 1.0)
        : 0.0;

    return FarmioCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      radius: 18,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color:        FarmioColors.primary.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.map_outlined,
                      color: FarmioColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(field.name,
                          style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          )),
                      Text(field.soilType,
                          style: TextStyle(
                            fontSize: 12, color: colors.textMuted,
                          )),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) { if (v == 'delete') onDelete(); },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline,
                            color: FarmioColors.danger, size: 18),
                        SizedBox(width: 8),
                        Text('Delete',
                            style: TextStyle(color: FarmioColors.danger)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Area stats
            Row(
              children: [
                _AreaChip(
                    label: 'Total',
                    value: Fmt.haShort(field.totalArea)),
                const SizedBox(width: 8),
                _AreaChip(
                    label: 'Cultivatable',
                    value: Fmt.haShort(field.cultivatableArea)),
                const SizedBox(width: 8),
                _AreaChip(
                    label: 'Available',
                    value: Fmt.haShort(field.availableArea),
                    color: field.availableArea > 0
                        ? FarmioColors.success
                        : FarmioColors.danger),
              ],
            ),
            const SizedBox(height: 12),

            // Land use bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Land use',
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: colors.textMuted,
                        )),
                    Text('${(usedPct * 100).toStringAsFixed(0)}% allocated',
                        style: TextStyle(
                          fontSize: 11, color: colors.textMuted,
                        )),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:           usedPct,
                    minHeight:       6,
                    backgroundColor: colors.border,
                    valueColor:      AlwaysStoppedAnimation<Color>(
                      usedPct >= 1.0
                          ? FarmioColors.danger
                          : FarmioColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Crops
            if (field.crops.isNotEmpty)
              Wrap(
                spacing:  6,
                runSpacing: 4,
                children: field.crops.map((c) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: FarmioColors.primary.withValues(alpha:0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(c,
                      style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: FarmioColors.primary,
                      )),
                )).toList(),
              )
            else
              Text('No active crops',
                  style: TextStyle(
                    fontSize: 12, color: colors.textMuted,
                  )),
          ],
        ),
    );
  }
}

class _AreaChip extends StatelessWidget {
  final String label, value;
  final Color? color;
  const _AreaChip({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color:        colors.background,
          borderRadius: BorderRadius.circular(10),
        ),
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
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: color ?? colors.textPrimary,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────
class _FieldsSkeleton extends StatelessWidget {
  const _FieldsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding:          const EdgeInsets.all(20),
      itemCount:        3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder:      (_, __) => const FarmioShimmer(
        width: double.infinity,
        height: 160,
        radius: 18,
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined,
              size: 56, color: FarmioColors.primary),
          const SizedBox(height: 16),
          Text('No fields yet',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              )),
          const SizedBox(height: 6),
          Text('Tap + to add your first field',
              style: TextStyle(color: colors.textMuted)),
        ],
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: FarmioColors.danger),
            const SizedBox(height: 12),
            Text('Could not load fields',
                style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                )),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon:       const Icon(Icons.refresh),
              label:      const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
