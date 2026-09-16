import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/equipment.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'equipment_provider.dart';

class EquipmentFormScreen extends ConsumerStatefulWidget {
  final EquipmentModel? existing;
  const EquipmentFormScreen({super.key, this.existing});

  @override
  ConsumerState<EquipmentFormScreen> createState() => _EquipmentFormScreenState();
}

class _EquipmentFormScreenState extends ConsumerState<EquipmentFormScreen> {
  late final _nameCtrl = TextEditingController(text: widget.existing?.name);
  late final _costCtrl = TextEditingController(
      text: widget.existing?.acquisitionCost?.toString());
  late final _notesCtrl = TextEditingController(text: widget.existing?.notes);
  late String _category = widget.existing?.category ?? 'tractor';
  late String _status = widget.existing?.status ?? 'active';
  DateTime? _acquisitionDate;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _acquisitionDate = widget.existing?.acquisitionDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _costCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _acquisitionDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _acquisitionDate = picked);
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

    final data = {
      'name': _nameCtrl.text.trim(),
      'category': _category,
      'status': _status,
      'acquisitionDate': _acquisitionDate?.toIso8601String(),
      'acquisitionCost': _costCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
    };

    try {
      final existing = widget.existing;
      if (existing != null) {
        await ref.read(equipmentRepositoryProvider).updateEquipment(existing.id, data);
      } else {
        await ref.read(equipmentRepositoryProvider).addEquipment(data);
      }
      ref.invalidate(equipmentProvider);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = 'Could not save equipment: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit equipment' : 'Add equipment',
            style: const TextStyle(fontWeight: FontWeight.w800)),
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
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: kEquipmentCategories
                        .map((c) => DropdownMenuItem(
                            value: c, child: Text(equipmentCategoryLabel(c))))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v ?? _category),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: kEquipmentStatuses
                        .map((s) => DropdownMenuItem(
                            value: s, child: Text(equipmentStatusLabel(s))))
                        .toList(),
                    onChanged: (v) => setState(() => _status = v ?? _status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration:
                          const InputDecoration(labelText: 'Acquired on (optional)'),
                      child: Text(_acquisitionDate != null
                          ? '${_acquisitionDate!.day}/${_acquisitionDate!.month}/${_acquisitionDate!.year}'
                          : 'Not set'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _costCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Cost (optional)'),
                  ),
                ),
              ],
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
                    : Text(_isEditing ? 'Save changes' : 'Save equipment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
