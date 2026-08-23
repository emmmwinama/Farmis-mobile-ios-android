import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/auth/account_provider.dart';
import '../../core/theme/app_theme.dart';

/// Real checkout, reached from the Profile screen's "See upgrade options"
/// and from the free-tier limit sheet. PayPal opens in an external browser
/// (no in-app webview/deep-link wiring yet) — the plan only actually takes
/// effect once the backend's webhook confirms payment, so this screen can't
/// know the moment it happens; [_refresh] is the manual "check now" action.
class UpgradeScreen extends ConsumerStatefulWidget {
  const UpgradeScreen({super.key});

  @override
  ConsumerState<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends ConsumerState<UpgradeScreen> {
  String? _startingPlan; // "monthly" | "lifetime" while that button is busy
  bool _refreshing = false;
  bool _checkoutOpened = false;
  String? _error;

  Future<void> _startCheckout(String plan) async {
    setState(() {
      _startingPlan = plan;
      _error = null;
    });
    try {
      final approveUrl = await ref.read(accountRepositoryProvider).startCheckout(plan);
      final opened = await launchUrl(approveUrl, mode: LaunchMode.externalApplication);
      if (!opened) throw Exception('Could not open the browser');
      if (mounted) setState(() => _checkoutOpened = true);
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e, fallback: 'Could not start checkout. Please try again.'));
    } finally {
      if (mounted) setState(() => _startingPlan = null);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _refreshing = true;
      _error = null;
    });
    try {
      await ref.read(accountProvider.notifier).refresh();
      if (!mounted) return;
      final isPaid = ref.read(accountProvider).account?.subscription?.isPaid ?? false;
      if (isPaid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You're upgraded — thanks!")),
        );
        context.pop();
      } else {
        setState(() => _error = "Payment hasn't been confirmed yet. If you just paid, give it a moment and try again.");
      }
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e, fallback: 'Could not check your plan status.'));
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final account = ref.watch(accountProvider).account;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('Upgrade', style: TextStyle(fontWeight: FontWeight.w800))),
      body: account == null ? _signedOutBody(context) : _plansBody(context, account.subscription?.isPaid ?? false),
    );
  }

  Widget _signedOutBody(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 40, color: colors.textMuted),
          const SizedBox(height: 16),
          Text(
            'Sign in first',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: colors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Upgrading needs an AgriVault account so your plan follows you across devices.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: colors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/login'),
              child: const Text('Sign in or create an account'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _plansBody(BuildContext context, bool isPaid) {
    final colors = context.colors;

    if (isPaid) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium, size: 40, color: FarmioColors.purple),
            const SizedBox(height: 16),
            Text(
              "You're already upgraded",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: colors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlimited records and cloud backup are active on this account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Choose a plan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: colors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          'Both plans unlock unlimited fields, crops, activities, transactions and employees, plus cloud backup.',
          style: TextStyle(fontSize: 13, color: colors.textMuted, height: 1.4),
        ),
        const SizedBox(height: 20),
        _PlanTile(
          name: 'Monthly',
          price: '\$5',
          cadence: '/month',
          description: 'Cancel anytime.',
          highlight: false,
          busy: _startingPlan == 'monthly',
          onTap: () => _startCheckout('monthly'),
        ),
        const SizedBox(height: 12),
        _PlanTile(
          name: 'Lifetime',
          price: '\$30',
          cadence: 'once',
          description: 'One payment, no renewals, ever.',
          highlight: true,
          busy: _startingPlan == 'lifetime',
          onTap: () => _startCheckout('lifetime'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: FarmioColors.danger, fontSize: 12.5)),
        ],
        if (_checkoutOpened) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Opened in your browser',
                  style: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete the payment there, then come back here and tap below.',
                  style: TextStyle(fontSize: 12.5, color: colors.textMuted),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _refreshing ? null : _refresh,
                    child: _refreshing
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("I've paid — refresh my plan"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  final String name;
  final String price;
  final String cadence;
  final String description;
  final bool highlight;
  final bool busy;
  final VoidCallback onTap;

  const _PlanTile({
    required this.name,
    required this.price,
    required this.cadence,
    required this.description,
    required this.highlight,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: highlight ? FarmioColors.purple.withValues(alpha: 0.08) : colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? FarmioColors.purple.withValues(alpha: 0.4) : colors.border,
          width: highlight ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(price, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: colors.textPrimary)),
                    const SizedBox(width: 4),
                    Text(cadence, style: TextStyle(fontSize: 12, color: colors.textMuted)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(name, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: colors.textMuted)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 12, color: colors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              style: highlight ? ElevatedButton.styleFrom(backgroundColor: FarmioColors.purple) : null,
              onPressed: busy ? null : onTap,
              child: busy
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(highlight ? 'Buy' : 'Subscribe'),
            ),
          ),
        ],
      ),
    );
  }
}
