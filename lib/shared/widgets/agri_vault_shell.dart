import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/sync/auto_sync_service.dart';
import '../../core/theme/app_theme.dart';
import 'app_brand_mark.dart';

class _ShellItem {
  final String label;
  final IconData icon;
  final String route;

  const _ShellItem(this.label, this.icon, this.route);
}

const _shellItems = [
  _ShellItem('Today', Icons.dashboard_outlined, '/dashboard'),
  _ShellItem('Capture', Icons.add_circle_outline, '/capture'),
  _ShellItem('Farm', Icons.map_outlined, '/farm'),
  _ShellItem('Money', Icons.account_balance_wallet_outlined, '/money'),
  _ShellItem('Reports', Icons.query_stats_outlined, '/reports'),
];

/// Every leaf route that belongs to each bottom-nav tab, keyed by tab index.
/// Tab 0 (Today) isn't listed — it's the fallback for anything unmatched,
/// which also covers `/profile`/`/import` (reached via the app bar profile
/// icon).
const _tabRouteGroups = <int, List<String>>{
  1: ['/capture'],
  2: [
    '/farm', '/fields', '/field-map', '/crops', '/activities',
    '/livestock', '/livestock-detail', '/equipment', '/employees',
  ],
  3: ['/money', '/finance', '/inventory', '/credit-score'],
  4: [
    '/reports', '/records', '/traceability', '/compliance',
    '/report-builder', '/weather', '/seasons', '/templates',
  ],
};

/// Pure route→tab resolution, extracted so it's unit-testable without
/// pumping a widget tree — replaces a brittle inline if/else chain.
int tabIndexForLocation(String location) {
  for (final entry in _tabRouteGroups.entries) {
    for (final route in entry.value) {
      if (location == route || location.startsWith('$route/')) return entry.key;
    }
  }
  return 0;
}

class AgriVaultShell extends ConsumerWidget {
  final Widget child;

  const AgriVaultShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Just being watched here starts the auto-sync watcher for the whole
    // logged-in session, regardless of which tab the user lands on first —
    // it stays alive afterward since this isn't an autoDispose provider.
    ref.watch(autoSyncProvider);

    final width = MediaQuery.of(context).size.width;
    final tablet = width >= 760;
    final index = tabIndexForLocation(GoRouterState.of(context).matchedLocation);

    if (tablet) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: (i) => context.go(_shellItems[i].route),
              minWidth: 78,
              backgroundColor: context.colors.surface,
              indicatorColor: FarmioColors.primaryBg,
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: BrandMark(size: 46, radius: 16),
              ),
              destinations: _shellItems
                  .map((item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon:
                            Icon(item.icon, color: FarmioColors.primary),
                        label: Text(item.label),
                      ))
                  .toList(),
            ),
            VerticalDivider(width: 1, color: context.colors.softBorder),
            Expanded(child: child),
          ],
        ),
      );
    }

    final bottomInset = MediaQuery.of(context).padding.bottom;
    const pillHeight = 64.0;
    const pillMargin = 12.0;
    final pillClearance = pillHeight + bottomInset + pillMargin;

    return Scaffold(
      backgroundColor: context.colors.background,
      // extendBody:true lets scrollable content flow behind the pill (it's
      // meant to show through — the pill blurs it), but a descendant
      // screen's own FloatingActionButton needs real clearance, not just a
      // visual allowance. Scaffold's FAB math (FabFloatOffsetY.getOffsetY in
      // the framework) computes its safe margin from
      // ScaffoldPrelayoutGeometry.minViewPadding, which traces back to
      // MediaQuery.viewPadding — NOT MediaQuery.padding, which is what
      // extendBody's own built-in mechanism (and an earlier, ultimately
      // wrong attempt at this fix) feeds. padding.bottom is a dead end here:
      // Scaffold's contentBottom calculation discards it in favor of
      // viewInsets.bottom (the keyboard) whenever resizeToAvoidBottomInset
      // is on, which it is by default — so overriding it, no matter the
      // value, never moves the FAB. viewPadding.bottom is the one MediaQuery
      // field that actually reaches the FAB's own safe-margin math.
      extendBody: true,
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          viewPadding: MediaQuery.of(context).viewPadding.copyWith(bottom: pillClearance),
        ),
        child: child,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + pillMargin),
        child: Container(
          height: pillHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: FarmioColors.slate900.withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(
                decoration: BoxDecoration(
                  color: FarmioColors.slate900.withValues(alpha: 0.52),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < _shellItems.length; i++)
                      _NavPill(
                        item: _shellItems[i],
                        selected: i == index,
                        onTap: () => context.go(_shellItems[i].route),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A bottom-nav tab that morphs between an icon-only puck (unselected) and a
/// filled icon+label capsule (selected) instead of a fixed-width slot with a
/// separate indicator — the active tab visibly grows to claim the space.
class _NavPill extends StatelessWidget {
  final _ShellItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavPill({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 12),
          decoration: BoxDecoration(
            color: selected ? FarmioColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? AppShadows.glow(FarmioColors.primary, alpha: 0.4, blur: 14, offset: const Offset(0, 4))
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 20, color: selected ? Colors.white : Colors.white60),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 7),
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    : const SizedBox(width: 0, height: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
