import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/inventory_item.dart';
import '../../shared/filters/entity_filter_bar.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'inventory_provider.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const InventoryScreen({super.key, this.embedded = false});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _categoryFilter = 'All';
  bool _lowStockOnly = false;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(inventoryItemsProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: widget.embedded
          ? null
          : AppBar(
              title: const Text('Inventory',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.invalidate(inventoryItemsProvider),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/inventory/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add stock'),
      ),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(inventoryItemsProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No inventory items yet.',
                  style: TextStyle(color: FarmioColors.textMuted),
                ),
              ),
            );
          }

          final categories = {...list.map((i) => i.category)}.toList();
          final filtered = list.where((i) {
            if (_categoryFilter != 'All' && i.category != _categoryFilter) {
              return false;
            }
            if (_lowStockOnly && !i.lowStock) return false;
            return true;
          }).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(inventoryItemsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              itemCount: (filtered.isEmpty ? 1 : filtered.length) + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EntityFilterBar(
                        dimensions: [
                          FilterDimension(
                            label: 'Category',
                            icon: Icons.category_outlined,
                            value: _categoryFilter,
                            options: categories,
                            onSelected: (v) =>
                                setState(() => _categoryFilter = v),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FilterChip(
                          label: const Text('Low stock only'),
                          selected: _lowStockOnly,
                          avatar: Icon(
                            Icons.warning_amber_rounded,
                            size: 17,
                            color: _lowStockOnly
                                ? Colors.white
                                : FarmioColors.warning,
                          ),
                          onSelected: (v) =>
                              setState(() => _lowStockOnly = v),
                          selectedColor: FarmioColors.warning,
                          labelStyle: TextStyle(
                            color: _lowStockOnly
                                ? Colors.white
                                : context.colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  );
                }
                if (filtered.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No items match this filter',
                        style: TextStyle(color: FarmioColors.textMuted),
                      ),
                    ),
                  );
                }
                final item = filtered[index - 1];
                return _ItemCard(
                  item: item,
                  onDelete: () => _confirmDelete(context, ref, item),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, InventoryItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete item'),
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
    if (ok == true) {
      await ref.read(inventoryRepositoryProvider).deleteItem(item.id);
      ref.invalidate(inventoryItemsProvider);
    }
  }
}

class _ItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onDelete;
  const _ItemCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.lowStock ? FarmioColors.warning : context.colors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style:
                            const TextStyle(fontWeight: FontWeight.w900)),
                    Text(
                      '${item.quantity.toStringAsFixed(1)} ${item.unit} · ${item.category}',
                      style: const TextStyle(
                          fontSize: 12, color: FarmioColors.textMuted),
                    ),
                  ],
                ),
              ),
              if (item.lowStock) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: FarmioColors.warningBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Low stock',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: FarmioColors.warning)),
                ),
                const SizedBox(width: 4),
              ],
              PopupMenuButton<String>(
                onSelected: (v) { if (v == 'delete') onDelete(); },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline, color: FarmioColors.danger, size: 18),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: FarmioColors.danger)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Sold ${Fmt.mwk(item.totalRevenue)}',
                  style: const TextStyle(
                      fontSize: 12, color: FarmioColors.success)),
              const Spacer(),
              if (item.quantity > 0)
                TextButton.icon(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _SellForm(item: item),
                  ),
                  icon: const Icon(Icons.sell_outlined, size: 16),
                  label: const Text('Sell'),
                )
              else
                const Text('Out of stock',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: FarmioColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SellForm extends ConsumerStatefulWidget {
  final InventoryItem item;
  const _SellForm({required this.item});

  @override
  ConsumerState<_SellForm> createState() => _SellFormState();
}

class _SellFormState extends ConsumerState<_SellForm> {
  final _quantityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _buyerCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    _buyerCtrl.dispose();
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
    if (_quantityCtrl.text.trim().isEmpty ||
        _priceCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Quantity and price are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref.read(inventoryRepositoryProvider).createSale({
        'inventoryItemId': widget.item.id,
        'quantitySold': num.tryParse(_quantityCtrl.text.trim()) ?? 0,
        'unit': widget.item.unit,
        'pricePerUnit': num.tryParse(_priceCtrl.text.trim()) ?? 0,
        'buyerName':
            _buyerCtrl.text.trim().isEmpty ? null : _buyerCtrl.text.trim(),
        'saleDate': _date.toIso8601String(),
      });
      ref.invalidate(inventoryItemsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Could not save sale: $e');
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
              Text('Sell ${widget.item.name}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900)),
              Text('${widget.item.quantity.toStringAsFixed(1)} ${widget.item.unit} available',
                  style: const TextStyle(
                      fontSize: 12, color: FarmioColors.textMuted)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'Quantity (${widget.item.unit})'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Price per unit'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _buyerCtrl,
                decoration:
                    const InputDecoration(labelText: 'Buyer (optional)'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Sale date'),
                  child: Text('${_date.day}/${_date.month}/${_date.year}'),
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
                      : const Text('Record sale'),
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
            const Text('Could not load inventory',
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
