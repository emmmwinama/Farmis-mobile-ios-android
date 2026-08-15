import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/sync/offline_queued_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../models/equipment_item.dart';
import '../../models/overhead.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import '../../shared/widgets/farmio_summary_bar.dart';
import 'equipment_detail_screen.dart';
import 'equipment_provider.dart';

class EquipmentScreen extends ConsumerStatefulWidget {
  const EquipmentScreen({super.key});

  @override
  ConsumerState<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends ConsumerState<EquipmentScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final equipment = ref.watch(equipmentProvider);

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Equipment',
            style: TextStyle(fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: FarmioColors.primary,
          unselectedLabelColor: FarmioColors.textMuted,
          indicatorColor: FarmioColors.primary,
          tabs: const [
            Tab(text: 'Equipment'),
            Tab(text: 'Fuel & service'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(equipmentProvider),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) => FloatingActionButton.extended(
          onPressed: () => _tabController.index == 0
              ? _showEquipmentForm(context)
              : _showCostForm(context),
          icon: const Icon(Icons.add),
          label: Text(_tabController.index == 0 ? 'Add equipment' : 'Add cost'),
        ),
      ),
      body: equipment.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(equipmentProvider),
        ),
        data: (data) => TabBarView(
          controller: _tabController,
          children: [
            _EquipmentList(items: data.equipment, allCosts: data.costs),
            _CostsList(costs: data.costs),
          ],
        ),
      ),
    );
  }

  Future<void> _showEquipmentForm(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EquipmentForm(),
    );
  }

  Future<void> _showCostForm(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EquipmentCostForm(),
    );
  }
}

class _EquipmentList extends StatelessWidget {
  final List<EquipmentItem> items;
  final List<OverheadExpense> allCosts;
  const _EquipmentList({required this.items, required this.allCosts});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No equipment registered yet.',
            style: TextStyle(color: FarmioColors.textMuted),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _EquipmentSummary(items: items, allCosts: allCosts),
          );
        }
        final item = items[index - 1];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  EquipmentDetailScreen(item: item, allCosts: allCosts),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: FarmioColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: FarmioColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.precision_manufacturing_outlined,
                    color: FarmioColors.warning),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style:
                              const TextStyle(fontWeight: FontWeight.w800)),
                      if (item.notes?.isNotEmpty == true)
                        Text(item.notes!,
                            style: const TextStyle(
                                fontSize: 12, color: FarmioColors.textMuted)),
                    ],
                  ),
                ),
                Text('${item.quantity.toStringAsFixed(0)} ${item.unit}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: FarmioColors.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EquipmentSummary extends StatelessWidget {
  final List<EquipmentItem> items;
  final List<OverheadExpense> allCosts;
  const _EquipmentSummary({required this.items, required this.allCosts});

  @override
  Widget build(BuildContext context) {
    final totalCost = allCosts.fold(0.0, (s, c) => s + c.amount);
    final maintenanceCost = allCosts
        .where((c) => c.category == 'Maintenance')
        .fold(0.0, (s, c) => s + c.amount);

    return FarmioSummaryBar(
      stats: [
        FarmioSummaryStat(label: 'Items', value: '${items.length}'),
        FarmioSummaryStat(
            label: 'Fuel & service', value: Fmt.mwk(totalCost)),
        FarmioSummaryStat(
          label: 'Maintenance',
          value: Fmt.mwk(maintenanceCost),
          color: Colors.orangeAccent,
        ),
      ],
    );
  }
}

class _CostsList extends StatelessWidget {
  final List<OverheadExpense> costs;
  const _CostsList({required this.costs});

  @override
  Widget build(BuildContext context) {
    if (costs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No fuel or service costs recorded yet.',
            style: TextStyle(color: FarmioColors.textMuted),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      itemCount: costs.length,
      itemBuilder: (context, index) {
        final cost = costs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(cost.category,
                        style: const TextStyle(
                            fontSize: 12, color: FarmioColors.textMuted)),
                  ],
                ),
              ),
              Text(Fmt.mwk(cost.amount),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: FarmioColors.danger)),
            ],
          ),
        );
      },
    );
  }
}

class _EquipmentForm extends ConsumerStatefulWidget {
  const _EquipmentForm();

  @override
  ConsumerState<_EquipmentForm> createState() => _EquipmentFormState();
}

class _EquipmentFormState extends ConsumerState<_EquipmentForm> {
  final _nameCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: 'unit');
  final _quantityCtrl = TextEditingController(text: '1');
  final _notesCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _unitCtrl.dispose();
    _quantityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Name is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref.read(equipmentRepositoryProvider).addEquipment({
        'name': _nameCtrl.text.trim(),
        'unit': _unitCtrl.text.trim().isEmpty ? 'unit' : _unitCtrl.text.trim(),
        'quantity': _quantityCtrl.text.trim().isEmpty
            ? 1
            : num.tryParse(_quantityCtrl.text.trim()) ?? 1,
        'notes': _notesCtrl.text.trim(),
      });
      ref.invalidate(equipmentProvider);
      if (mounted) Navigator.pop(context);
    } on OfflineQueuedException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      setState(() => _error = data is Map<String, dynamic>
          ? data['error'] as String? ?? 'Could not save equipment.'
          : 'Could not save equipment.');
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add equipment',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Quantity'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _unitCtrl,
                      decoration: const InputDecoration(labelText: 'Unit'),
                    ),
                  ),
                ],
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
                      : const Text('Save equipment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EquipmentCostForm extends ConsumerStatefulWidget {
  final String? initialDescription;
  const EquipmentCostForm({super.key, this.initialDescription});

  @override
  ConsumerState<EquipmentCostForm> createState() => _EquipmentCostFormState();
}

class _EquipmentCostFormState extends ConsumerState<EquipmentCostForm> {
  late final _descCtrl =
      TextEditingController(text: widget.initialDescription ?? '');
  final _amountCtrl = TextEditingController();
  String _category = 'Machinery';
  DateTime _date = DateTime.now();
  bool _saving = false;
  String? _error;

  final _categories = const ['Machinery', 'Fuel', 'Maintenance'];

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
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
    if (_descCtrl.text.trim().isEmpty || _amountCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Description and amount are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref.read(equipmentRepositoryProvider).addCost({
        'description': _descCtrl.text.trim(),
        'category': _category,
        'amount': _amountCtrl.text.trim(),
        'date': _date.toIso8601String(),
      });
      ref.invalidate(equipmentProvider);
      if (mounted) Navigator.pop(context);
    } on OfflineQueuedException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      setState(() => _error = data is Map<String, dynamic>
          ? data['error'] as String? ?? 'Could not save cost.'
          : 'Could not save cost.');
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add fuel / service cost',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Text(
                      '${_date.day}/${_date.month}/${_date.year}'),
                ),
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
                      : const Text('Save cost'),
                ),
              ),
            ],
          ),
        ),
      ),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load equipment',
                style: TextStyle(
                    color: FarmioColors.textPrimary,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: FarmioColors.textMuted)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
