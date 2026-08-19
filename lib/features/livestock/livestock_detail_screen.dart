import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/livestock.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'livestock_provider.dart';

class AnimalDetailScreen extends ConsumerWidget {
  final String animalId;
  const AnimalDetailScreen({super.key, required this.animalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animal = ref.watch(animalDetailProvider(animalId));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Animal detail',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: animal.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Failed to load animal: $error'),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            _HeaderCard(animal: data),
            const SizedBox(height: 16),
            _RecordSection(
              title: 'Health',
              icon: Icons.medical_services_outlined,
              color: FarmioColors.warning,
              recordType: 'health',
              animalId: animalId,
              rows: data.healthRecords
                  .map((r) => _RecordRow(
                        title: r.type,
                        detail: r.description,
                        meta: Fmt.date(r.date),
                        value: r.cost > 0 ? Fmt.mwk(r.cost) : '',
                      ))
                  .toList(),
            ),
            _RecordSection(
              title: 'Production',
              icon: Icons.insights_outlined,
              color: FarmioColors.primary,
              recordType: 'production',
              animalId: animalId,
              rows: data.productions
                  .map((r) => _RecordRow(
                        title: r.type,
                        detail: '${r.quantity} ${r.unit}',
                        meta: Fmt.date(r.date),
                        value: r.totalValue != null
                            ? Fmt.mwk(r.totalValue!)
                            : '',
                      ))
                  .toList(),
            ),
            _RecordSection(
              title: 'Weight',
              icon: Icons.monitor_weight_outlined,
              color: FarmioColors.info,
              recordType: 'weight',
              animalId: animalId,
              rows: data.weightRecords
                  .map((r) => _RecordRow(
                        title: '${r.weight} ${r.unit}',
                        detail: r.notes ?? '',
                        meta: Fmt.date(r.date),
                        value: '',
                      ))
                  .toList(),
            ),
            _RecordSection(
              title: 'Expenses',
              icon: Icons.receipt_long_outlined,
              color: FarmioColors.danger,
              recordType: 'expense',
              animalId: animalId,
              rows: data.expenses
                  .map((r) => _RecordRow(
                        title: r.description,
                        detail: r.category,
                        meta: Fmt.date(r.date),
                        value: Fmt.mwk(r.amount),
                      ))
                  .toList(),
            ),
            _RecordSection(
              title: 'Sales',
              icon: Icons.sell_outlined,
              color: FarmioColors.success,
              recordType: 'sale',
              animalId: animalId,
              rows: data.sales
                  .map((r) => _RecordRow(
                        title: r.buyer ?? 'Sale',
                        detail: '${r.quantity} head',
                        meta: Fmt.date(r.saleDate),
                        value: Fmt.mwk(r.totalAmount),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Animal animal;
  const _HeaderCard({required this.animal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FarmioColors.slate800,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(animal.displayName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            '${animal.livestockTypeName ?? 'Livestock'} · ${animal.sex}${animal.breed != null ? ' · ${animal.breed}' : ''}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _HeaderStat(label: 'Status', value: animal.status),
              if (animal.weight != null)
                _HeaderStat(label: 'Weight', value: '${animal.weight} kg'),
              _HeaderStat(
                  label: 'Acquired', value: Fmt.date(animal.acquisitionDate)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeaderStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }
}

class _RecordRow {
  final String title;
  final String detail;
  final String meta;
  final String value;
  const _RecordRow({
    required this.title,
    required this.detail,
    required this.meta,
    required this.value,
  });
}

class _RecordSection extends ConsumerWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String recordType;
  final String animalId;
  final List<_RecordRow> rows;

  const _RecordSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.recordType,
    required this.animalId,
    required this.rows,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
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
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: FarmioColors.textPrimary)),
              ),
              TextButton.icon(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _RecordFormSheet(
                    recordType: recordType,
                    animalId: animalId,
                  ),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
              ),
            ],
          ),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text('No $title records yet.',
                  style: const TextStyle(
                      fontSize: 12, color: FarmioColors.textMuted)),
            )
          else
            ...rows.map((row) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(row.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                            if (row.detail.isNotEmpty)
                              Text(row.detail,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: FarmioColors.textMuted)),
                          ],
                        ),
                      ),
                      Text(row.meta,
                          style: const TextStyle(
                              fontSize: 11, color: FarmioColors.textMuted)),
                      if (row.value.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(row.value,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

class _RecordFormSheet extends ConsumerStatefulWidget {
  final String recordType;
  final String animalId;
  const _RecordFormSheet({required this.recordType, required this.animalId});

  @override
  ConsumerState<_RecordFormSheet> createState() => _RecordFormSheetState();
}

class _RecordFormSheetState extends ConsumerState<_RecordFormSheet> {
  final _primaryCtrl = TextEditingController(); // type/category
  final _descCtrl = TextEditingController(); // description/buyer/notes-ish
  final _secondaryCtrl = TextEditingController(); // unit/veterinarian
  final _amountCtrl = TextEditingController(); // cost/quantity/amount/weight/totalAmount
  final _priceCtrl = TextEditingController(); // pricePerUnit/pricePerKg
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _primaryCtrl.dispose();
    _descCtrl.dispose();
    _secondaryCtrl.dispose();
    _amountCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  String get _title {
    switch (widget.recordType) {
      case 'health':
        return 'Add health record';
      case 'production':
        return 'Add production record';
      case 'weight':
        return 'Add weight record';
      case 'expense':
        return 'Add expense';
      case 'sale':
        return 'Add sale';
      default:
        return 'Add record';
    }
  }

  Map<String, dynamic> _buildPayload() {
    final base = <String, dynamic>{
      'recordType': widget.recordType,
      'animalId': widget.animalId,
    };
    switch (widget.recordType) {
      case 'health':
        return {
          ...base,
          'type': _primaryCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'veterinarian': _secondaryCtrl.text.trim().isEmpty
              ? null
              : _secondaryCtrl.text.trim(),
          'cost': _amountCtrl.text.trim().isEmpty
              ? 0
              : num.tryParse(_amountCtrl.text.trim()) ?? 0,
          'date': _date.toIso8601String(),
          'notes': _notesCtrl.text.trim(),
        };
      case 'production':
        return {
          ...base,
          'type': _primaryCtrl.text.trim(),
          'quantity': num.tryParse(_amountCtrl.text.trim()) ?? 0,
          'unit': _secondaryCtrl.text.trim(),
          'date': _date.toIso8601String(),
          'pricePerUnit': _priceCtrl.text.trim().isEmpty
              ? null
              : num.tryParse(_priceCtrl.text.trim()),
          'notes': _notesCtrl.text.trim(),
        };
      case 'weight':
        return {
          ...base,
          'weight': num.tryParse(_amountCtrl.text.trim()) ?? 0,
          'unit':
              _secondaryCtrl.text.trim().isEmpty ? 'kg' : _secondaryCtrl.text.trim(),
          'date': _date.toIso8601String(),
          'notes': _notesCtrl.text.trim(),
        };
      case 'expense':
        return {
          ...base,
          'category': _primaryCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'amount': num.tryParse(_amountCtrl.text.trim()) ?? 0,
          'date': _date.toIso8601String(),
          'notes': _notesCtrl.text.trim(),
        };
      case 'sale':
        return {
          ...base,
          'saleDate': _date.toIso8601String(),
          'quantity': _amountCtrl.text.trim().isEmpty
              ? 1
              : int.tryParse(_amountCtrl.text.trim()) ?? 1,
          'pricePerKg': _priceCtrl.text.trim().isEmpty
              ? null
              : num.tryParse(_priceCtrl.text.trim()),
          'totalAmount': num.tryParse(_descCtrl.text.trim()) ?? 0,
          'buyer': _secondaryCtrl.text.trim().isEmpty
              ? null
              : _secondaryCtrl.text.trim(),
          'notes': _notesCtrl.text.trim(),
        };
      default:
        return base;
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(livestockRepositoryProvider)
          .addRecord(_buildPayload());
      ref.invalidate(animalDetailProvider(widget.animalId));
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = 'Could not save record: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<Widget> _fields() {
    switch (widget.recordType) {
      case 'health':
        return [
          TextField(
              controller: _primaryCtrl,
              decoration:
                  const InputDecoration(labelText: 'Type (e.g. Vaccination)')),
          const SizedBox(height: 12),
          TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 12),
          TextField(
              controller: _secondaryCtrl,
              decoration:
                  const InputDecoration(labelText: 'Veterinarian (optional)')),
          const SizedBox(height: 12),
          TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cost (optional)')),
        ];
      case 'production':
        return [
          TextField(
              controller: _primaryCtrl,
              decoration:
                  const InputDecoration(labelText: 'Type (e.g. Milk, Eggs)')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity')),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                  controller: _secondaryCtrl,
                  decoration: const InputDecoration(labelText: 'Unit')),
            ),
          ]),
          const SizedBox(height: 12),
          TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Price per unit (optional)')),
        ];
      case 'weight':
        return [
          Row(children: [
            Expanded(
              child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Weight')),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                  controller: _secondaryCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Unit (default kg)')),
            ),
          ]),
        ];
      case 'expense':
        return [
          TextField(
              controller: _primaryCtrl,
              decoration: const InputDecoration(labelText: 'Category')),
          const SizedBox(height: 12),
          TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 12),
          TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount')),
        ];
      case 'sale':
        return [
          Row(children: [
            Expanded(
              child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Quantity (default 1)')),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Price/kg (optional)')),
            ),
          ]),
          const SizedBox(height: 12),
          TextField(
              controller: _descCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total amount')),
          const SizedBox(height: 12),
          TextField(
              controller: _secondaryCtrl,
              decoration:
                  const InputDecoration(labelText: 'Buyer (optional)')),
        ];
      default:
        return const [];
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                ..._fields(),
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
                  decoration:
                      const InputDecoration(labelText: 'Notes (optional)'),
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
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
