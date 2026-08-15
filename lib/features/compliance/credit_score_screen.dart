import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/compliance.dart';
import '../../shared/utils/formatters.dart';
import 'compliance_provider.dart';

class CreditScoreScreen extends ConsumerWidget {
  const CreditScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credit = ref.watch(creditReadinessProvider);

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Credit readiness',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(creditReadinessProvider),
          ),
        ],
      ),
      body: credit.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(creditReadinessProvider),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(creditReadinessProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              _ScoreCard(data: data),
              const SizedBox(height: 16),
              const Text('Readiness checks',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: FarmioColors.textPrimary)),
              const SizedBox(height: 8),
              ...data.checks.map((item) => Container(
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
                          item.passed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: item.passed
                              ? FarmioColors.success
                              : FarmioColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(item.label,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              const Text('Summary',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: FarmioColors.textPrimary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: FarmioColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: FarmioColors.border),
                ),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 12,
                  children: [
                    _SummaryItem(label: 'Fields', value: '${data.summary.fields}'),
                    _SummaryItem(label: 'Crops', value: '${data.summary.crops}'),
                    _SummaryItem(
                        label: 'Transactions',
                        value: '${data.summary.transactionCount}'),
                    _SummaryItem(
                        label: 'Documents', value: '${data.summary.documents}'),
                    _SummaryItem(
                        label: 'Net', value: Fmt.mwk(data.summary.net)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final CreditReadinessData data;
  const _ScoreCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [FarmioColors.primaryDark, FarmioColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(data.grade,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${data.readinessScore.round()}% ready',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text(
                  'Based on fields, crops, transactions and documents on file.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
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
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: FarmioColors.textMuted)),
      ],
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
            const Text('Could not load credit readiness',
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
