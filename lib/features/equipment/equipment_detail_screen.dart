import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/equipment.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'equipment_provider.dart';

class EquipmentDetailScreen extends ConsumerWidget {
  final String equipmentId;
  const EquipmentDetailScreen({super.key, required this.equipmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipment = ref.watch(equipmentDetailProvider(equipmentId));
    final logs = ref.watch(equipmentLogsProvider(equipmentId));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Equipment detail',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          equipment.whenOrNull(
                data: (data) => IconButton(
                  tooltip: 'Edit equipment',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push('/equipment/new', extra: data),
                ),
              ) ??
              const SizedBox(),
          IconButton(
            tooltip: 'Delete equipment',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDeleteEquipment(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _LogFormSheet(equipmentId: equipmentId),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add log'),
      ),
      body: equipment.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Failed to load equipment: $error'),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            _HeaderCard(item: data),
            const SizedBox(height: 16),
            Text('Maintenance logs',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                )),
            const SizedBox(height: 12),
            logs.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => FarmioErrorBanner(message: '$error'),
              data: (rows) => rows.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.build_outlined,
                              size: 36, color: context.colors.textMuted),
                          SizedBox(height: 8),
                          Text('No logs recorded for this equipment yet',
                              style: TextStyle(color: context.colors.textMuted)),
                        ],
                      ),
                    )
                  : Column(
                      children: rows
                          .map((log) => _LogRow(
                                log: log,
                                onDelete: () =>
                                    _confirmDeleteLog(context, ref, log),
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteEquipment(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete equipment'),
        content: const Text('Delete this equipment? This cannot be undone.'),
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

    await ref.read(equipmentRepositoryProvider).deleteEquipment(equipmentId);
    ref.invalidate(equipmentProvider);
    if (context.mounted) context.pop();
  }

  Future<void> _confirmDeleteLog(
      BuildContext context, WidgetRef ref, EquipmentMaintenanceLog log) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete log'),
        content: Text('Delete "${log.description}"? This cannot be undone.'),
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
      await ref.read(equipmentRepositoryProvider).deleteLog(equipmentId, log.id);
      ref.invalidate(equipmentLogsProvider(equipmentId));
      ref.invalidate(equipmentProvider);
    }
  }
}

class _HeaderCard extends StatelessWidget {
  final EquipmentModel item;
  const _HeaderCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
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
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: context.colors.textPrimary,
                        )),
                    Text(
                        '${equipmentCategoryLabel(item.category)} · ${equipmentStatusLabel(item.status)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textMuted,
                        )),
                  ],
                ),
              ),
              if (item.maintenanceCost > 0)
                Text(Fmt.mwk(item.maintenanceCost),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: FarmioColors.danger)),
            ],
          ),
          if (item.acquisitionDate != null || item.acquisitionCost != null) ...[
            const SizedBox(height: 12),
            Divider(color: context.colors.border, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                if (item.acquisitionDate != null)
                  Text('Acquired ${Fmt.date(item.acquisitionDate!)}',
                      style: TextStyle(
                          fontSize: 12, color: context.colors.textSecond)),
                if (item.acquisitionDate != null && item.acquisitionCost != null)
                  Text('  ·  ',
                      style: TextStyle(color: context.colors.textMuted)),
                if (item.acquisitionCost != null)
                  Text('Cost ${Fmt.mwk(item.acquisitionCost!)}',
                      style: TextStyle(
                          fontSize: 12, color: context.colors.textSecond)),
              ],
            ),
          ],
          if (item.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Divider(color: context.colors.border, height: 1),
            const SizedBox(height: 12),
            Text(item.notes!,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textSecond,
                )),
          ],
        ],
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  final EquipmentMaintenanceLog log;
  final VoidCallback onDelete;
  const _LogRow({required this.log, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.description,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                    '${Fmt.date(log.date)}${log.hoursUsed != null ? ' · ${log.hoursUsed} hrs' : ''}',
                    style: TextStyle(
                        fontSize: 12, color: context.colors.textMuted)),
              ],
            ),
          ),
          if (log.cost > 0)
            Text(Fmt.mwk(log.cost),
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: FarmioColors.danger)),
          IconButton(
            tooltip: 'Delete log',
            icon: Icon(Icons.delete_outline,
                size: 18, color: context.colors.textMuted),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _LogFormSheet extends ConsumerStatefulWidget {
  final String equipmentId;
  const _LogFormSheet({required this.equipmentId});

  @override
  ConsumerState<_LogFormSheet> createState() => _LogFormSheetState();
}

class _LogFormSheetState extends ConsumerState<_LogFormSheet> {
  final _descCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _descCtrl.dispose();
    _costCtrl.dispose();
    _hoursCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_descCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Description is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    final data = {
      'date': _date.toIso8601String(),
      'description': _descCtrl.text.trim(),
      'cost': _costCtrl.text.trim().isEmpty ? 0 : _costCtrl.text.trim(),
      'hoursUsed': _hoursCtrl.text.trim().isEmpty ? null : _hoursCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
    };

    try {
      await ref.read(equipmentRepositoryProvider).addLog(widget.equipmentId, data);
      ref.invalidate(equipmentLogsProvider(widget.equipmentId));
      ref.invalidate(equipmentProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Could not save log: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add maintenance log',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _costCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Cost (optional)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _hoursCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Hours used (optional)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Text('${_date.day}/${_date.month}/${_date.year}'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                FarmioErrorBanner(message: _error!),
              ],
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Save log'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
