import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/transaction.dart';
import '../../models/overhead.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_summary_bar.dart';
import 'finance_provider.dart';
import 'transaction_form_screen.dart';
import 'overhead_form_screen.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

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
    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Finance',
            style: TextStyle(fontWeight: FontWeight.w800)),
        bottom: TabBar(
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
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _TransactionsTab(),
          _OverheadTab(),
          _SummaryTab(),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabs,
        builder: (_, __) => FloatingActionButton(
          backgroundColor: FarmioColors.primary,
          onPressed: () async {
            if (_tabs.index == 0) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                    const TransactionFormScreen()),
              );
              ref.refresh(financeProvider);
            } else if (_tabs.index == 1) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                    const OverheadFormScreen()),
              );
              ref.refresh(overheadProvider);
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
  const _TransactionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);

    return finance.when(
      loading: () => const _Skeleton(),
      error:   (e, _) => _ErrorView(
        message: e.toString(),
        onRetry: () => ref.refresh(financeProvider),
      ),
      data: (data) {
        if (data.transactions.isEmpty) {
          return const _EmptyState(
              label: 'No transactions yet',
              hint:  'Tap + to record income or expenses');
        }

        return RefreshIndicator(
          color:     FarmioColors.primary,
          onRefresh: () async => ref.refresh(financeProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            children: [

              // Balance card
              _BalanceCard(summary: data.summary),
              const SizedBox(height: 20),

              // Transaction list
              ...data.transactions.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child:   _TransactionTile(
                  transaction: t,
                  onDelete: () async {
                    await ref
                        .read(financeRepositoryProvider)
                        .deleteTransaction(t.id);
                    ref.refresh(financeProvider);
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
  const _OverheadTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overhead = ref.watch(overheadProvider);

    return overhead.when(
      loading: () => const _Skeleton(),
      error:   (e, _) => _ErrorView(
        message: e.toString(),
        onRetry: () => ref.refresh(overheadProvider),
      ),
      data: (data) {
        if (data.expenses.isEmpty) {
          return const _EmptyState(
              label: 'No overhead expenses',
              hint:  'Tap + to add overhead costs');
        }

        return RefreshIndicator(
          color:     FarmioColors.primary,
          onRefresh: () async => ref.refresh(overheadProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            children: [

              // Overhead summary
              _OverheadSummaryCard(summary: data.summary),
              const SizedBox(height: 20),

              ...data.expenses.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child:   _OverheadTile(
                  expense: e,
                  onDelete: () async {
                    await ref
                        .read(financeRepositoryProvider)
                        .deleteOverhead(e.id);
                    ref.refresh(overheadProvider);
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
  const _SummaryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance  = ref.watch(financeProvider);
    final overhead = ref.watch(overheadProvider);

    return finance.when(
      loading: () => const _Skeleton(),
      error:   (e, _) => _ErrorView(
        message: e.toString(),
        onRetry: () => ref.refresh(financeProvider),
      ),
      data: (finData) => overhead.when(
        loading: () => const _Skeleton(),
        error:   (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.refresh(overheadProvider),
        ),
        data: (ohData) {
          final totalExpense =
              finData.summary.expense + ohData.summary.total;
          final net =
              finData.summary.income - totalExpense;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            children: [

              // Net P&L card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: net >= 0
                        ? [
                      const Color(0xFF1A3D1F),
                      const Color(0xFF2D6A35),
                    ]
                        : [
                      const Color(0xFF7F1D1D),
                      const Color(0xFFB91C1C),
                    ],
                    begin: Alignment.topLeft,
                    end:   Alignment.bottomRight,
                  ),
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

              // Income / Expense / Overhead row
              FarmioSummaryBar(stats: [
                FarmioSummaryStat(
                    label: 'Income',
                    value: Fmt.mwk(finData.summary.income),
                    color: Colors.greenAccent),
                FarmioSummaryStat(
                    label: 'Expenses',
                    value: Fmt.mwk(finData.summary.expense),
                    color: Colors.redAccent),
                FarmioSummaryStat(
                    label: 'Overhead',
                    value: Fmt.mwk(ohData.summary.total),
                    color: Colors.orangeAccent),
              ]),
              const SizedBox(height: 20),

              // Category breakdown
              const Text('By category',
                  style: TextStyle(
                    fontSize:   16,
                    fontWeight: FontWeight.w800,
                    color:      FarmioColors.textPrimary,
                  )),
              const SizedBox(height: 10),

              if (finData.summary.byCategory.isEmpty)
                const _EmptyState(
                    label: 'No data yet',
                    hint:  'Add transactions to see breakdown')
              else
                ...finData.summary.byCategory.map(
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
        ? const Color(0xFF16A34A)
        : FarmioColors.danger;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: FarmioColors.border),
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
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: FarmioColors.border),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color:        const Color(0xFFD97706).withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.receipt_outlined,
              color: Color(0xFFD97706), size: 20),
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
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: FarmioColors.border),
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
                    ? const Color(0xFF16A34A)
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
      itemBuilder: (_, __) => Container(
        height:     70,
        decoration: BoxDecoration(
          color:        const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(14),
        ),
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
