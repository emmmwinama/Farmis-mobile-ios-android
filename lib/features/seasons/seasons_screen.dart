import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/season.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_summary_bar.dart';
import 'seasons_provider.dart';

class SeasonsScreen extends ConsumerStatefulWidget {
  const SeasonsScreen({super.key});

  @override
  ConsumerState<SeasonsScreen> createState() => _SeasonsScreenState();
}

class _SeasonsScreenState extends ConsumerState<SeasonsScreen> {
  final Set<String> _selected = {};

  void _toggle(String season) {
    setState(() {
      if (_selected.contains(season)) {
        _selected.remove(season);
      } else {
        if (_selected.length >= 2) _selected.remove(_selected.first);
        _selected.add(season);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final seasons = ref.watch(seasonsProvider);
    final canCompare = _selected.length == 2;

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Seasons',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(seasonsProvider),
          ),
        ],
      ),
      floatingActionButton: canCompare
          ? FloatingActionButton.extended(
              onPressed: () {
                final list = _selected.toList();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SeasonCompareScreen(
                      pair: SeasonComparePair(list[0], list[1]),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.compare_arrows_outlined),
              label: const Text('Compare'),
            )
          : null,
      body: seasons.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(seasonsProvider),
        ),
        data: (data) {
          if (data.seasons.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No seasons found yet. Seasons are derived from crop records.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: FarmioColors.textMuted),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(seasonsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              itemCount: data.seasons.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SeasonsSummary(seasons: data.seasons),
                  );
                }
                final season = data.seasons[index - 1];
                return _SeasonCard(
                  season: season,
                  selected: _selected.contains(season.season),
                  onTap: () => _toggle(season.season),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SeasonsSummary extends StatelessWidget {
  final List<SeasonSummary> seasons;
  const _SeasonsSummary({required this.seasons});

  @override
  Widget build(BuildContext context) {
    final revenue = seasons.fold(0.0, (s, x) => s + x.revenue);
    final net = seasons.fold(0.0, (s, x) => s + x.netProfit);
    final area = seasons.fold(0.0, (s, x) => s + x.totalArea);

    return FarmioSummaryBar(
      stats: [
        FarmioSummaryStat(label: 'Seasons', value: '${seasons.length}'),
        FarmioSummaryStat(label: 'Revenue', value: Fmt.mwk(revenue)),
        FarmioSummaryStat(
          label: 'Net profit',
          value: Fmt.mwk(net),
          color: net >= 0 ? Colors.greenAccent : Colors.redAccent,
        ),
        FarmioSummaryStat(
            label: 'Area', value: '${area.toStringAsFixed(1)} ha'),
      ],
    );
  }
}

class _SeasonCard extends StatelessWidget {
  final SeasonSummary season;
  final bool selected;
  final VoidCallback onTap;

  const _SeasonCard({
    required this.season,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FarmioColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? FarmioColors.primary : FarmioColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(season.season,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: FarmioColors.textPrimary,
                      )),
                ),
                if (selected)
                  const Icon(Icons.check_circle,
                      color: FarmioColors.primary, size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${season.cropCount} crops · ${season.totalArea.toStringAsFixed(2)} ha · ${season.fields.length} fields',
              style: const TextStyle(
                  fontSize: 12, color: FarmioColors.textMuted),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Metric(label: 'Revenue', value: Fmt.mwk(season.revenue)),
                _Metric(
                  label: 'Net',
                  value: Fmt.mwk(season.netProfit),
                  color: season.netProfit >= 0
                      ? FarmioColors.success
                      : FarmioColors.danger,
                ),
                _Metric(
                  label: 'Yield/ha',
                  value: '${season.yieldPerHa.toStringAsFixed(0)} kg',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _Metric({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: color ?? FarmioColors.textPrimary,
              )),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: FarmioColors.textMuted)),
        ],
      ),
    );
  }
}

