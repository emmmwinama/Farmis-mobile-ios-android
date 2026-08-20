import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shown whenever a free-tier action is blocked by [FreeTierLimits] — a
/// deliberately polished paywall moment rather than a plain snackbar, since
/// this is the app's main upsell surface. Matches the sheet chrome already
/// used elsewhere (grab handle, rounded top, `context.colors.surface`) —
/// see e.g. crop_detail_screen.dart's record sheets.
///
/// Returns true if the user tapped "See upgrade options" — navigation is
/// left to the caller (using its own, longer-lived context) rather than done
/// from inside the sheet, since go_router's `context.pop()`/`push()` from a
/// bottom-sheet builder context is unreliable about which Navigator it acts on.
Future<bool> showUpgradePromptSheet(
  BuildContext context, {
  required String resourceLabel,
  required int limit,
}) async {
  final upgrade = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _UpgradePromptSheet(
      resourceLabel: resourceLabel,
      limit: limit,
      onUpgrade: () => Navigator.of(sheetContext).pop(true),
      onDismiss: () => Navigator.of(sheetContext).pop(false),
    ),
  );
  return upgrade ?? false;
}

class _UpgradePromptSheet extends StatelessWidget {
  final String resourceLabel;
  final int limit;
  final VoidCallback onUpgrade;
  final VoidCallback onDismiss;

  const _UpgradePromptSheet({
    required this.resourceLabel,
    required this.limit,
    required this.onUpgrade,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: FarmioColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: FarmioColors.purple.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.workspace_premium_outlined, color: FarmioColors.purple, size: 28),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "You've reached your Free plan limit",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: colors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                'The Free plan includes up to $limit $resourceLabel. Upgrade to add more and unlock cloud backup.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: colors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _PlanCard(
                    name: 'Monthly',
                    price: '\$5',
                    cadence: '/month',
                    highlight: false,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _PlanCard(
                    name: 'Lifetime',
                    price: '\$30',
                    cadence: 'once',
                    highlight: true,
                  )),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: FarmioColors.purple),
                  onPressed: onUpgrade,
                  child: const Text('See upgrade options'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: TextButton(
                  onPressed: onDismiss,
                  child: Text('Maybe later', style: TextStyle(color: colors.textMuted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String cadence;
  final bool highlight;

  const _PlanCard({
    required this.name,
    required this.price,
    required this.cadence,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: highlight ? FarmioColors.purple.withValues(alpha: 0.08) : colors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight ? FarmioColors.purple.withValues(alpha: 0.4) : colors.border,
          width: highlight ? 1.4 : 1,
        ),
      ),
      child: Column(
        children: [
          if (highlight)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: FarmioColors.purple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('BEST VALUE',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors.textMuted)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: colors.textPrimary)),
              const SizedBox(width: 3),
              Text(cadence, style: TextStyle(fontSize: 11, color: colors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
