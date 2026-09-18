import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/field.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'fields_provider.dart';
import '../../core/theme/app_spacing.dart';

class FieldFormScreen extends ConsumerStatefulWidget {
  final FieldModel? existing;
  const FieldFormScreen({super.key, this.existing});

  @override
  ConsumerState<FieldFormScreen> createState() => _FieldFormScreenState();
}

class _FieldFormScreenState extends ConsumerState<FieldFormScreen> {
  late final _nameCtrl      = TextEditingController(text: widget.existing?.name);
  late final _totalCtrl     = TextEditingController(text: widget.existing?.totalArea.toString());
  late final _cultivCtrl    = TextEditingController(text: widget.existing?.cultivatableArea.toString());
  late final _notesCtrl     = TextEditingController(text: widget.existing?.notes);

  late String _soilType = widget.existing?.soilType ?? 'Loam';
  bool    _saving   = false;
  String? _error;

  bool get _isEditing => widget.existing != null;

  final _soilTypes = [
    'Loam', 'Sandy loam', 'Clay loam', 'Clay',
    'Sandy', 'Silt loam', 'Silty clay', 'Other',
  ];

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _totalCtrl.text.trim().isEmpty ||
        _cultivCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please fill in all required fields.');
      return;
    }

    setState(() { _saving = true; _error = null; });

    final data = {
      'name':             _nameCtrl.text.trim(),
      'totalArea':        _totalCtrl.text.trim(),
      'cultivatableArea': _cultivCtrl.text.trim(),
      'soilType':         _soilType,
      'notes':            _notesCtrl.text.trim(),
    };

    try {
      final existing = widget.existing;
      if (existing != null) {
        await ref.read(fieldsRepositoryProvider).updateField(existing.id, data);
        ref.invalidate(fieldDetailProvider(existing.id));
      } else {
        await ref.read(fieldsRepositoryProvider).createField(data);
      }
      ref.invalidate(fieldsProvider);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = 'Failed to save field: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _totalCtrl.dispose();
    _cultivCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit field' : 'Add field',
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _label('Field name *'),
            _field(controller: _nameCtrl, hint: 'e.g. Kalekeni Block A'),
            const SizedBox(height: 16),

            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Total area (ha) *'),
                  _field(
                    controller:  _totalCtrl,
                    hint:        '2.5',
                    inputType:   TextInputType.number,
                  ),
                ],
              )),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Cultivatable (ha) *'),
                  _field(
                    controller: _cultivCtrl,
                    hint:       '2.0',
                    inputType:  TextInputType.number,
                  ),
                ],
              )),
            ]),
            const SizedBox(height: 16),

            _label('Soil type *'),
            DropdownButtonFormField<String>(
              initialValue: _soilType,
              isExpanded: true,
              items:      _soilTypes
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged:  (v) => setState(() => _soilType = v!),
            ),
            const SizedBox(height: 16),

            _label('Notes (optional)'),
            TextField(
              controller: _notesCtrl,
              maxLines:   3,
              decoration: const InputDecoration(
                hintText: 'Any notes about this field...',
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              FarmioErrorBanner(message: _error!),
            ],

            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : Text(_isEditing ? 'Save changes' : 'Save field'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
    child: Text(text,
        style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700,
          color: context.colors.textMuted,
        )),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType inputType = TextInputType.text,
  }) =>
      TextField(
        controller:   controller,
        keyboardType: inputType,
        decoration:   InputDecoration(hintText: hint),
      );
}
