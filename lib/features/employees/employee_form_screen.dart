import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/employee.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'employees_provider.dart';
import '../../core/theme/app_spacing.dart';

class EmployeeFormScreen extends ConsumerStatefulWidget {
  final EmployeeModel? existing;
  const EmployeeFormScreen({super.key, this.existing});

  @override
  ConsumerState<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  late final _nameCtrl = TextEditingController(text: widget.existing?.name);
  late final _roleCtrl = TextEditingController(text: widget.existing?.role);
  late final _payRateCtrl = TextEditingController(text: widget.existing?.payRate.toString());
  late final _phoneCtrl = TextEditingController(text: widget.existing?.phone);
  late String _payRateUnit = widget.existing?.payRateUnit ?? 'day';
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.existing != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _payRateCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _roleCtrl.text.trim().isEmpty ||
        _payRateCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Name, role and pay rate are required.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final data = {
      'name': _nameCtrl.text.trim(),
      'role': _roleCtrl.text.trim(),
      'payRate': _payRateCtrl.text.trim(),
      'payRateUnit': _payRateUnit,
      'phone': _phoneCtrl.text.trim(),
    };

    try {
      final existing = widget.existing;
      if (existing != null) {
        await ref.read(employeesRepositoryProvider).updateEmployee(existing.id, data);
      } else {
        await ref.read(employeesRepositoryProvider).createEmployee(data);
      }
      ref.invalidate(employeesProvider);
      if (mounted) context.pop();
    } catch (_) {
      setState(() => _error = 'Could not save worker. Check your connection.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit employee' : 'Add employee',
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _roleCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _payRateCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Pay rate'),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    initialValue: _payRateUnit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: const [
                      DropdownMenuItem(value: 'day', child: Text('day')),
                      DropdownMenuItem(value: 'hour', child: Text('hour')),
                      DropdownMenuItem(value: 'bag', child: Text('bag')),
                      DropdownMenuItem(value: 'month', child: Text('month')),
                    ],
                    onChanged: (value) =>
                        setState(() => _payRateUnit = value ?? 'day'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone optional'),
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
                    : Text(_isEditing ? 'Save changes' : 'Save employee'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
