import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/crop_field.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_shimmer.dart';
import '../../shared/widgets/farmio_summary_bar.dart';
import '../fields/fields_provider.dart';
import 'crops_provider.dart';

class CropsScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const CropsScreen({super.key, this.embedded = false});

  @override
  ConsumerState<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends ConsumerState<CropsScreen> {
  String  _statusFilter  = 'All';
  String  _seasonFilter  = 'All';
  String  _fieldFilter   = 'All';
  bool    _groupBySeason = true;
  bool    _showFilters   = false;

  final _statuses = ['All', 'Active', 'Harvested', 'Failed'];

  @override
  Widget build(BuildContext context) {
    // Load all crops (no server-side filter — we filter client-side)
    final cropsAsync  = ref.watch(allCropsProvider);
    final fieldsAsync = ref.watch(fieldsProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: widget.embedded
          ? null
          : AppBar(
              title: const Text('Crops',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
      body: cropsAsync.when(
        loading: () => const _Skeleton(),
        error:   (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(allCropsProvider),
        ),
        data: (allCrops) {
          // Derive filter options from data
          final seasons = ['All',
            ...{...allCrops.map((c) => c.season)}.toList()
              ..sort((a, b) => b.compareTo(a)),
          ];

          final fieldNames = fieldsAsync.whenOrNull(
            data: (f) => {'All': 'All fields',
              ...{for (final x in f) x.id: x.name}},
          ) ?? {'All': 'All fields'};

          // Apply filters
          final filtered = allCrops.where((c) {
            if (_statusFilter != 'All' && c.status != _statusFilter) return false;
            if (_seasonFilter != 'All' && c.season != _seasonFilter) return false;
            if (_fieldFilter  != 'All' && c.fieldId != _fieldFilter)  return false;
            return true;
          }).toList();

          // Summary counts
          final activeCount    = allCrops.where((c) => c.status == 'Active').length;
          final harvestedCount = allCrops.where((c) => c.status == 'Harvested').length;
          final failedCount    = allCrops.where((c) => c.status == 'Failed').length;
          final seasonCount    = {...allCrops.map((c) => c.season)}.length;
          final totalArea      = allCrops
              .where((c) => c.status == 'Active')
              .fold(0.0, (s, c) => s + c.areaPlanted);

          return RefreshIndicator(
            color:     FarmioColors.primary,
            onRefresh: () async => ref.invalidate(allCropsProvider),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [

                // Summary
                FarmioSummaryBar(
                  stats: [
                    FarmioSummaryStat(
                        label: 'Active',
                        value: '$activeCount',
                        color: Colors.greenAccent),
                    FarmioSummaryStat(
                        label: 'Harvested',
                        value: '$harvestedCount',
                        color: Colors.lightBlueAccent),
                    FarmioSummaryStat(
                        label: 'Failed',
                        value: '$failedCount',
                        color: Colors.redAccent),
                    FarmioSummaryStat(
                        label: 'Seasons',
                        value: '$seasonCount',
                        color: Colors.orangeAccent),
                  ],
                  footer: Text(
                    '${Fmt.haShort(totalArea)} actively planted',
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ),
                const SizedBox(height: 16),

                // Filter toggle
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _showFilters = !_showFilters),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: FarmioColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.tune_rounded,
                            size: 17, color: FarmioColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusFilter != 'All' ||
                                    _seasonFilter != 'All' ||
                                    _fieldFilter != 'All'
                                ? 'Filters: $_statusFilter · $_seasonFilter · $_fieldFilter'
                                : 'Filters',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: FarmioColors.textPrimary,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: _showFilters ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 18, color: FarmioColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showFilters) ...[
                  const SizedBox(height: 10),

                  // Status filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _statuses.map((s) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label:    s,
                          selected: _statusFilter == s,
                          onTap:    () => setState(() => _statusFilter = s),
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Season + Field dropdowns + Group toggle
                  Row(children: [
                    Expanded(
                      child: _DropdownFilter(
                        value:    _seasonFilter,
                        items:    seasons,
                        label:    'Season',
                        onChanged: (v) => setState(() => _seasonFilter = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DropdownFilter(
                        value:     _fieldFilter,
                        items:     fieldNames.keys.toList(),
                        itemLabels: fieldNames,
                        label:     'Field',
                        onChanged: (v) => setState(() => _fieldFilter = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _GroupToggle(
                      active:  _groupBySeason,
                      onToggle: () =>
                          setState(() => _groupBySeason = !_groupBySeason),
                    ),
                  ]),
                ],
                const SizedBox(height: 16),

                // Results
                if (filtered.isEmpty)
                  const _EmptyState()
                else if (_groupBySeason)
                  _GroupedList(
                    crops:    filtered,
                    onTap:    (c) => _openDetail(context, ref, c),
                    onArchive: (c) => _archive(ref, c),
                    onRestore: (c) => _restore(ref, c),
                    onDelete:  (c) => _confirmDelete(context, ref, c),
                  )
                else
                  _FlatList(
                    crops:    filtered,
                    onTap:    (c) => _openDetail(context, ref, c),
                    onArchive: (c) => _archive(ref, c),
                    onRestore: (c) => _restore(ref, c),
                    onDelete:  (c) => _confirmDelete(context, ref, c),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: FarmioColors.primary,
        onPressed: () => context.push('/crops/new'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _openDetail(BuildContext context, WidgetRef ref, CropFieldModel c) {
    context.push('/crops/${c.id}');
  }

  Future<void> _archive(WidgetRef ref, CropFieldModel c) async {
    await ref.read(cropsRepositoryProvider).archiveCrop(c.id);
    ref.invalidate(allCropsProvider);
  }

  Future<void> _restore(WidgetRef ref, CropFieldModel c) async {
    await ref.read(cropsRepositoryProvider).restoreCrop(c.id);
    ref.invalidate(allCropsProvider);
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, CropFieldModel c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title:   const Text('Delete crop'),
        content: Text('Delete "${c.cropTypeName} (${c.variety})"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete',
                  style: TextStyle(color: FarmioColors.danger))),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(cropsRepositoryProvider).deleteCrop(c.id);
      ref.invalidate(allCropsProvider);
    }
  }
}

// ── Provider for all crops (no server filter) ─────────────────────────────────
final allCropsProvider =
FutureProvider.autoDispose<List<CropFieldModel>>((ref) {
  return ref.read(cropsRepositoryProvider).getCrops();
});

// ── Grouped list ──────────────────────────────────────────────────────────────
class _GroupedList extends StatelessWidget {
  final List<CropFieldModel>      crops;
  final void Function(CropFieldModel) onTap;
  final void Function(CropFieldModel) onArchive;
  final void Function(CropFieldModel) onRestore;
  final void Function(CropFieldModel) onDelete;

  const _GroupedList({
    required this.crops,
    required this.onTap,
    required this.onArchive,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Group by season
    final Map<String, List<CropFieldModel>> grouped = {};
    for (final c in crops) {
      grouped.putIfAbsent(c.season, () => []).add(c);
    }
    final seasons = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: seasons.map((season) {
        final list  = grouped[season]!;
        final area  = list.fold(0.0, (s, c) => s + c.areaPlanted);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Season header
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Text(season,
                    style: const TextStyle(
                      fontSize:   15,
                      fontWeight: FontWeight.w800,
                      color:      FarmioColors.textPrimary,
                    )),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color:        FarmioColors.warningBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${list.length} crop${list.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize:   10,
                      fontWeight: FontWeight.w700,
                      color:      FarmioColors.warning,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(Fmt.haShort(area),
                    style: const TextStyle(
                      fontSize: 12, color: FarmioColors.textMuted,
                    )),
              ]),
            ),
            ...list.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child:   _CropCard(
                crop:      c,
                onTap:     () => onTap(c),
                onArchive: () => onArchive(c),
                onRestore: () => onRestore(c),
                onDelete:  () => onDelete(c),
              ),
            )),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }
}

// ── Flat list ─────────────────────────────────────────────────────────────────
class _FlatList extends StatelessWidget {
  final List<CropFieldModel>      crops;
  final void Function(CropFieldModel) onTap;
  final void Function(CropFieldModel) onArchive;
  final void Function(CropFieldModel) onRestore;
  final void Function(CropFieldModel) onDelete;

  const _FlatList({
    required this.crops,
    required this.onTap,
    required this.onArchive,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: crops.map((c) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child:   _CropCard(
          crop:      c,
          onTap:     () => onTap(c),
          onArchive: () => onArchive(c),
          onRestore: () => onRestore(c),
          onDelete:  () => onDelete(c),
        ),
      )).toList(),
    );
  }
}

// ── Crop card ─────────────────────────────────────────────────────────────────
class _CropCard extends StatelessWidget {
  final CropFieldModel        crop;
  final VoidCallback          onTap;
  final VoidCallback          onArchive;
  final VoidCallback          onRestore;
  final VoidCallback          onDelete;

  const _CropCard({
    required this.crop,
    required this.onTap,
    required this.onArchive,
    required this.onRestore,
    required this.onDelete,
  });

  Color get _statusColor {
    switch (crop.status) {
      case 'Active':    return FarmioColors.success;
      case 'Harvested': return FarmioColors.info;
      case 'Failed':    return FarmioColors.danger;
      case 'Archived':  return FarmioColors.textMuted;
      default:
        if (crop.isOverdue)  return FarmioColors.danger;
        if (crop.isDueSoon)  return FarmioColors.warning;
        return FarmioColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color      = _statusColor;
    final isArchived = crop.status == 'Archived';
    final days       = crop.daysToHarvest;

    double progressValue = 0;
    if (!isArchived && crop.status == 'Active') {
      final total   = crop.expectedHarvestDate
          .difference(crop.plantingDate).inDays;
      final elapsed = DateTime.now()
          .difference(crop.plantingDate).inDays;
      progressValue =
      total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0;
    }

    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(
            color: color.withValues(alpha:0.25),
          ),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withValues(alpha:0.03),
              blurRadius: 6,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Header row
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color:        color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    crop.status == 'Harvested'
                        ? Icons.agriculture_outlined
                        : crop.status == 'Failed'
                            ? Icons.block_outlined
                            : Icons.grass_outlined,
                    size: 18,
                    color: crop.status == 'Failed'
                        ? FarmioColors.danger
                        : FarmioColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${crop.cropTypeName} · ${crop.variety}',
                      style: const TextStyle(
                        fontSize:   14,
                        fontWeight: FontWeight.w800,
                        color:      FarmioColors.textPrimary,
                      )),
                  Text(crop.fieldName,
                      style: const TextStyle(
                        fontSize: 12,
                        color:    FarmioColors.textMuted,
                      )),
                ],
              )),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:        color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(crop.status,
                    style: TextStyle(
                      fontSize:   10,
                      fontWeight: FontWeight.w700,
                      color:      color,
                    )),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'archive') onArchive();
                  if (v == 'restore') onRestore();
                  if (v == 'delete')  onDelete();
                },
                itemBuilder: (_) => [
                  if (crop.status != 'Archived')
                    const PopupMenuItem(
                      value: 'archive',
                      child: Row(children: [
                        Icon(Icons.archive_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Archive'),
                      ]),
                    ),
                  if (crop.status == 'Archived')
                    const PopupMenuItem(
                      value: 'restore',
                      child: Row(children: [
                        Icon(Icons.unarchive_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Restore'),
                      ]),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline,
                          color: FarmioColors.danger, size: 16),
                      SizedBox(width: 8),
                      Text('Delete',
                          style: TextStyle(color: FarmioColors.danger)),
                    ]),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 12),

            // Info grid
            Row(children: [
              _InfoBox(label: 'Area',    value: Fmt.haShort(crop.areaPlanted)),
              const SizedBox(width: 8),
              _InfoBox(label: 'Planted', value: Fmt.dateShort(crop.plantingDate)),
              const SizedBox(width: 8),
              _InfoBox(
                label: 'Harvest',
                value: Fmt.dateShort(crop.expectedHarvestDate),
              ),
            ]),

            // Progress bar — only for active crops
            if (crop.status == 'Active') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Growth',
                      style: TextStyle(
                        fontSize: 11,
                        color:    FarmioColors.textMuted,
                      )),
                  Text(
                    crop.isOverdue
                        ? '${days.abs()}d overdue'
                        : crop.isDueSoon
                        ? 'Due in ${days}d'
                        : 'Harvest ${Fmt.dateShort(crop.expectedHarvestDate)}',
                    style: TextStyle(
                      fontSize:   11,
                      color:      color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value:           progressValue,
                  minHeight:       5,
                  backgroundColor: FarmioColors.border,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label, value;
  const _InfoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color:        FarmioColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                  fontSize: 10,
                  color:    FarmioColors.textMuted,
                )),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                  fontSize:   11,
                  fontWeight: FontWeight.w700,
                  color:      FarmioColors.textPrimary,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String   label;
  final bool     selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? FarmioColors.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? FarmioColors.primary
                : FarmioColors.border,
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.w700,
              color: selected
                  ? Colors.white
                  : FarmioColors.textMuted,
            )),
      ),
    );
  }
}

