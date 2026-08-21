import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/limits/limits_gate.dart';
import '../../core/theme/app_theme.dart';
import '../../models/employee.dart';
import '../../shared/filters/entity_filter_bar.dart';
import '../../shared/utils/formatters.dart';
import 'employees_provider.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const EmployeesScreen({super.key, this.embedded = false});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  String _roleFilter = 'All';
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(employeesProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: widget.embedded
          ? null
          : AppBar(
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
        onPressed: () async {
          if (!await ensureCanAdd(context, ref, LimitResource.employees)) return;
          if (context.mounted) context.push('/employees/new');
        },
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
          final roles = roleCounts.keys.toList();

          final filtered = data.where((e) {
            if (_roleFilter != 'All' && e.role != _roleFilter) return false;
            if (_statusFilter == 'Active' && !e.isActive) return false;
            if (_statusFilter == 'Inactive' && e.isActive) return false;
            return true;
          }).toList();

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
                EntityFilterBar(
                  dimensions: [
                    FilterDimension(
                      label: 'Role',
                      icon: Icons.work_outline_rounded,
                      value: _roleFilter,
                      options: roles,
                      onSelected: (v) => setState(() => _roleFilter = v),
                    ),
                    FilterDimension(
                      label: 'Status',
                      icon: Icons.toggle_on_outlined,
                      value: _statusFilter,
                      options: const ['Active', 'Inactive'],
                      onSelected: (v) => setState(() => _statusFilter = v),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Team capacity',
                  style: TextStyle(
                    color: FarmioColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No employees match this filter',
                        style: TextStyle(color: FarmioColors.textMuted),
                      ),
                    ),
                  )
                else
                  ...filtered.map((e) => _EmployeeCard(
                        e,
                        onDelete: () => _confirmDelete(context, ref, e),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, EmployeeModel employee) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove worker'),
        content: Text('Remove "${employee.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove',
                style: TextStyle(color: FarmioColors.danger)),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ref.read(employeesRepositoryProvider).deleteEmployee(employee.id);
      ref.invalidate(employeesProvider);
    }
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
  final VoidCallback onDelete;

  const _EmployeeCard(this.employee, {required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
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
          if (!employee.isActive) ...[
            const _StatusPill(label: 'Inactive', color: FarmioColors.slate500),
            const SizedBox(width: 4),
          ],
          PopupMenuButton<String>(
            onSelected: (v) { if (v == 'delete') onDelete(); },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline, color: FarmioColors.danger, size: 18),
                  SizedBox(width: 8),
                  Text('Remove', style: TextStyle(color: FarmioColors.danger)),
                ]),
              ),
            ],
          ),
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
