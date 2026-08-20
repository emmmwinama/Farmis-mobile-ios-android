import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/limits/limits_gate.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/farmio_card.dart';
import '../../shared/widgets/glass_panel.dart';

class CaptureHubScreen extends ConsumerWidget {
  const CaptureHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _HubScaffold(
      title: 'Capture',
      subtitle: 'Log field activity, harvests and records from these forms.',
      children: [
        _ActionCard(
          icon: Icons.assignment_outlined,
          title: 'Log activity',
          body: 'Field work, labour, inputs and notes.',
          route: '/activities/new',
          color: FarmioColors.primary,
          limitResource: LimitResource.activities,
        ),
        _ActionCard(
          icon: Icons.agriculture_outlined,
          title: 'Record harvest',
          body: 'Log a harvest against any crop-field.',
          route: '/yields/new',
          color: FarmioColors.success,
        ),
        _ActionCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Add transaction',
          body: 'Income, expense and sales records.',
          route: '/finance/new-transaction',
          color: FarmioColors.info,
          limitResource: LimitResource.transactions,
        ),
        _ActionCard(
          icon: Icons.attach_file_outlined,
          title: 'Add evidence',
          body: 'Photos, receipts, contracts and certificates.',
          route: '/documents/new',
          color: FarmioColors.info,
        ),
        _ActionCard(
          icon: Icons.pets_outlined,
          title: 'Add animal',
          body: 'Register a new animal to the herd.',
          route: '/animals/new',
          color: FarmioColors.success,
        ),
        _ActionCard(
          icon: Icons.inventory_2_outlined,
          title: 'Inventory sale',
          body: 'Pick a stock item to sell from inventory.',
          route: '/inventory',
          color: FarmioColors.warning,
        ),
      ],
    );
  }
}

class _HubScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _HubScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final tablet = MediaQuery.of(context).size.width >= 760;
    final heroFill = HeroFill(
      context,
      colors: [
        FarmioColors.primaryDark.withValues(alpha: 0.94),
        FarmioColors.primary.withValues(alpha: 0.82),
        FarmioColors.cyan.withValues(alpha: 0.52),
      ],
      flat: FarmioColors.primaryDark,
    );

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: FrostedScaffoldBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 96),
          children: [
            GlassPanel(
              padding: const EdgeInsets.all(18),
              radius: 24,
              gradient: heroFill.gradient,
              color: heroFill.color,
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: tablet ? 3 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: tablet ? 1.45 : 0.96,
              children: children,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? route;
  final Color color;
  final bool locked;
  final LimitResource? limitResource;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.route,
    required this.color,
    this.limitResource,
  }) : locked = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FarmioCard(
      onTap: route == null
          ? null
          : () async {
              final resource = limitResource;
              if (resource != null && !await ensureCanAdd(context, ref, resource)) return;
              if (context.mounted) context.push(route!);
            },
      padding: const EdgeInsets.all(15),
      radius: 18,
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const Spacer(),
                  Icon(
                    locked ? Icons.lock_outline : Icons.chevron_right_rounded,
                    color: locked ? FarmioColors.textMuted : color,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: FarmioColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: Text(
                  body,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: FarmioColors.textMuted,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ),
              if (locked)
                const Text(
                  'Endpoint needed',
                  style: TextStyle(
                    color: FarmioColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
    );
  }
}
