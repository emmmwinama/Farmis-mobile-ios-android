import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'employees_provider.dart';

class EmployeeFormScreen extends ConsumerStatefulWidget {
  const EmployeeFormScreen({super.key});

  @override
  ConsumerState<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final _nameCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _payRateCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _payRateUnit = 'day';
  bool _saving = false;
  String? _error;

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

    try {
      await ref.read(employeesRepositoryProvider).createEmployee({
        'name': _nameCtrl.text.trim(),
        'role': _roleCtrl.text.trim(),
        'payRate': _payRateCtrl.text.trim(),
        'payRateUnit': _payRateUnit,
        'phone': _phoneCtrl.text.trim(),
      });
      ref.invalidate(employeesProvider);
      if (mounted) context.pop();
    } catch (_) {
      setState(() => _error = 'Could not add worker. Check your connection.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Add employee',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
                    : const Text('Save employee'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
