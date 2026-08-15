import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import 'sync_status_indicator.dart';

class AgriVaultShell extends StatefulWidget {
  final Widget child;

  const AgriVaultShell({super.key, required this.child});

  @override
  State<AgriVaultShell> createState() => _AgriVaultShellState();
}

class _AgriVaultShellState extends State<AgriVaultShell> {
  static const _items = [
    _ShellItem('Home', Icons.dashboard_outlined, '/dashboard'),
    _ShellItem('Farm', Icons.map_outlined, '/farm'),
    _ShellItem('Business', Icons.account_balance_wallet_outlined, '/business'),
    _ShellItem('Insights', Icons.query_stats_outlined, '/insights'),
    _ShellItem('More', Icons.apps_outlined, '/more'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final tablet = width >= 760;
    final index = _selectedIndex(GoRouterState.of(context).matchedLocation);

    if (tablet) {
      return Scaffold(
        backgroundColor: FarmioColors.background,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: (i) => context.go(_items[i].route),
              minWidth: 78,
              backgroundColor: Colors.white,
              indicatorColor: FarmioColors.primaryBg,
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: _BrandMark(),
              ),
              trailing: const Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: SyncStatusIndicator(compact: true),
                  ),
                ),
              ),
              destinations: _items
                  .map((item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon:
                            Icon(item.icon, color: FarmioColors.primary),
                        label: Text(item.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1, color: FarmioColors.softBorder),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: FarmioColors.background,
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_items[i].route),
        backgroundColor: FarmioColors.slate800,
        indicatorColor: Colors.white.withValues(alpha: 0.14),
        shadowColor: Colors.transparent,
        destinations: _items
            .map((item) => NavigationDestination(
                  icon: Icon(item.icon, color: Colors.white70),
                  selectedIcon:
                      Icon(item.icon, color: FarmioColors.primary),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }

  int _selectedIndex(String location) {
    for (var i = 0; i < _items.length; i++) {
      if (location == _items[i].route ||
          location.startsWith('${_items[i].route}/')) {
        return i;
      }
    }
    if (location == '/capture' ||
        location == '/livestock' ||
        location == '/fields' ||
        location == '/field-map' ||
        location == '/crops' ||
        location == '/activities' ||
        location == '/templates' ||
        location == '/seasons') {
      return 1;
    }
    if (location == '/finance' ||
        location == '/employees' ||
        location == '/team' ||
        location == '/inventory' ||
        location == '/equipment') {
      return 2;
    }
    if (location == '/reports' ||
        location == '/records' ||
        location == '/traceability' ||
        location == '/compliance' ||
        location == '/notifications' ||
        location == '/credit-score' ||
        location == '/report-builder' ||
        location == '/graph-catalog' ||
        location == '/weather') {
      return 3;
    }
    return 0;
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [FarmioColors.primaryDark, FarmioColors.primary],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: const Icon(Icons.shield_outlined, color: Colors.white),
    );
  }
}

class _ShellItem {
  final String label;
  final IconData icon;
  final String route;

  const _ShellItem(this.label, this.icon, this.route);
}
