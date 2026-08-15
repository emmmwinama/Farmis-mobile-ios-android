import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum ArchiveFilter { active, archived, all }

class ReportRecordFilters {
  final String period;
  final DateTimeRange? dateRange;
  final String crop;
  final String season;
  final String field;
  final ArchiveFilter archive;

  const ReportRecordFilters({
    this.period = 'This year',
    this.dateRange,
    this.crop = 'All',
    this.season = 'All',
    this.field = 'All',
    this.archive = ArchiveFilter.active,
  });

  ReportRecordFilters copyWith({
    String? period,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
    String? crop,
    String? season,
    String? field,
    ArchiveFilter? archive,
  }) {
    return ReportRecordFilters(
      period: period ?? this.period,
      dateRange: clearDateRange ? null : dateRange ?? this.dateRange,
      crop: crop ?? this.crop,
      season: season ?? this.season,
      field: field ?? this.field,
      archive: archive ?? this.archive,
    );
  }

  Map<String, dynamic> toQuery() {
    final params = <String, dynamic>{
      'period': period,
      'status': archive.name,
    };
    if (dateRange != null) {
      params['from'] = _dateOnly(dateRange!.start);
      params['to'] = _dateOnly(dateRange!.end);
    }
    if (crop != 'All') params['crop'] = crop;
    if (season != 'All') params['season'] = season;
    if (field != 'All') params['field'] = field;
    return params;
  }

  String get summary {
    final bits = <String>[
      dateRange == null
          ? period
          : '${_dateOnly(dateRange!.start)} to ${_dateOnly(dateRange!.end)}',
      if (crop != 'All') crop,
      if (season != 'All') season,
      if (field != 'All') field,
      archive.label,
    ];
    return bits.join(' / ');
  }

  static String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  bool operator ==(Object other) {
    return other is ReportRecordFilters &&
        other.period == period &&
        other.dateRange?.start == dateRange?.start &&
        other.dateRange?.end == dateRange?.end &&
        other.crop == crop &&
        other.season == season &&
        other.field == field &&
        other.archive == archive;
  }

  @override
  int get hashCode => Object.hash(
        period,
        dateRange?.start,
        dateRange?.end,
        crop,
        season,
        field,
        archive,
      );
}

extension ArchiveFilterLabel on ArchiveFilter {
  String get label {
    switch (this) {
      case ArchiveFilter.active:
        return 'Active';
      case ArchiveFilter.archived:
        return 'Archived';
      case ArchiveFilter.all:
        return 'All status';
    }
  }
}

class ReportRecordFilterBar extends StatefulWidget {
  final ReportRecordFilters value;
  final List<String> crops;
  final List<String> seasons;
  final List<String> fields;
  final ValueChanged<ReportRecordFilters> onChanged;

  const ReportRecordFilterBar({
    super.key,
    required this.value,
    required this.crops,
    required this.seasons,
    required this.fields,
    required this.onChanged,
  });

  @override
  State<ReportRecordFilterBar> createState() => _ReportRecordFilterBarState();
}

class _ReportRecordFilterBarState extends State<ReportRecordFilterBar> {
  static const _periods = [
    'Today',
    'This week',
    'This month',
    'This season',
    'This year',
    'Custom',
  ];

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: FarmioColors.softBorder),
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
                const Expanded(
                  child: Text(
                    'Filters',
                    style: TextStyle(
                      color: FarmioColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    value.summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: FarmioColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20, color: FarmioColors.textMuted),
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
                  _FilterMenu(
                    icon: Icons.calendar_today_outlined,
                    label: value.period == 'Custom' && value.dateRange != null
                        ? 'Custom dates'
                        : value.period,
                    items: _periods,
                    onSelected: (period) async {
                      if (period == 'Custom') {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate:
                              DateTime.now().add(const Duration(days: 730)),
                          initialDateRange: value.dateRange,
                        );
                        if (picked == null) return;
                        widget.onChanged(value.copyWith(
                          period: period,
                          dateRange: picked,
                        ));
                      } else {
                        widget.onChanged(value.copyWith(
                          period: period,
                          clearDateRange: true,
                        ));
                      }
                    },
                  ),
                  _FilterMenu(
                    icon: Icons.grass_outlined,
                    label: value.crop,
                    items: _withAll(widget.crops),
                    onSelected: (crop) =>
                        widget.onChanged(value.copyWith(crop: crop)),
                  ),
                  _FilterMenu(
                    icon: Icons.event_note_outlined,
                    label: value.season,
                    items: _withAll(widget.seasons),
                    onSelected: (season) =>
                        widget.onChanged(value.copyWith(season: season)),
                  ),
                  _FilterMenu(
                    icon: Icons.map_outlined,
                    label: value.field,
                    items: _withAll(widget.fields),
                    onSelected: (field) =>
                        widget.onChanged(value.copyWith(field: field)),
                  ),
                  _FilterMenu(
                    icon: Icons.inventory_2_outlined,
                    label: value.archive.label,
                    items: ArchiveFilter.values
                        .map((item) => item.label)
                        .toList(),
                    onSelected: (label) {
                      final archive = ArchiveFilter.values
                          .firstWhere((item) => item.label == label);
                      widget.onChanged(value.copyWith(archive: archive));
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static List<String> _withAll(List<String> items) {
    final values = {...items.where((item) => item.trim().isNotEmpty)}.toList()
      ..sort();
    return ['All', ...values.where((item) => item != 'All')];
  }
}

class _FilterMenu extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> items;
  final ValueChanged<String> onSelected;

  const _FilterMenu({
    required this.icon,
    required this.label,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<String>(
        tooltip: label,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onSelected: onSelected,
        itemBuilder: (context) => items
            .map((item) => PopupMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(color: FarmioColors.textPrimary),
                  ),
                ))
            .toList(),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: FarmioColors.slate50,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: FarmioColors.softBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: FarmioColors.primary),
              const SizedBox(width: 7),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 118),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: FarmioColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 16, color: FarmioColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
