import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/limits/limits_gate.dart';
import '../../core/theme/app_theme.dart';
import '../../models/transaction.dart';
import '../../models/overhead.dart';
import '../../shared/filters/report_record_filters.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_shimmer.dart';
import '../../shared/widgets/farmio_summary_bar.dart';
import 'finance_provider.dart';

bool _inRange(DateTime date, DateTimeRange range) =>
    !date.isBefore(range.start) && !date.isAfter(range.end);

/// Whether [t] matches the shared crop/season/field/period filters plus the
/// Finance-specific transaction type/category filters.
bool _matchesTransaction(
  TransactionModel t,
  ReportRecordFilters filters,
  String typeFilter,
  String categoryFilter,
) {
  if (!_inRange(t.date, filters.resolveRange())) return false;
  if (filters.season != 'All' && t.season != filters.season) return false;
  if (filters.crop != 'All' && t.cropName != filters.crop) return false;
  if (filters.field != 'All' && t.fieldName != filters.field) return false;
  if (typeFilter != 'All' && t.type != typeFilter) return false;
  if (categoryFilter != 'All' && t.category != categoryFilter) return false;
  return true;
}

FinanceSummary _summarize(List<TransactionModel> transactions) {
  double income = 0, expense = 0;
  final incomeByCategory = <String, double>{};
  final expenseByCategory = <String, double>{};

  for (final t in transactions) {
    if (t.isIncome) {
      income += t.amount;
      incomeByCategory.update(t.category, (v) => v + t.amount,
          ifAbsent: () => t.amount);
    } else {
      expense += t.amount;
      expenseByCategory.update(t.category, (v) => v + t.amount,
          ifAbsent: () => t.amount);
    }
  }

  final categories = {...incomeByCategory.keys, ...expenseByCategory.keys};
  return FinanceSummary(
    income: income,
    expense: expense,
    net: income - expense,
    byCategory: categories
        .map((c) => CategoryBreakdown(
              category: c,
              income: incomeByCategory[c] ?? 0,
              expense: expenseByCategory[c] ?? 0,
              net: (incomeByCategory[c] ?? 0) - (expenseByCategory[c] ?? 0),
            ))
        .toList(),
  );
}

class FinanceScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const FinanceScreen({super.key, this.embedded = false});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  ReportRecordFilters _filters = const ReportRecordFilters();
  String _typeFilter = 'All';
  String _categoryFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subTabs = TabBar(
      controller:          _tabs,
      labelColor:          FarmioColors.primary,
      unselectedLabelColor: FarmioColors.textMuted,
      indicatorColor:      FarmioColors.primary,
      labelStyle: const TextStyle(
          fontWeight: FontWeight.w700, fontSize: 13),
      tabs: const [
        Tab(text: 'Transactions'),
        Tab(text: 'Overhead'),
        Tab(text: 'Summary'),
      ],
    );

    final finance = ref.watch(financeProvider);
    final allTransactions = finance.valueOrNull?.transactions ?? const [];
    final crops = {
      ...allTransactions.map((t) => t.cropName).whereType<String>(),
    }.toList();
    final seasons = {
      ...allTransactions.map((t) => t.season).whereType<String>(),
    }.toList();
    final fields = {
      ...allTransactions.map((t) => t.fieldName).whereType<String>(),
    }.toList();
    final categories = {...allTransactions.map((t) => t.category)}.toList();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: widget.embedded
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kTextTabBarHeight),
              child: Material(
                color: context.colors.background,
                child: subTabs,
              ),
            )
          : AppBar(
              title: const Text('Finance',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              bottom: subTabs,
            ),
      body: Column(
        children: [
          ReportRecordFilterBar(
            value: _filters,
            crops: crops,
            seasons: seasons,
            fields: fields,
            onChanged: (filters) => setState(() => _filters = filters),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                _SimpleFilterChip(
                  icon: Icons.swap_vert_rounded,
                  label: _typeFilter,
                  items: const ['All', 'Income', 'Expense'],
                  onSelected: (v) => setState(() => _typeFilter = v),
                ),
                const SizedBox(width: 8),
                _SimpleFilterChip(
                  icon: Icons.sell_outlined,
                  label: _categoryFilter,
                  items: ['All', ...categories],
                  onSelected: (v) => setState(() => _categoryFilter = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _TransactionsTab(
                  filters: _filters,
                  typeFilter: _typeFilter,
                  categoryFilter: _categoryFilter,
                ),
                _OverheadTab(filters: _filters),
                _SummaryTab(
                  filters: _filters,
                  typeFilter: _typeFilter,
                  categoryFilter: _categoryFilter,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabs,
        builder: (_, __) => FloatingActionButton(
          backgroundColor: FarmioColors.primary,
          onPressed: () async {
            if (_tabs.index == 0) {
              if (!await ensureCanAdd(context, ref, LimitResource.transactions)) return;
              if (!context.mounted) return;
              await context.push('/finance/new-transaction');
              ref.invalidate(financeProvider);
            } else if (_tabs.index == 1) {
              await context.push('/finance/new-overhead');
              ref.invalidate(overheadProvider);
            }
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

// ── Transactions tab ──────────────────────────────────────────────────────────
class _TransactionsTab extends ConsumerWidget {
  final ReportRecordFilters filters;
  final String typeFilter;
  final String categoryFilter;

  const _TransactionsTab({
    required this.filters,
    required this.typeFilter,
    required this.categoryFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);

    return finance.when(
      loading: () => const _Skeleton(),
      error:   (e, _) => _ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(financeProvider),
      ),
      data: (data) {
        final transactions = data.transactions
            .where((t) =>
                _matchesTransaction(t, filters, typeFilter, categoryFilter))
            .toList();

        if (transactions.isEmpty) {
          return data.transactions.isEmpty
              ? const _EmptyState(
                  label: 'No transactions yet',
                  hint:  'Tap + to record income or expenses')
              : const _EmptyState(
                  label: 'No transactions match these filters',
                  hint:  'Try widening the filters above');
        }

        return RefreshIndicator(
          color:     FarmioColors.primary,
          onRefresh: () async => ref.invalidate(financeProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            children: [

              // Balance card
              _BalanceCard(summary: _summarize(transactions)),
              const SizedBox(height: 20),

              // Transaction list
              ...transactions.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child:   _TransactionTile(
                  transaction: t,
                  onDelete: () async {
                    await ref
                        .read(financeRepositoryProvider)
                        .deleteTransaction(t.id);
                    ref.invalidate(financeProvider);
                  },
                ),
              )),
            ],
          ),
        );
      },
    );
  }
}

// ── Overhead tab ──────────────────────────────────────────────────────────────
class _OverheadTab extends ConsumerWidget {
  final ReportRecordFilters filters;
  const _OverheadTab({required this.filters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overhead = ref.watch(overheadProvider);

    return overhead.when(
      loading: () => const _Skeleton(),
      error:   (e, _) => _ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(overheadProvider),
      ),
      data: (data) {
        final range = filters.resolveRange();
        final expenses =
            data.expenses.where((e) => _inRange(e.date, range)).toList();

        if (expenses.isEmpty) {
          return data.expenses.isEmpty
              ? const _EmptyState(
                  label: 'No overhead expenses',
                  hint:  'Tap + to add overhead costs')
              : const _EmptyState(
                  label: 'No overhead expenses in this period',
                  hint:  'Try widening the filters above');
        }

        final total = expenses.fold<double>(0, (s, e) => s + e.amount);
        final recurring = expenses
            .where((e) => e.recurring)
            .fold<double>(0, (s, e) => s + e.amount);

        return RefreshIndicator(
          color:     FarmioColors.primary,
          onRefresh: () async => ref.invalidate(overheadProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            children: [

              // Overhead summary
              _OverheadSummaryCard(
                summary: OverheadSummary(total: total, recurring: recurring),
              ),
              const SizedBox(height: 20),

              ...expenses.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child:   _OverheadTile(
                  expense: e,
                  onDelete: () async {
                    await ref
                        .read(financeRepositoryProvider)
                        .deleteOverhead(e.id);
                    ref.invalidate(overheadProvider);
                  },
                ),
              )),
            ],
          ),
        );
      },
    );
  }
}

// ── Summary tab ───────────────────────────────────────────────────────────────
class _SummaryTab extends ConsumerWidget {
  final ReportRecordFilters filters;
  final String typeFilter;
  final String categoryFilter;

  const _SummaryTab({
    required this.filters,
    required this.typeFilter,
    required this.categoryFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance  = ref.watch(financeProvider);
    final overhead = ref.watch(overheadProvider);
    final activityCosts = ref.watch(activityCostProvider(filters));

    return finance.when(
      loading: () => const _Skeleton(),
      error:   (e, _) => _ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(financeProvider),
      ),
      data: (finData) => overhead.when(
        loading: () => const _Skeleton(),
        error:   (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(overheadProvider),
        ),
        data: (ohData) {
          final range = filters.resolveRange();
          final transactions = finData.transactions
              .where((t) =>
                  _matchesTransaction(t, filters, typeFilter, categoryFilter))
              .toList();
          final summary = _summarize(transactions);
          final overheadTotal = ohData.expenses
              .where((e) => _inRange(e.date, range))
              .fold<double>(0, (s, e) => s + e.amount);
          final activities = activityCosts.valueOrNull;
          final activityTotal = activities?.total ?? 0;

          final totalExpense =
              summary.expense + overheadTotal + activityTotal;
          final net = summary.income - totalExpense;
          final netFill = HeroFill(
            context,
            colors: net >= 0
                ? [FarmioColors.success.darken(0.5), FarmioColors.success.darken(0.15)]
                : [FarmioColors.danger.darken(0.5), FarmioColors.danger.darken(0.15)],
            flat: (net >= 0 ? FarmioColors.success : FarmioColors.danger).darken(0.3),
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            children: [

              // Net P&L card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: netFill.color,
                  gradient: netFill.gradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Net P&L',
                        style: TextStyle(
                          color:    Colors.white70,
                          fontSize: 13,
                        )),
                    const SizedBox(height: 6),
                    Text(Fmt.mwk(net),
                        style: const TextStyle(
                          color:      Colors.white,
                          fontSize:   28,
                          fontWeight: FontWeight.w800,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      net >= 0 ? 'Profitable' : 'Operating at a loss',
                      style: const TextStyle(
                        color:    Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Income / Expense / Activity costs / Overhead row
              FarmioSummaryBar(stats: [
                FarmioSummaryStat(
                    label: 'Income',
                    value: Fmt.mwk(summary.income),
                    color: Colors.greenAccent),
                FarmioSummaryStat(
                    label: 'Expenses',
                    value: Fmt.mwk(summary.expense),
                    color: Colors.redAccent),
                FarmioSummaryStat(
                    label: 'Activity costs',
                    value: Fmt.mwk(activityTotal),
                    color: Colors.orangeAccent),
                FarmioSummaryStat(
                    label: 'Overhead',
                    value: Fmt.mwk(overheadTotal),
                    color: Colors.orangeAccent),
              ]),
              const SizedBox(height: 20),

              // Activity cost breakdown
              const Text('Activity costs',
                  style: TextStyle(
                    fontSize:   16,
                    fontWeight: FontWeight.w800,
                    color:      FarmioColors.textPrimary,
                  )),
              const SizedBox(height: 4),
              const Text(
                'Labour, inputs and other costs logged against field '
                'activities — these never appear as transactions.',
                style: TextStyle(
                  fontSize: 12,
                  color:    FarmioColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              activityCosts.when(
                loading: () => const FarmioShimmerCard(height: 70),
                error: (e, _) => _EmptyState(
                    label: 'Could not load activity costs',
                    hint: e.toString()),
                data: (a) => a.total == 0
                    ? const _EmptyState(
                        label: 'No activity costs in this period',
                        hint: 'Log field activities to see them here')
                    : Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: Column(
                          children: [
                            _ActivityCostLine(
                                label: 'Labour', value: a.labourCost),
                            const SizedBox(height: 8),
                            _ActivityCostLine(
                                label: 'Inputs', value: a.inputCost),
                            const SizedBox(height: 8),
                            _ActivityCostLine(
                                label: 'Other', value: a.otherCost),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              // Category breakdown
              const Text('By category',
                  style: TextStyle(
                    fontSize:   16,
                    fontWeight: FontWeight.w800,
                    color:      FarmioColors.textPrimary,
                  )),
              const SizedBox(height: 10),

              if (summary.byCategory.isEmpty)
                const _EmptyState(
                    label: 'No data yet',
                    hint:  'Add transactions to see breakdown')
              else
                ...summary.byCategory.map(
                      (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child:   _CategoryRow(breakdown: c),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ActivityCostLine extends StatelessWidget {
  final String label;
  final double value;
  const _ActivityCostLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            )),
        Text(Fmt.mwk(value),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: FarmioColors.warning,
            )),
      ],
    );
  }
}

class _SimpleFilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> items;
  final ValueChanged<String> onSelected;

  const _SimpleFilterChip({
    required this.icon,
    required this.label,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: label,
      onSelected: onSelected,
      itemBuilder: (context) => items
          .map((item) => PopupMenuItem<String>(value: item, child: Text(item)))
          .toList(),
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: FarmioColors.primary),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: context.colors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ── Balance card ──────────────────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  final FinanceSummary summary;
  const _BalanceCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return FarmioSummaryBar(stats: [
      FarmioSummaryStat(
          label: 'Income',
          value: Fmt.mwk(summary.income),
          color: Colors.greenAccent),
      FarmioSummaryStat(
          label: 'Expenses',
          value: Fmt.mwk(summary.expense),
          color: Colors.redAccent),
      FarmioSummaryStat(
        label: 'Net',
        value: Fmt.mwk(summary.net),
        color: summary.net >= 0 ? Colors.greenAccent : Colors.redAccent,
      ),
    ]);
  }
}

// ── Transaction tile ──────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback     onDelete;

  const _TransactionTile({
    required this.transaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final color    = isIncome
        ? FarmioColors.success
        : FarmioColors.danger;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: context.colors.border),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color:        color.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isIncome
                ? Icons.arrow_downward
                : Icons.arrow_upward,
            color: color, size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(transaction.description,
                  style: const TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w700,
                    color:      FarmioColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _SmallBadge(label: transaction.category),
                  if (transaction.fieldName != null)
                    _SmallBadge(label: transaction.fieldName!),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 132),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${isIncome ? '+' : '-'} ${Fmt.mwk(transaction.amount)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w800,
                    color:      color,
                  ),
                ),
                Text(Fmt.dateShort(transaction.date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color:    FarmioColors.textMuted,
                    )),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 34,
          child: PopupMenuButton<String>(
            padding:    EdgeInsets.zero,
            icon: const Icon(Icons.more_vert, size: 22),
            onSelected: (v) { if (v == 'delete') onDelete(); },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline,
                      color: FarmioColors.danger, size: 18),
                  SizedBox(width: 8),
                  Text('Delete',
                      style: TextStyle(color: FarmioColors.danger)),
                ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Overhead tile ─────────────────────────────────────────────────────────────
class _OverheadTile extends StatelessWidget {
  final OverheadExpense expense;
  final VoidCallback    onDelete;

  const _OverheadTile({
    required this.expense,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: context.colors.border),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color:        FarmioColors.warning.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.receipt_outlined,
              color: FarmioColors.warning, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(expense.description,
                  style: const TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w700,
                    color:      FarmioColors.textPrimary,
                  )),
              const SizedBox(height: 3),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _SmallBadge(label: expense.category),
                  if (expense.recurring)
                    _SmallBadge(
                      label: 'Recurring',
                      color: FarmioColors.primary,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 118),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(Fmt.mwk(expense.amount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize:   13,
                      fontWeight: FontWeight.w800,
                      color:      FarmioColors.danger,
                    )),
                Text(Fmt.dateShort(expense.date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color:    FarmioColors.textMuted,
                    )),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 34,
          child: PopupMenuButton<String>(
            padding:    EdgeInsets.zero,
            icon: const Icon(Icons.more_vert, size: 22),
            onSelected: (v) { if (v == 'delete') onDelete(); },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline,
                      color: FarmioColors.danger, size: 18),
                  SizedBox(width: 8),
                  Text('Delete',
                      style: TextStyle(color: FarmioColors.danger)),
                ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Overhead summary card ─────────────────────────────────────────────────────
class _OverheadSummaryCard extends StatelessWidget {
  final OverheadSummary summary;
  const _OverheadSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return FarmioSummaryBar(stats: [
      FarmioSummaryStat(
          label: 'Total overhead',
          value: Fmt.mwk(summary.total),
          color: Colors.redAccent),
      FarmioSummaryStat(
          label: 'Recurring',
          value: Fmt.mwk(summary.recurring),
          color: Colors.orangeAccent),
    ]);
  }
}

// ── Category row ──────────────────────────────────────────────────────────────
class _CategoryRow extends StatelessWidget {
  final CategoryBreakdown breakdown;
  const _CategoryRow({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final isPositive = breakdown.net >= 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: context.colors.border),
      ),
      child: Row(children: [
        Expanded(
          child: Text(breakdown.category,
              style: const TextStyle(
                fontSize:   13,
                fontWeight: FontWeight.w700,
                color:      FarmioColors.textPrimary,
              )),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isPositive ? '+' : ''}${Fmt.mwk(breakdown.net)}',
              style: TextStyle(
                fontSize:   13,
                fontWeight: FontWeight.w800,
                color: isPositive
                    ? FarmioColors.success
                    : FarmioColors.danger,
              ),
            ),
            Text(
              'In: ${Fmt.mwk(breakdown.income)}  '
                  'Out: ${Fmt.mwk(breakdown.expense)}',
              style: const TextStyle(
                fontSize: 10,
                color:    FarmioColors.textMuted,
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────
class _SmallBadge extends StatelessWidget {
  final String label;
  final Color  color;

  const _SmallBadge({
    required this.label,
    this.color = FarmioColors.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize:   10,
            fontWeight: FontWeight.w600,
            color:      color,
          )),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding:          const EdgeInsets.all(20),
      itemCount:        5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const FarmioShimmer(
        width: double.infinity,
        height: 70,
        radius: 14,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label, hint;
  const _EmptyState({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet_outlined,
                size: 56, color: FarmioColors.primary),
            const SizedBox(height: 16),
            Text(label,
                style: const TextStyle(
                  fontSize:   18,
                  fontWeight: FontWeight.w800,
                  color:      FarmioColors.textPrimary,
                )),
            const SizedBox(height: 6),
            Text(hint,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: FarmioColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: FarmioColors.danger),
          const SizedBox(height: 12),
          const Text('Could not load data',
              style: TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.w700,
                color:      FarmioColors.textPrimary,
              )),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon:      const Icon(Icons.refresh),
            label:     const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