class SeasonCompareScreen extends ConsumerWidget {
  final SeasonComparePair pair;
  const SeasonCompareScreen({super.key, required this.pair});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compare = ref.watch(seasonCompareProvider(pair));

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Season comparison',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: compare.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(seasonCompareProvider(pair)),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(data.seasonA.season,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
                const Icon(Icons.compare_arrows_outlined,
                    color: FarmioColors.textMuted),
                Expanded(
                  child: Text(data.seasonB.season,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _OverallVerdict(data: data),
            const SizedBox(height: 16),
            _DeltaRow(
                label: 'Revenue',
                a: Fmt.mwk(data.seasonA.revenue),
                b: Fmt.mwk(data.seasonB.revenue),
                delta: data.comparison.revenue),
            _DeltaRow(
                label: 'Net profit',
                a: Fmt.mwk(data.seasonA.netProfit),
                b: Fmt.mwk(data.seasonB.netProfit),
                delta: data.comparison.netProfit),
            _DeltaRow(
                label: 'Total cost',
                a: Fmt.mwk(data.seasonA.totalCost),
                b: Fmt.mwk(data.seasonB.totalCost),
                delta: data.comparison.totalCost),
            _DeltaRow(
                label: 'Area',
                a: '${data.seasonA.totalArea.toStringAsFixed(2)} ha',
                b: '${data.seasonB.totalArea.toStringAsFixed(2)} ha',
                delta: data.comparison.area),
            _DeltaRow(
                label: 'Yield/ha',
                a: '${data.seasonA.yieldPerHa.toStringAsFixed(0)} kg',
                b: '${data.seasonB.yieldPerHa.toStringAsFixed(0)} kg',
                delta: data.comparison.yieldPerHa),
            _DeltaRow(
                label: 'Cost/ha',
                a: Fmt.mwk(data.seasonA.costPerHa),
                b: Fmt.mwk(data.seasonB.costPerHa),
                delta: data.comparison.costPerHa),
          ],
        ),
      ),
    );
  }
}

class _OverallVerdict extends StatelessWidget {
  final SeasonCompareData data;
  const _OverallVerdict({required this.data});

  @override
  Widget build(BuildContext context) {
    final verdict = _verdict(data);

    if (verdict == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FarmioColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: FarmioColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.balance_outlined,
                color: FarmioColors.textMuted, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Both seasons performed about the same overall.',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: FarmioColors.textMuted)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FarmioColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FarmioColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_outlined,
              color: FarmioColors.success, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${verdict.season} performed better overall',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: FarmioColors.success)),
                const SizedBox(height: 2),
                Text(verdict.reason,
                    style: const TextStyle(
                        fontSize: 12, color: FarmioColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Net profit is the deciding factor whenever it isn't tied — it's the
  /// single number that best answers "which season was more worthwhile".
  /// If net profit is tied (or missing), fall back to whichever season led
  /// on more of the other metrics.
  _SeasonVerdict? _verdict(SeasonCompareData data) {
    final netProfit = data.comparison.netProfit.improved;
    if (netProfit != null) {
      return _SeasonVerdict(
        season: netProfit ? data.seasonA.season : data.seasonB.season,
        reason: 'Higher net profit',
      );
    }

    final others = [
      data.comparison.revenue.improved,
      data.comparison.totalCost.improved,
      data.comparison.yieldPerHa.improved,
      data.comparison.costPerHa.improved,
      if (data.comparison.costPerKg != null)
        data.comparison.costPerKg!.improved,
    ];
    final aWins = others.where((improved) => improved == true).length;
    final bWins = others.where((improved) => improved == false).length;
    if (aWins == bWins) return null;

    return _SeasonVerdict(
      season: aWins > bWins ? data.seasonA.season : data.seasonB.season,
      reason: aWins > bWins
          ? 'Ahead on $aWins of ${others.length} other metrics'
          : 'Ahead on $bWins of ${others.length} other metrics',
    );
  }
}

class _SeasonVerdict {
  final String season;
  final String reason;
  const _SeasonVerdict({required this.season, required this.reason});
}

class _DeltaRow extends StatelessWidget {
  final String label;
  final String a;
  final String b;
  final SeasonMetricDelta delta;

  const _DeltaRow({
    required this.label,
    required this.a,
    required this.b,
    required this.delta,
  });

  @override
  Widget build(BuildContext context) {
    final improved = delta.improved;
    final color = improved == null
        ? FarmioColors.textMuted
        : improved
            ? FarmioColors.success
            : FarmioColors.danger;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FarmioColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FarmioColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: FarmioColors.textMuted)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                  child: Text(a,
                      style: const TextStyle(fontWeight: FontWeight.w800))),
              if (delta.pct != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${improved == true ? '+' : ''}${delta.pct!.toStringAsFixed(1)}%',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: color),
                  ),
                ),
              Expanded(
                  child: Text(b,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w800))),
            ],
          ),
        ],
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
            const Text('Could not load seasons',
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
