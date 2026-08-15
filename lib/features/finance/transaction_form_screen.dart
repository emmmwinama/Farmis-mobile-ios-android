import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/sync/offline_queued_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'finance_provider.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState
    extends ConsumerState<TransactionFormScreen> {
  final _descCtrl   = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _seasonCtrl = TextEditingController();

  String   _type     = 'Income';
  String   _category = 'Crop sales';
  DateTime _date     = DateTime.now();
  bool     _saving   = false;
  String?  _error;

  final _incomeCategories  = [
    'Crop sales', 'Livestock sales', 'Grant', 'Loan', 'Other income',
  ];
  final _expenseCategories = [
    'Inputs', 'Labour', 'Equipment', 'Transport',
    'Maintenance', 'Loan repayment', 'Other expense',
  ];

  List<String> get _categories =>
      _type == 'Income' ? _incomeCategories : _expenseCategories;

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
          .createTransaction({
        'type':        _type,
        'category':    _category,
        'amount':      _amountCtrl.text.trim(),
        'date':        _date.toIso8601String(),
        'description': _descCtrl.text.trim(),
        'season':      _seasonCtrl.text.trim().isEmpty
            ? null
            : _seasonCtrl.text.trim(),
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
    _seasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Add transaction',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Type toggle
            _label('Type *'),
            Row(children: [
              Expanded(
                child: _TypeButton(
                  label:      'Income',
                  selected:   _type == 'Income',
                  color:      const Color(0xFF16A34A),
                  onTap:      () => setState(() {
                    _type     = 'Income';
                    _category = _incomeCategories.first;
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TypeButton(
                  label:    'Expense',
                  selected: _type == 'Expense',
                  color:    FarmioColors.danger,
                  onTap:    () => setState(() {
                    _type     = 'Expense';
                    _category = _expenseCategories.first;
                  }),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // Category
            _label('Category *'),
            _dropdown(
              value:    _category,
              items:    _categories,
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),

            // Description
            _label('Description *'),
            _field(
              controller: _descCtrl,
              hint:       'e.g. Maize sale to ADMARC',
            ),
            const SizedBox(height: 16),

            // Amount
            _label('Amount (MWK) *'),
            _field(
              controller: _amountCtrl,
              hint:       '50000',
              inputType:  TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Season
            _label('Season (optional)'),
            _field(
              controller: _seasonCtrl,
              hint:       '2024/25',
            ),
            const SizedBox(height: 16),

            // Date
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
                    : const Text('Save transaction'),
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

  Widget _dropdown({
    required String         value,
    required List<String>   items,
    required void Function(String?) onChanged,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color:        FarmioColors.background,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: FarmioColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value:      value,
            isExpanded: true,
            items:      items
                .map((i) =>
                DropdownMenuItem(value: i, child: Text(i)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );
}

class _TypeButton extends StatelessWidget {
  final String   label;
  final bool     selected;
  final Color    color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha:0.1)
              : FarmioColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : FarmioColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:   14,
              fontWeight: FontWeight.w700,
              color:      selected ? color : FarmioColors.textMuted,
            )),
      ),
    );
  }
}
