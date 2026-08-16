import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/employee.dart';
import '../../shared/utils/formatters.dart';
import 'employees_provider.dart';

class EmployeesScreen extends ConsumerWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employees = ref.watch(employeesProvider);

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Employees',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(employeesProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEmployeeForm(context, ref),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add worker'),
      ),
      body: employees.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(employeesProvider),
        ),
        data: (data) {
          if (data.isEmpty) {
            return const _EmptyState();
          }

          final active = data.where((e) => e.isActive).length;
          final monthlyPayroll = data.fold<double>(
            0,
            (sum, e) => sum + _monthlyEstimate(e),
          );
          final roleCounts = <String, int>{};
          for (final employee in data) {
            roleCounts[employee.role] = (roleCounts[employee.role] ?? 0) + 1;
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(employeesProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
              children: [
                _SummaryCard(
                  total: data.length,
                  active: active,
                  monthlyPayroll: monthlyPayroll,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: roleCounts.entries
                      .map((e) => _RoleBadge(role: e.key, count: e.value))
                      .toList(),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Team capacity',
                  style: TextStyle(
                    color: FarmioColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                ...data.map(_EmployeeCard.new),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showEmployeeForm(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EmployeeForm(ref: ref),
    );
  }
}

class _EmployeeForm extends StatefulWidget {
  final WidgetRef ref;
  const _EmployeeForm({required this.ref});

  @override
  State<_EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<_EmployeeForm> {
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
      await widget.ref.read(employeesRepositoryProvider).createEmployee({
        'name': _nameCtrl.text.trim(),
        'role': _roleCtrl.text.trim(),
        'payRate': _payRateCtrl.text.trim(),
        'payRateUnit': _payRateUnit,
        'phone': _phoneCtrl.text.trim(),
      });
      widget.ref.invalidate(employeesProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() => _error = 'Could not add worker. Check your connection.');
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add employee',
                style: TextStyle(
                  color: FarmioColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
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
                      value: _payRateUnit,
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
                Text(_error!,
                    style: const TextStyle(color: FarmioColors.danger)),
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
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int total;
  final int active;
  final double monthlyPayroll;

  const _SummaryCard({
    required this.total,
    required this.active,
    required this.monthlyPayroll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FarmioColors.slate800,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(child: _SummaryItem(label: 'Active', value: '$active/$total')),
          Expanded(
            child: _SummaryItem(
              label: 'Est. monthly',
              value: Fmt.mwk(monthlyPayroll),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            )),
      ],
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;

  const _EmployeeCard(this.employee);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FarmioColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: employee.isActive
                ? FarmioColors.infoBg
                : FarmioColors.slate100,
            child: Text(
              employee.name.isEmpty ? '?' : employee.name[0].toUpperCase(),
              style: const TextStyle(
                color: FarmioColors.info,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.name,
                    style: const TextStyle(
                      color: FarmioColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    )),
                const SizedBox(height: 2),
                Text(employee.role,
                    style: const TextStyle(color: FarmioColors.textMuted)),
                const SizedBox(height: 6),
                Text(
                  '${Fmt.mwk(employee.payRate)} / ${employee.payRateUnit}',
                  style: const TextStyle(
                    color: FarmioColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (!employee.isActive)
            const _StatusPill(label: 'Inactive', color: FarmioColors.slate500),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  final int count;

  const _RoleBadge({required this.role, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: FarmioColors.infoBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$role · $count',
        style: const TextStyle(
          color: FarmioColors.info,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          )),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'No employees yet. Add workers to build payroll and loan-readiness evidence.',
          textAlign: TextAlign.center,
          style: TextStyle(color: FarmioColors.textMuted),
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
            const Text('Could not load employees',
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

double _monthlyEstimate(EmployeeModel employee) {
  switch (employee.payRateUnit) {
    case 'hour':
      return employee.payRate * 8 * 22;
    case 'day':
      return employee.payRate * 22;
    case 'bag':
      return employee.payRate * 40;
    case 'month':
      return employee.payRate;
    default:
      return employee.payRate;
  }
}
