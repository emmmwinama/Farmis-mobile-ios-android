import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/equipment_item.dart';
import '../../models/overhead.dart';
import '../../shared/filters/entity_filter_bar.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import '../../shared/widgets/farmio_summary_bar.dart';
import 'equipment_detail_screen.dart';
import 'equipment_provider.dart';

class EquipmentScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const EquipmentScreen({super.key, this.embedded = false});

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

    final subTabs = TabBar(
      controller: _tabController,
      labelColor: FarmioColors.primary,
      unselectedLabelColor: FarmioColors.textMuted,
      indicatorColor: FarmioColors.primary,
      tabs: const [
        Tab(text: 'Equipment'),
        Tab(text: 'Fuel & service'),
      ],
    );

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: widget.embedded
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kTextTabBarHeight),
              child: Material(
                color: context.colors.background,
                child: subTabs,
              ),
            )
          : AppBar(
              title: const Text('Equipment',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              bottom: subTabs,
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
              ? context.push('/equipment/new')
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
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.colors.border),
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

class _CostsList extends StatefulWidget {
  final List<OverheadExpense> costs;
  const _CostsList({required this.costs});

  @override
  State<_CostsList> createState() => _CostsListState();
}

class _CostsListState extends State<_CostsList> {
  String _categoryFilter = 'All';

  @override
  Widget build(BuildContext context) {
    if (widget.costs.isEmpty) {
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

    final categories = {...widget.costs.map((c) => c.category)}.toList();
    final filtered = _categoryFilter == 'All'
        ? widget.costs
        : widget.costs.where((c) => c.category == _categoryFilter).toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      itemCount: filtered.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return EntityFilterBar(
            dimensions: [
              FilterDimension(
                label: 'Category',
                icon: Icons.category_outlined,
                value: _categoryFilter,
                options: categories,
                onSelected: (v) => setState(() => _categoryFilter = v),
              ),
            ],
          );
        }
        if (filtered.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No costs match this filter',
                style: TextStyle(color: FarmioColors.textMuted),
              ),
            ),
          );
        }
        final cost = filtered[index - 1];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
    } catch (e) {
      setState(() => _error = 'Could not save cost: $e');
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