// ── Dropdown filter ───────────────────────────────────────────────────────────
class _DropdownFilter extends StatelessWidget {
  final String              value;
  final List<String>        items;
  final Map<String, String>? itemLabels;
  final String              label;
  final void Function(String) onChanged;

  const _DropdownFilter({
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
    this.itemLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color:        context.colors.surface,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: context.colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value:      value,
          isExpanded: true,
          style: TextStyle(
            fontSize:   12,
            color:      context.colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          items: items.map((i) => DropdownMenuItem(
            value: i,
            child: Text(
              itemLabels?[i] ?? i,
              overflow: TextOverflow.ellipsis,
            ),
          )).toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }
}

// ── Group toggle ──────────────────────────────────────────────────────────────
class _GroupToggle extends StatelessWidget {
  final bool         active;
  final VoidCallback onToggle;
  const _GroupToggle({required this.active, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        onToggle,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active
              ? FarmioColors.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? FarmioColors.primary
                : FarmioColors.border,
          ),
        ),
        child: Icon(
          Icons.view_agenda_outlined,
          size:  18,
          color: active ? Colors.white : FarmioColors.textMuted,
        ),
      ),
    );
  }
}

// ── Skeleton / Empty / Error ──────────────────────────────────────────────────
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding:          const EdgeInsets.all(20),
      itemCount:        4,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const FarmioShimmer(
        width: double.infinity,
        height: 130,
        radius: 16,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.grass_outlined,
                size: 48, color: FarmioColors.primary),
            SizedBox(height: 16),
            Text('No crops match your filters',
                style: TextStyle(
                  fontSize:   16,
                  fontWeight: FontWeight.w800,
                  color:      FarmioColors.textPrimary,
                )),
            SizedBox(height: 6),
            Text('Try adjusting your season, status or field filter',
                textAlign: TextAlign.center,
                style: TextStyle(color: FarmioColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: FarmioColors.danger),
          const SizedBox(height: 12),
          const Text('Could not load crops',
              style: TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.w700,
                color:      FarmioColors.textPrimary,
              )),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon:      const Icon(Icons.refresh),
            label:     const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
