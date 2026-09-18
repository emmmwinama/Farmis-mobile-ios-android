import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/equipment.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_summary_bar.dart';
import 'equipment_detail_screen.dart';
import 'equipment_provider.dart';
import '../../core/theme/app_spacing.dart';

class EquipmentScreen extends ConsumerWidget {
  final bool embedded;
  const EquipmentScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipment = ref.watch(equipmentProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: embedded
          ? null
          : AppBar(
              title: const Text('Equipment',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.invalidate(equipmentProvider),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/equipment/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add equipment'),
      ),
      body: equipment.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(equipmentProvider),
        ),
        data: (items) => _EquipmentList(items: items),
      ),
    );
  }
}

class _EquipmentList extends StatelessWidget {
  final List<EquipmentModel> items;
  const _EquipmentList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            'No equipment registered yet.',
            style: TextStyle(color: context.colors.textMuted),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 96),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _EquipmentSummary(items: items),
          );
        }
        final item = items[index - 1];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push('/equipment/${item.id}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              children: [
                Icon(_categoryIcon(item.category),
                    color: FarmioColors.warning),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style:
                              const TextStyle(fontWeight: FontWeight.w800)),
                      Text(
                          '${equipmentCategoryLabel(item.category)}'
                          '${item.logCount > 0 ? ' · ${item.logCount} log${item.logCount == 1 ? '' : 's'}' : ''}',
                          style: TextStyle(
                              fontSize: 12, color: context.colors.textMuted)),
                    ],
                  ),
                ),
                _StatusChip(status: item.status),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: context.colors.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _categoryIcon(String category) => switch (category) {
        'tractor' => Icons.agriculture_outlined,
        'irrigation' => Icons.water_drop_outlined,
        'tool' => Icons.build_outlined,
        'vehicle' => Icons.local_shipping_outlined,
        _ => Icons.precision_manufacturing_outlined,
      };
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'under_repair' => FarmioColors.warning,
      'retired' => context.colors.textMuted,
      _ => FarmioColors.success,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(equipmentStatusLabel(status),
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _EquipmentSummary extends StatelessWidget {
  final List<EquipmentModel> items;
  const _EquipmentSummary({required this.items});

  @override
  Widget build(BuildContext context) {
    final active = items.where((e) => e.status == 'active').length;
    final maintenanceCost = items.fold(0.0, (s, e) => s + e.maintenanceCost);

    return FarmioSummaryBar(
      stats: [
        FarmioSummaryStat(label: 'Items', value: '${items.length}'),
        FarmioSummaryStat(label: 'Active', value: '$active'),
        FarmioSummaryStat(
          label: 'Maintenance',
          value: Fmt.mwk(maintenanceCost),
          color: Colors.orangeAccent,
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load equipment',
                style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.textMuted)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
