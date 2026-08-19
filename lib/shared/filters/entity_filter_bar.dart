import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// One filterable dimension shown as a pill in an [EntityFilterBar] — e.g.
/// "Soil type", "Category", "Status". [options] should NOT include 'All';
/// it's prepended automatically.
class FilterDimension {
  final String label;
  final IconData icon;
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const FilterDimension({
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  bool get isActive => value != 'All';
}

/// A generic collapsible, chip-based filter bar for screens whose filter
/// dimensions don't fit [ReportRecordFilterBar]'s crop/season/field/archive
/// shape (Fields, Equipment, Inventory, Employees, Livestock, Documents,
/// Compliance, ...). Visually mirrors that widget's pattern.
class EntityFilterBar extends StatefulWidget {
  final List<FilterDimension> dimensions;
  final String title;

  const EntityFilterBar({
    super.key,
    required this.dimensions,
    this.title = 'Filters',
  });

  @override
  State<EntityFilterBar> createState() => _EntityFilterBarState();
}

class _EntityFilterBarState extends State<EntityFilterBar> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final active = widget.dimensions.where((d) => d.isActive).toList();
    final summary = active.isEmpty
        ? 'All ${widget.title.toLowerCase()}'
        : active.map((d) => d.value).join(' / ');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                const Icon(Icons.tune_rounded,
                    color: FarmioColors.primary, size: 19),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20, color: colors.textMuted),
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final dimension in widget.dimensions)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _DimensionMenu(dimension: dimension),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DimensionMenu extends StatelessWidget {
  final FilterDimension dimension;
  const _DimensionMenu({required this.dimension});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = ['All', ...dimension.options.where((o) => o != 'All')];

    return PopupMenuButton<String>(
      tooltip: dimension.label,
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: dimension.onSelected,
      itemBuilder: (context) => items
          .map((item) => PopupMenuItem<String>(
                value: item,
                child: Text(item,
                    style: TextStyle(color: colors.textPrimary)),
              ))
          .toList(),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: dimension.isActive
              ? FarmioColors.primaryBg
              : colors.background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: dimension.isActive ? FarmioColors.primary : colors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(dimension.icon, size: 17, color: FarmioColors.primary),
            const SizedBox(width: 7),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 118),
              child: Text(
                dimension.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}
