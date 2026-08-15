import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/sync/offline_queued_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'finance_provider.dart';

class OverheadFormScreen extends ConsumerStatefulWidget {
  const OverheadFormScreen({super.key});

  @override
  ConsumerState<OverheadFormScreen> createState() =>
      _OverheadFormScreenState();
}

class _OverheadFormScreenState
    extends ConsumerState<OverheadFormScreen> {
  final _descCtrl   = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl  = TextEditingController();

  String   _category  = 'Salary';
  DateTime _date       = DateTime.now();
  bool     _recurring  = false;
  bool     _saving     = false;
  String?  _error;

  final _categories = [
    'Salary', 'Rent', 'Utilities', 'Insurance',
    'Loan repayment', 'Maintenance', 'Other',
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context:     context,
      initialDate: _date,
      firstDate:   DateTime(2020),
      lastDate:    DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_descCtrl.text.trim().isEmpty ||
        _amountCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please fill in all required fields.');
      return;
    }

    setState(() { _saving = true; _error = null; });

    try {
      await ref
          .read(financeRepositoryProvider)
          .createOverhead({
        'description': _descCtrl.text.trim(),
        'category':    _category,
        'amount':      _amountCtrl.text.trim(),
        'date':        _date.toIso8601String(),
        'recurring':   _recurring,
        'notes':       _notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim(),
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
      setState(() => _error = msg ?? 'Failed to save.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Add overhead expense',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            _label('Description *'),
            _field(
              controller: _descCtrl,
              hint:       'e.g. Farm manager salary',
            ),
            const SizedBox(height: 16),

            _label('Category *'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color:        FarmioColors.background,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: FarmioColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value:      _category,
                  isExpanded: true,
                  items:      _categories
                      .map((c) => DropdownMenuItem(
                      value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _category = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _label('Amount (MWK) *'),
            _field(
              controller: _amountCtrl,
              hint:       '150000',
              inputType:  TextInputType.number,
            ),
            const SizedBox(height: 16),

            _label('Date *'),
            InkWell(
              onTap:        _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color:        FarmioColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border:       Border.all(color: FarmioColors.border),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: FarmioColors.textMuted),
                  const SizedBox(width: 10),
                  Text(
                    '${_date.day}/${_date.month}/${_date.year}',
                    style: const TextStyle(
                      fontSize: 14,
                      color:    FarmioColors.textPrimary,
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // Recurring toggle
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: FarmioColors.border),
              ),
              child: Row(children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recurring expense',
                          style: TextStyle(
                            fontSize:   14,
                            fontWeight: FontWeight.w700,
                            color:      FarmioColors.textPrimary,
                          )),
                      Text('This expense repeats monthly',
                          style: TextStyle(
                            fontSize: 12,
                            color:    FarmioColors.textMuted,
                          )),
                    ],
                  ),
                ),
                Switch(
                  value:           _recurring,
                  activeColor:     FarmioColors.primary,
                  onChanged: (v) =>
                      setState(() => _recurring = v),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            _label('Notes (optional)'),
            TextField(
              controller: _notesCtrl,
              maxLines:   3,
              decoration: InputDecoration(
                hintText: 'Any additional notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: FarmioColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: FarmioColors.border),
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
                  width:  20,
                  height: 20,
                  child:  CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : const Text('Save overhead'),
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
          fontSize:   12,
          fontWeight: FontWeight.w700,
          color:      FarmioColors.textMuted,
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
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: FarmioColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: FarmioColors.border),
          ),
          filled:    true,
          fillColor: FarmioColors.background,
        ),
      );
}
