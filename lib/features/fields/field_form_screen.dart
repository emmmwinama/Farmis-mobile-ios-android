import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/sync/offline_queued_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'fields_provider.dart';

class FieldFormScreen extends ConsumerStatefulWidget {
  const FieldFormScreen({super.key});

  @override
  ConsumerState<FieldFormScreen> createState() => _FieldFormScreenState();
}

class _FieldFormScreenState extends ConsumerState<FieldFormScreen> {
  final _nameCtrl      = TextEditingController();
  final _totalCtrl     = TextEditingController();
  final _cultivCtrl    = TextEditingController();
  final _notesCtrl     = TextEditingController();

  String  _soilType = 'Loam';
  bool    _saving   = false;
  String? _error;

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

    try {
      await ref.read(fieldsRepositoryProvider).createField({
        'name':             _nameCtrl.text.trim(),
        'totalArea':        _totalCtrl.text.trim(),
        'cultivatableArea': _cultivCtrl.text.trim(),
        'soilType':         _soilType,
        'notes':            _notesCtrl.text.trim(),
      });
      if (mounted) Navigator.pop(context);
    } on OfflineQueuedException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String?;
      setState(() => _error = msg ?? 'Failed to save field.');
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
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Add field',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color:        FarmioColors.background,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: FarmioColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value:       _soilType,
                  isExpanded:  true,
                  items:       _soilTypes
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged:   (v) => setState(() => _soilType = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _label('Notes (optional)'),
            TextField(
              controller:   _notesCtrl,
              maxLines:     3,
              decoration:   InputDecoration(
                hintText: 'Any notes about this field...',
                border:   OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:   const BorderSide(color: FarmioColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:   const BorderSide(color: FarmioColors.border),
                ),
                filled:    true,
                fillColor: FarmioColors.background,
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
                    : const Text('Save field'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700,
          color: FarmioColors.textMuted,
        )),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType inputType = TextInputType.text,
  }) =>
      TextField(
        controller:  controller,
        keyboardType: inputType,
        decoration:  InputDecoration(
          hintText:  hint,
          border:    OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   const BorderSide(color: FarmioColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   const BorderSide(color: FarmioColors.border),
          ),
          filled:    true,
          fillColor: FarmioColors.background,
        ),
      );
}