import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_config.dart';
import '../../core/auth/account_provider.dart';
import '../../core/theme/app_theme.dart';

/// In-app checkout needs a mobile PayPal endpoint and a way to read the
/// farm's live subscription status, neither of which exist on the backend
/// yet (see docs/MOBILE-API.md in Ulimi-app) — this points to the web
/// dashboard's billing page instead of presenting a checkout flow that
/// can't actually charge anything or confirm the result.
class UpgradeScreen extends ConsumerWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final signedIn = ref.watch(accountProvider).isLoggedIn;
    final host = Uri.parse(apiBaseUrl).host;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('Upgrade', style: TextStyle(fontWeight: FontWeight.w800))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              signedIn ? Icons.workspace_premium_outlined : Icons.lock_outline,
              size: 40,
              color: signedIn ? FarmioColors.purple : colors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              signedIn ? 'Manage your plan on the web' : 'Sign in first',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: colors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              signedIn
                  ? 'Upgrades and billing are handled from your farm\'s dashboard at $host — changes there apply here automatically.'
                  : 'Sign in to see your plan and upgrade options.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.textMuted, height: 1.4),
            ),
            if (!signedIn) ...[
              const SizedBox(height: 20),
              SizedBox(
                height: 46,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/login'),
                  child: const Text('Sign in'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
