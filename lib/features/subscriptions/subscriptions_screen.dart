import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/subscription_tier.dart';
import 'subscriptions_provider.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiers = ref.watch(subscriptionTiersProvider);

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Plans',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: tiers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _PlansError(
          details: error.toString(),
          onRetry: () => ref.invalidate(subscriptionTiersProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('No public plans available',
                  style: TextStyle(color: FarmioColors.textMuted)),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(subscriptionTiersProvider),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Choose the plan that matches your farm operations.',
                  style: TextStyle(
                    color: FarmioColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ...items.map(_TierCard.new),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final SubscriptionTier tier;
  const _TierCard(this.tier);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: tier.isFeatured ? FarmioColors.primary : FarmioColors.border,
          width: tier.isFeatured ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tier.name,
                  style: const TextStyle(
                    color: FarmioColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (tier.isFeatured)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: FarmioColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Popular',
                    style: TextStyle(
                      color: FarmioColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          if (tier.description != null && tier.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(tier.description!,
                style: const TextStyle(color: FarmioColors.textMuted)),
          ],
          const SizedBox(height: 14),
          Text(
            'MWK ${_money(tier.priceMonthly)} / month',
            style: const TextStyle(
              color: FarmioColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'MWK ${_money(tier.priceAnnual)} billed annually',
            style: const TextStyle(color: FarmioColors.textMuted),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _LimitChip(label: '${tier.maxFields} fields'),
              _LimitChip(label: '${tier.maxCrops} crops'),
              _LimitChip(label: '${tier.maxActivities} activities'),
              _LimitChip(label: '${tier.maxEmployees} employees'),
            ],
          ),
          if (tier.features.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...tier.features.take(5).map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 16, color: FarmioColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(feature,
                              style: const TextStyle(
                                  color: FarmioColors.textPrimary)),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

final _moneyFormat = NumberFormat.decimalPattern('en_MW');

String _money(num value) => _moneyFormat.format(value);

class _LimitChip extends StatelessWidget {
  final String label;
  const _LimitChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: FarmioColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: FarmioColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: FarmioColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PlansError extends StatelessWidget {
  final String details;
  final VoidCallback onRetry;
  const _PlansError({required this.details, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load plans',
                style: TextStyle(
                    color: FarmioColors.textPrimary,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(details,
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
