import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

/// One tab within a [SectionTabHost] — a label plus the already-embeddable
/// screen widget to show for it (pass `embedded: true` to that screen).
class SectionTabEntry {
  final String label;
  final Widget content;
  const SectionTabEntry({required this.label, required this.content});
}

/// Hosts several existing screens behind one app bar + a horizontally
/// scrollable pill-tab strip, so a bottom-nav tab (Farm, Money) lands
/// directly on real content instead of a card-menu screen. Each tab's
/// widget subtree is kept alive via [IndexedStack] so switching tabs
/// doesn't lose scroll position or in-flight state.
class SectionTabHost extends StatefulWidget {
  final String title;
  final List<SectionTabEntry> tabs;
  final int initialIndex;

  const SectionTabHost({
    super.key,
    required this.title,
    required this.tabs,
    this.initialIndex = 0,
  });

  @override
  State<SectionTabHost> createState() => _SectionTabHostState();
}

class _SectionTabHostState extends State<SectionTabHost> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _PillStrip(
            labels: widget.tabs.map((t) => t.label).toList(),
            selected: _index,
            onSelected: (i) => setState(() => _index = i),
          ),
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: widget.tabs.map((t) => t.content).toList(),
      ),
    );
  }
}

class _PillStrip extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  const _PillStrip({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = i == selected;
          return InkWell(
            onTap: () => onSelected(i),
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? FarmioColors.primary : context.colors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected ? FarmioColors.primary : context.colors.border,
                ),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : context.colors.textSecond,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
