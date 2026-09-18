import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/transaction.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'finance_provider.dart';
import '../../core/theme/app_spacing.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  final TransactionModel? existing;
  const TransactionFormScreen({super.key, this.existing});

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState
    extends ConsumerState<TransactionFormScreen> {
  late final _descCtrl   = TextEditingController(text: widget.existing?.description);
  late final _amountCtrl = TextEditingController(text: widget.existing?.amount.toString());
  late final _seasonCtrl = TextEditingController(text: widget.existing?.season);

  late String   _type     = widget.existing?.type ?? 'Income';
  late String   _category = widget.existing?.category ?? 'Crop sales';
  late DateTime _date     = widget.existing?.date ?? DateTime.now();
  bool     _saving   = false;
  String?  _error;

  bool get _isEditing => widget.existing != null;

  final _incomeCategories  = [
    'Crop sales', 'Livestock sales', 'Grant', 'Loan', 'Other income',
  ];
  final _expenseCategories = [
    'Inputs', 'Labour', 'Equipment', 'Transport',
    'Maintenance', 'Loan repayment', 'Other expense',
  ];

  List<String> get _categories => {
        ...(_type == 'Income' ? _incomeCategories : _expenseCategories),
        if (_isEditing && _type == widget.existing!.type) widget.existing!.category,
      }.toList();

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

    final data = {
      'type':        _type,
      'category':    _category,
      'amount':      _amountCtrl.text.trim(),
      'date':        _date.toIso8601String(),
      'description': _descCtrl.text.trim(),
      'season':      _seasonCtrl.text.trim().isEmpty
          ? null
          : _seasonCtrl.text.trim(),
    };

    try {
      final existing = widget.existing;
      if (existing != null) {
        await ref.read(financeRepositoryProvider).updateTransaction(existing.id, data);
      } else {
        await ref.read(financeRepositoryProvider).createTransaction(data);
      }
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = 'Failed to save: $e');
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
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit transaction' : 'Add transaction',
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
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
                  color:      FarmioColors.success,
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
                    horizontal: AppSpacing.md, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color:        context.colors.background,
                  borderRadius: BorderRadius.circular(12),
                  border:       Border.all(color: context.colors.border),
                ),
                child: Row(children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 16, color: context.colors.textMuted),
                  const SizedBox(width: 10),
                  Text(
                    '${_date.day}/${_date.month}/${_date.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color:    context.colors.textPrimary,
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
                    : Text(_isEditing ? 'Save changes' : 'Save transaction'),
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
          fontSize:   12,
          fontWeight: FontWeight.w700,
          color:      context.colors.textMuted,
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
            borderSide: BorderSide(color: context.colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.border),
          ),
          filled:    true,
          fillColor: context.colors.background,
        ),
      );

  Widget _dropdown({
    required String         value,
    required List<String>   items,
    required void Function(String?) onChanged,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color:        context.colors.background,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: context.colors.border),
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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha:0.1)
              : context.colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : context.colors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:   14,
              fontWeight: FontWeight.w700,
              color:      selected ? color : context.colors.textMuted,
            )),
      ),
    );
  }
}
