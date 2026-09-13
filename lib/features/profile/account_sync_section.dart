import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/account_provider.dart';
import '../../core/theme/app_theme.dart';

/// "Account" card on the Profile screen. Signing in is mandatory now (see
/// the router's redirect), so this is just an identity/sign-out card, not
/// an optional upsell — the per-farm subscription/plan details live on the
/// dashboard, not here.
class AccountSyncSection extends ConsumerWidget {
  const AccountSyncSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountProvider);
    final user = state.user;
    if (user == null) return const SizedBox.shrink();
    final farm = state.farmContext?.activeFarm;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: FarmioColors.primary.withValues(alpha: 0.12),
            child: Icon(Icons.person_outline, color: FarmioColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email,
                    style: TextStyle(fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
                if (farm != null) ...[
                  const SizedBox(height: 2),
                  Text('${farm.name} · ${farm.role}',
                      style: TextStyle(fontSize: 12.5, color: context.colors.textMuted)),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(accountProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}
