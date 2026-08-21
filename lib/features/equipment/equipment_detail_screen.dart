import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/equipment_item.dart';
import '../../models/overhead.dart';
import '../../shared/utils/formatters.dart';
import 'equipment_provider.dart';
import 'equipment_screen.dart';

/// Equipment doesn't have a dedicated maintenance-log backend record — fuel
/// and service costs are farm-wide `OverheadExpense` entries with no link to
/// a specific equipment item. This screen shows the entries whose
/// description mentions the equipment by name (best-effort, since that's the
/// only association available) and lets the user add more with the name
/// pre-filled so they stay attributable going forward.
class EquipmentDetailScreen extends ConsumerWidget {
  final EquipmentItem item;
  final List<OverheadExpense> allCosts;

  const EquipmentDetailScreen({
    super.key,
    required this.item,
    required this.allCosts,
  });

  List<OverheadExpense> get _linkedCosts => allCosts
      .where((c) =>
          c.description.toLowerCase().contains(item.name.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linked = _linkedCosts;
    final totalCost = linked.fold(0.0, (s, c) => s + c.amount);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(item.name,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Delete equipment',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDeleteEquipment(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) =>
                EquipmentCostForm(initialDescription: item.name),
          );
          ref.invalidate(equipmentProvider);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add log'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FarmioColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: FarmioColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: FarmioColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.precision_manufacturing_outlined,
                          color: FarmioColors.warning),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: FarmioColors.textPrimary,
                              )),
                          Text(
                              '${item.quantity.toStringAsFixed(0)} ${item.unit}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: FarmioColors.textMuted,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                if (item.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  const Divider(color: FarmioColors.border, height: 1),
                  const SizedBox(height: 12),
                  Text(item.notes!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: FarmioColors.textSecond,
                      )),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text('Fuel & service logs',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: FarmioColors.textPrimary,
                    )),
              ),
              if (linked.isNotEmpty)
                Text(Fmt.mwk(totalCost),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: FarmioColors.danger,
                    )),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Matched by equipment name — fuel/service costs entered '
            'elsewhere with this equipment\'s name in the description '
            'also show up here.',
            style: TextStyle(fontSize: 11, color: FarmioColors.textMuted),
          ),
          const SizedBox(height: 12),
          if (linked.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: FarmioColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: FarmioColors.border),
              ),
              child: const Column(
                children: [
                  Icon(Icons.build_outlined,
                      size: 36, color: FarmioColors.textMuted),
                  SizedBox(height: 8),
                  Text('No logs recorded for this equipment yet',
                      style: TextStyle(color: FarmioColors.textMuted)),
                ],
              ),
            )
          else
            ...linked.map((cost) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: FarmioColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: FarmioColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cost.description,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800)),
                            Text(
                                '${cost.category} · ${Fmt.date(cost.date)}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: FarmioColors.textMuted)),
                          ],
                        ),
                      ),
                      Text(Fmt.mwk(cost.amount),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: FarmioColors.danger)),
                      IconButton(
                        tooltip: 'Delete log',
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: FarmioColors.textMuted),
                        onPressed: () => _confirmDeleteCost(context, ref, cost),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteEquipment(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete equipment'),
        content: Text('Delete "${item.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: FarmioColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await ref.read(equipmentRepositoryProvider).deleteEquipment(item.id);
    ref.invalidate(equipmentProvider);
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _confirmDeleteCost(
      BuildContext context, WidgetRef ref, OverheadExpense cost) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete log'),
        content: Text('Delete "${cost.description}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: FarmioColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(equipmentRepositoryProvider).deleteCost(cost.id);
      ref.invalidate(equipmentProvider);
    }
  }
}
