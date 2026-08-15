import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/compliance.dart';
import '../../shared/widgets/farmio_summary_bar.dart';
import '../crops/crop_detail_screen.dart';
import 'compliance_provider.dart';

class ComplianceScreen extends ConsumerWidget {
  const ComplianceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compliance = ref.watch(complianceProvider);

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Compliance',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(complianceProvider),
          ),
        ],
      ),
      body: compliance.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(complianceProvider),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(complianceProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              _ReadinessGauge(pct: data.readinessPct),
              const SizedBox(height: 12),
              _ComplianceSummaryRow(data: data),
              const SizedBox(height: 16),
              const Text('Farm checklist',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: FarmioColors.textPrimary)),
              const SizedBox(height: 8),
              ...data.checklist.map((item) => _ChecklistTile(item: item)),
              const SizedBox(height: 16),
              const Text('Crop lots',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: FarmioColors.textPrimary)),
              const SizedBox(height: 8),
              if (data.lots.isEmpty)
                const Text('No crop lots to review yet.',
                    style: TextStyle(color: FarmioColors.textMuted))
              else
                ...data.lots.map((lot) => _LotTile(
                      lot: lot,
                      onReview: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CropDetailScreen(cropId: lot.id),
                          ),
                        );
                        ref.invalidate(complianceProvider);
                      },
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComplianceSummaryRow extends StatelessWidget {
  final ComplianceData data;
  const _ComplianceSummaryRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final passed = data.checklist.where((c) => c.passed).length;
    final readyLots = data.lots.where((l) => l.allDone).length;

    return FarmioSummaryBar(
      stats: [
        FarmioSummaryStat(
          label: 'Checklist',
          value: '$passed/${data.checklist.length}',
          color: Colors.greenAccent,
        ),
        FarmioSummaryStat(
          label: 'Crop lots ready',
          value: '$readyLots/${data.lots.length}',
          color: readyLots == data.lots.length && data.lots.isNotEmpty
              ? Colors.greenAccent
              : Colors.orangeAccent,
        ),
      ],
    );
  }
}

class _ReadinessGauge extends StatelessWidget {
  final double pct;
  const _ReadinessGauge({required this.pct});

  @override
  Widget build(BuildContext context) {
    final color = pct >= 80
        ? FarmioColors.success
        : pct >= 50
            ? FarmioColors.warning
            : FarmioColors.danger;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FarmioColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FarmioColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: pct / 100,
                  strokeWidth: 6,
                  color: color,
                  backgroundColor: FarmioColors.slate100,
                ),
                Text('${pct.round()}%',
                    style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Audit, buyer and insurance readiness across your farm records.',
              style: TextStyle(fontSize: 13, color: FarmioColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  final ChecklistItem item;
  const _ChecklistTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FarmioColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FarmioColors.border),
      ),
      child: Row(
        children: [
          Icon(
            item.passed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: item.passed ? FarmioColors.success : FarmioColors.textMuted,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(item.label,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Text('${item.value}',
              style: const TextStyle(
                  fontSize: 12, color: FarmioColors.textMuted)),
        ],
      ),
    );
  }
}

class _LotTile extends StatelessWidget {
  final ComplianceLot lot;
  final VoidCallback onReview;
  const _LotTile({required this.lot, required this.onReview});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: FarmioColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: lot.allDone ? FarmioColors.success : FarmioColors.border,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onReview,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${lot.cropName} · ${lot.fieldName}',
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(lot.season,
                        style: const TextStyle(
                            fontSize: 12, color: FarmioColors.textMuted)),
                  ],
                ),
              ),
              Text(lot.allDone ? 'Ready' : 'Review',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: lot.allDone
                        ? FarmioColors.success
                        : FarmioColors.warning,
                  )),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  size: 18,
                  color: lot.allDone
                      ? FarmioColors.success
                      : FarmioColors.warning),
            ],
          ),
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
            const Text('Could not load compliance',
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
