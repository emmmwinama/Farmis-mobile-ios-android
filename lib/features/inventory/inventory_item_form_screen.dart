import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'inventory_provider.dart';

class InventoryItemFormScreen extends ConsumerStatefulWidget {
  const InventoryItemFormScreen({super.key});

  @override
  ConsumerState<InventoryItemFormScreen> createState() =>
      _InventoryItemFormScreenState();
}

class _InventoryItemFormScreenState
    extends ConsumerState<InventoryItemFormScreen> {
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: 'kg');
  final _quantityCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _unitCtrl.dispose();
    _quantityCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _categoryCtrl.text.trim().isEmpty ||
        _quantityCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Name, category and quantity are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref.read(inventoryRepositoryProvider).createItem({
        'name': _nameCtrl.text.trim(),
        'category': _categoryCtrl.text.trim(),
        'unit': _unitCtrl.text.trim().isEmpty ? 'kg' : _unitCtrl.text.trim(),
        'quantity': num.tryParse(_quantityCtrl.text.trim()) ?? 0,
        'acquisitionUnitCost': _costCtrl.text.trim().isEmpty
            ? null
            : num.tryParse(_costCtrl.text.trim()),
      });
      ref.invalidate(inventoryItemsProvider);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = 'Could not save item: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Add stock',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
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
              controller: _costCtrl,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Cost per unit (optional)'),
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
                    : const Text('Save item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
