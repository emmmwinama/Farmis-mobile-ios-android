import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../core/auth/account_provider.dart';
import '../../core/db/database_provider.dart';
import '../../core/migration/export_service.dart';
import '../../core/migration/import_service.dart';
import '../../core/theme/app_theme.dart';

/// "Account & Sync" card on the Profile screen — the only place the optional
/// email/password account surfaces. Signed out, it's just a CTA; signed in,
/// it shows the plan and (for paid tiers) push/pull actions against the
/// `/api/mobile/backup` endpoint.
class AccountSyncSection extends ConsumerStatefulWidget {
  const AccountSyncSection({super.key});

  @override
  ConsumerState<AccountSyncSection> createState() => _AccountSyncSectionState();
}

class _AccountSyncSectionState extends ConsumerState<AccountSyncSection> {
  bool _busy = false;

  Future<void> _backup() async {
    setState(() => _busy = true);
    try {
      final json = await ExportService(ref.read(databaseProvider)).exportToJson();
      final counts = await ref.read(accountRepositoryProvider).backup(json);
      final total = counts.values.fold(0, (s, c) => s + c);
      _toast('Backed up $total record${total == 1 ? '' : 's'} to the cloud.');
    } catch (e) {
      _toast(apiErrorMessage(e, fallback: 'Could not back up your data.'), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore from cloud?'),
        content: const Text(
          "This pulls your last cloud backup into this device's local data. "
          "Existing local records are kept — nothing is deleted.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      final json = await ref.read(accountRepositoryProvider).restore();
      final summary = await ImportService(ref.read(databaseProvider)).importFromJson(json);
      _toast(summary.total == 0
          ? 'No cloud backup found yet — back up first from another device.'
          : 'Restored ${summary.total} record${summary.total == 1 ? '' : 's'} from the cloud.');
    } catch (e) {
      _toast(apiErrorMessage(e, fallback: 'Could not restore from the cloud.'), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    await ref.read(accountProvider.notifier).logout();
  }

  void _toast(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? FarmioColors.danger : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: state.isLoggedIn ? _signedIn(context, state) : _signedOut(context),
    );
  }

  Widget _signedOut(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.cloud_outlined, color: FarmioColors.primary),
            const SizedBox(width: 10),
            Text('Account & Sync',
                style: TextStyle(fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to back up your farm data to the cloud and restore it if you switch devices.',
          style: TextStyle(fontSize: 12.5, color: context.colors.textMuted),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 46,
          child: OutlinedButton(
            onPressed: () => context.push('/login'),
            child: const Text('Sign in or create an account'),
          ),
        ),
      ],
    );
  }

  Widget _signedIn(BuildContext context, AccountState state) {
    final account = state.account!;
    final tierName = account.subscription?.tierName ?? 'Mobile Free';
    final isPaid = account.subscription?.isPaid ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                  Text(account.user.email,
                      style: TextStyle(fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isPaid ? FarmioColors.success : FarmioColors.textMuted).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(tierName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isPaid ? FarmioColors.success : context.colors.textMuted,
                        )),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Sign out',
              icon: const Icon(Icons.logout),
              onPressed: _busy ? null : _signOut,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isPaid) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: const Text('Back up now'),
                  onPressed: _busy ? null : _backup,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cloud_download_outlined, size: 18),
                  label: const Text('Restore'),
                  onPressed: _busy ? null : _restore,
                ),
              ),
            ],
          ),
          if (_busy) ...[
            const SizedBox(height: 12),
            const Center(child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))),
          ],
        ] else ...[
          Text(
            'Upgrade to Monthly (\$5) or Lifetime (\$30) to unlock unlimited records and cloud backup.',
            style: TextStyle(fontSize: 12.5, color: context.colors.textMuted),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: () => _toast('Upgrades are coming soon.'),
              child: const Text('See upgrade options'),
            ),
          ),
        ],
      ],
    );
  }
}
