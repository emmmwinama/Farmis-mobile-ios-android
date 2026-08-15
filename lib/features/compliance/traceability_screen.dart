import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/compliance.dart';
import '../../shared/utils/formatters.dart';
import 'compliance_provider.dart';

class TraceabilityScreen extends ConsumerWidget {
  const TraceabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lots = ref.watch(traceabilityProvider);

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Traceability',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(traceabilityProvider),
          ),
        ],
      ),
      body: lots.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(traceabilityProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No crop lots found yet.',
                    style: TextStyle(color: FarmioColors.textMuted)),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(traceabilityProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              itemCount: list.length,
              itemBuilder: (context, index) => _LotCard(lot: list[index]),
            ),
          );
        },
      ),
    );
  }
}

class _LotCard extends StatelessWidget {
  final TraceabilityLot lot;
  const _LotCard({required this.lot});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FarmioColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              lot.buyerReady ? FarmioColors.success : FarmioColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(lot.lotId,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 13)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (lot.buyerReady
                          ? FarmioColors.success
                          : FarmioColors.warning)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  lot.buyerReady ? 'Buyer-ready' : 'Needs evidence',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: lot.buyerReady
                        ? FarmioColors.success
                        : FarmioColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${lot.cropName} · ${lot.variety} · ${lot.fieldName} · ${lot.season}',
              style: const TextStyle(
                  fontSize: 12, color: FarmioColors.textMuted)),
          const SizedBox(height: 10),
          Row(
            children: [
              _Stat(label: 'Activities', value: '${lot.activityCount}'),
              _Stat(label: 'Sprays', value: '${lot.sprayRecordCount}'),
              _Stat(label: 'Harvests', value: '${lot.harvestCount}'),
              _Stat(label: 'Revenue', value: Fmt.mwk(lot.revenue)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 12)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: FarmioColors.textMuted)),
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
            const Text('Could not load traceability',
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
