import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // User card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: FarmioColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: FarmioColors.primary,
                  child: Text(
                    (auth?.user.name ?? 'F')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white, fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth?.user.name ?? 'Farmer',
                        style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800,
                          color: FarmioColors.textPrimary,
                        ),
                      ),
                      Text(
                        auth?.user.email ?? '',
                        style: const TextStyle(
                          fontSize: 13, color: FarmioColors.textMuted,
                        ),
                      ),
                      if (auth?.subscription != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: FarmioColors.primary.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${auth!.subscription!.tierName} · '
                            '${auth.subscription!.status}',
                            style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: FarmioColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Farm card
          if (auth?.farm != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: FarmioColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Farm',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: FarmioColors.textMuted,
                      )),
                  const SizedBox(height: 6),
                  Text(auth!.farm!.name,
                      style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: FarmioColors.textPrimary,
                      )),
                  Text(auth.farm!.location,
                      style: const TextStyle(
                        fontSize: 13, color: FarmioColors.textMuted,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          _ProfileAction(
            icon: Icons.apps_outlined,
            title: 'Farmis functions',
            subtitle: 'See mobile coverage for every web dashboard module',
            onTap: () => context.push('/functions'),
          ),
          const SizedBox(height: 12),
          _ProfileAction(
            icon: Icons.file_present_outlined,
            title: 'Record packs',
            subtitle: 'Prepare loan, buyer, audit and insurance evidence',
            onTap: () => context.push('/records'),
          ),
          const SizedBox(height: 12),
          _ProfileAction(
            icon: Icons.people_alt_outlined,
            title: 'Employees',
            subtitle: 'Manage payroll capacity and team evidence',
            onTap: () => context.push('/employees'),
          ),
          const SizedBox(height: 12),
          _ProfileAction(
            icon: Icons.fact_check_outlined,
            title: 'Seasonal templates',
            subtitle: 'Plan crop activities using Farmio web workflows',
            onTap: () => context.push('/templates'),
          ),
          const SizedBox(height: 12),
          _ProfileAction(
            icon: Icons.workspace_premium,
            title: 'Subscription plans',
            subtitle: 'Compare public FarmIS plan limits and features',
            onTap: () => context.push('/subscriptions'),
          ),
          const SizedBox(height: 16),

          // Sign out
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              icon:  const Icon(Icons.logout),
              label: const Text('Sign out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FarmioColors.danger,
              ),
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FarmioColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: FarmioColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: FarmioColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: FarmioColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: FarmioColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: FarmioColors.textMuted),
          ],
        ),
      ),
    );
  }
}
