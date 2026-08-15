import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/field.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_summary_bar.dart';
import 'fields_provider.dart';
import 'field_detail_screen.dart';
import 'field_form_screen.dart';

class FieldsScreen extends ConsumerWidget {
  const FieldsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fields = ref.watch(fieldsProvider);

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Fields',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(
                builder: (_) => const FieldFormScreen(),
              ));
              ref.refresh(fieldsProvider);
            },
          ),
        ],
      ),
      body: fields.when(
        loading: () => const _FieldsSkeleton(),
        error:   (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.refresh(fieldsProvider),
        ),
        data: (list) => list.isEmpty
            ? const _EmptyState()
            : RefreshIndicator(
          color:     FarmioColors.primary,
          onRefresh: () async => ref.refresh(fieldsProvider),
          child: ListView.separated(
            padding:   const EdgeInsets.all(20),
            itemCount: list.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              if (i == 0) return _FieldsSummary(fields: list);
              final field = list[i - 1];
              return _FieldCard(
                field:   field,
                onTap:   () async {
                  await Navigator.push(context, MaterialPageRoute(
                    builder: (_) => FieldDetailScreen(fieldId: field.id),
                  ));
                  ref.refresh(fieldsProvider);
                },
                onDelete: () => _confirmDelete(context, ref, field),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: FarmioColors.primary,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (_) => const FieldFormScreen(),
          ));
          ref.refresh(fieldsProvider);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, FieldModel field) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete field'),
        content: Text('Delete "${field.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: FarmioColors.danger)),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ref.read(fieldsRepositoryProvider).deleteField(field.id);
      ref.refresh(fieldsProvider);
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
    final usedPct = field.cultivatableArea > 0
        ? (field.allocatedArea / field.cultivatableArea).clamp(0.0, 1.0)
        : 0.0;

    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: FarmioColors.border),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withValues(alpha:0.04),
              blurRadius: 8,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
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
                          style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800,
                            color: FarmioColors.textPrimary,
                          )),
                      Text(field.soilType,
                          style: const TextStyle(
                            fontSize: 12, color: FarmioColors.textMuted,
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
                        ? const Color(0xFF16A34A)
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
                        style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: FarmioColors.textMuted,
                        )),
                    Text('${(usedPct * 100).toStringAsFixed(0)}% allocated',
                        style: const TextStyle(
                          fontSize: 11, color: FarmioColors.textMuted,
                        )),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:           usedPct,
                    minHeight:       6,
                    backgroundColor: FarmioColors.border,
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
                  style: const TextStyle(
                    fontSize: 12, color: FarmioColors.textMuted,
                  )),
          ],
        ),
      ),
    );
  }
}

class _AreaChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _AreaChip({
    required this.label,
    required this.value,
    this.color = FarmioColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color:        FarmioColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                  fontSize: 10, color: FarmioColors.textMuted,
                )),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: color,
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
      itemBuilder:      (_, __) => Container(
        height:      160,
        decoration:  BoxDecoration(
          color:        const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined,
              size: 56, color: FarmioColors.primary),
          const SizedBox(height: 16),
          const Text('No fields yet',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: FarmioColors.textPrimary,
              )),
          const SizedBox(height: 6),
          const Text('Tap + to add your first field',
              style: TextStyle(color: FarmioColors.textMuted)),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: FarmioColors.danger),
            const SizedBox(height: 12),
            const Text('Could not load fields',
                style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: FarmioColors.textPrimary,
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
