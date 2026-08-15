import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../models/report.dart';
import '../../shared/filters/report_record_filters.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_summary_bar.dart';
import 'reports_provider.dart';

// Report tabs matching the web app
enum ReportTab {
  season, crop, field, cropField, labour, inputs, yields
}

const _tabLabels = {
  ReportTab.season:    'Season P&L',
  ReportTab.crop:      'Crop costs',
  ReportTab.field:     'Field costs',
  ReportTab.cropField: 'Crop-field',
  ReportTab.labour:    'Labour',
  ReportTab.inputs:    'Inputs',
  ReportTab.yields:    'Yields',
};

List<String> _filterCrops(ReportData data) {
  return {
    ...data.cropReport.map((item) => item.cropName),
    ...data.cropFieldDetail.map((item) => item.cropName),
    ...data.yieldsReport.byType.map((item) => item.cropName),
    ...data.yieldsReport.records.map((item) => item.cropName),
  }.toList();
}

List<String> _filterSeasons(ReportData data) {
  return {
    ...data.seasonReport.map((item) => item.season),
    ...data.cropReport.expand((item) => item.seasons),
    ...data.cropFieldDetail.map((item) => item.season),
    ...data.yieldsReport.records.map((item) => item.season),
  }.toList();
}

List<String> _filterFields(ReportData data) {
  return {
    ...data.fieldReport.map((item) => item.fieldName),
    ...data.cropFieldDetail.map((item) => item.fieldName),
    ...data.yieldsReport.records.map((item) => item.fieldName),
  }.toList();
}

ReportData _applyLocalFilters(
  ReportData data,
  ReportRecordFilters filters,
) {
  final crop = filters.crop;
  final season = filters.season;
  final field = filters.field;

  bool activeStatus(String status) {
    final normalized = status.toLowerCase();
    if (filters.archive == ArchiveFilter.all) return true;
    if (filters.archive == ArchiveFilter.archived) {
      return normalized.contains('archived') ||
          normalized.contains('closed') ||
          normalized.contains('completed');
    }
    return !normalized.contains('archived') && !normalized.contains('closed');
  }

  final seasonReport = data.seasonReport.where((item) {
    if (season != 'All' && item.season != season) return false;
    if (crop != 'All' && !item.crops.contains(crop)) return false;
    if (field != 'All' && !item.fields.contains(field)) return false;
    return true;
  }).toList();

  final cropReport = data.cropReport.where((item) {
    if (crop != 'All' && item.cropName != crop) return false;
    if (season != 'All' && !item.seasons.contains(season)) return false;
    return true;
  }).toList();

  final fieldReport = data.fieldReport.where((item) {
    if (field != 'All' && item.fieldName != field) return false;
    if (crop != 'All' && !item.crops.contains(crop)) return false;
    return true;
  }).toList();

  final cropFieldDetail = data.cropFieldDetail.where((item) {
    if (crop != 'All' && item.cropName != crop) return false;
    if (season != 'All' && item.season != season) return false;
    if (field != 'All' && item.fieldName != field) return false;
    return activeStatus(item.status);
  }).toList();

  final yieldRecords = data.yieldsReport.records.where((item) {
    if (crop != 'All' && item.cropName != crop) return false;
    if (season != 'All' && item.season != season) return false;
    if (field != 'All' && item.fieldName != field) return false;
    return true;
  }).toList();

  final yieldTypes = data.yieldsReport.byType.where((item) {
    if (crop != 'All' && item.cropName != crop) return false;
    return true;
  }).toList();

  return ReportData(
    financeSummary: data.financeSummary,
    seasonReport: seasonReport,
    cropReport: cropReport,
    fieldReport: fieldReport,
    cropFieldDetail: cropFieldDetail,
    employeeReport: data.employeeReport,
    inputReport: data.inputReport,
    yieldsReport: YieldsReport(byType: yieldTypes, records: yieldRecords),
  );
}

String _csvCell(Object? value) {
  final text = '$value';
  if (text.contains(',') || text.contains('"') || text.contains('\n')) {
    return '"${text.replaceAll('"', '""')}"';
  }
  return text;
}

String _csvRow(List<Object?> cells) => cells.map(_csvCell).join(',');

String _buildReportCsv(ReportData data, Set<ReportTab> tabs) {
  final lines = <String>[];

  void section(String title, List<String> headers, List<List<Object?>> rows) {
    if (lines.isNotEmpty) lines.add('');
    lines.add(title);
    lines.add(_csvRow(headers));
    for (final row in rows) {
      lines.add(_csvRow(row));
    }
  }

  if (tabs.contains(ReportTab.season)) {
    section(_tabLabels[ReportTab.season]!,
        ['Season', 'Fields', 'Crops', 'Area (ha)', 'Labour', 'Inputs', 'Other', 'Total cost', 'Cost/ha'],
        data.seasonReport.map((s) => [
              s.season, s.fields.join('; '), s.crops.join('; '),
              s.totalArea, s.labourCost, s.inputCost, s.otherCost,
              s.totalCost, s.costPerHectare,
            ]).toList());
  }
  if (tabs.contains(ReportTab.crop)) {
    section(_tabLabels[ReportTab.crop]!,
        ['Crop', 'Seasons', 'Area (ha)', 'Records', 'Labour', 'Inputs', 'Total cost', 'Cost/ha'],
        data.cropReport.map((c) => [
              c.cropName, c.seasons.join('; '), c.totalArea, c.count,
              c.labourCost, c.inputCost, c.totalCost, c.costPerHectare,
            ]).toList());
  }
  if (tabs.contains(ReportTab.field)) {
    section(_tabLabels[ReportTab.field]!,
        ['Field', 'Soil type', 'Total area', 'Planted', 'Crops', 'Labour', 'Inputs', 'Total cost', 'Cost/ha'],
        data.fieldReport.map((f) => [
              f.fieldName, f.soilType, f.totalArea, f.totalAreaPlanted,
              f.crops.join('; '), f.labourCost, f.inputCost, f.totalCost,
              f.costPerHectare,
            ]).toList());
  }
  if (tabs.contains(ReportTab.cropField)) {
    section(_tabLabels[ReportTab.cropField]!,
        ['Crop', 'Variety', 'Field', 'Season', 'Status', 'Area', 'Labour', 'Inputs', 'Other', 'Total cost', 'Cost/ha'],
        data.cropFieldDetail.map((c) => [
              c.cropName, c.variety, c.fieldName, c.season, c.status,
              c.areaPlanted, c.labour, c.inputs, c.other, c.totalCost,
              c.costPerHectare,
            ]).toList());
  }
  if (tabs.contains(ReportTab.labour)) {
    section(_tabLabels[ReportTab.labour]!,
        ['Employee', 'Role', 'Activities', 'Days', 'Hours', 'Total earned'],
        data.employeeReport.map((e) => [
              e.name, e.role, e.activities, e.totalDays, e.totalHours,
              e.totalEarned,
            ]).toList());
  }
  if (tabs.contains(ReportTab.inputs)) {
    section(_tabLabels[ReportTab.inputs]!,
        ['Input', 'Category', 'Unit', 'Total quantity', 'Times used', 'Total cost'],
        data.inputReport.map((i) => [
              i.inputName, i.category, i.unit, i.totalQuantity,
              i.usageCount, i.totalCost,
            ]).toList());
  }
  if (tabs.contains(ReportTab.yields)) {
    section('${_tabLabels[ReportTab.yields]!} (by crop)',
        ['Crop', 'Records', 'Area planted', 'Yield (kg)', 'Yield/ha', 'Cost/kg'],
        data.yieldsReport.byType.map((y) => [
              y.cropName, y.records, y.totalAreaPlanted, y.totalYieldKg,
              y.yieldPerHa, y.costPerKg,
            ]).toList());
    section('${_tabLabels[ReportTab.yields]!} (records)',
        ['Crop', 'Variety', 'Field', 'Season', 'Area', 'Yield (kg)', 'Total cost', 'Cost/kg', 'Yield/ha'],
        data.yieldsReport.records.map((r) => [
              r.cropName, r.variety, r.fieldName, r.season, r.areaPlanted,
              r.totalYieldKg, r.totalCost, r.costPerKg, r.yieldPerHa,
            ]).toList());
  }

  return lines.join('\n');
}

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() =>
      _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportTab _tab = ReportTab.season;
  ReportRecordFilters _filters = const ReportRecordFilters();
  final Set<ReportTab> _exportTabs = {...ReportTab.values};

  // Crop-field filters
  String _seasonFilter = 'All';
  String _fieldFilter  = 'All';

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(reportsProvider(_filters));

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Reports',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(reportsProvider(_filters)),
          ),
        ],
      ),
      body: report.when(
        loading: () => const _Skeleton(),
        error:   (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(reportsProvider(_filters)),
        ),
        data: (data) {
          final filteredData = _applyLocalFilters(data, _filters);
          return RefreshIndicator(
            color:     FarmioColors.primary,
            onRefresh: () async =>
                ref.invalidate(reportsProvider(_filters)),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [

                // Finance summary banner
                _FinanceBanner(summary: data.financeSummary),
                ReportRecordFilterBar(
                  value: _filters,
                  crops: _filterCrops(data),
                  seasons: _filterSeasons(data),
                  fields: _filterFields(data),
                  onChanged: (filters) => setState(() {
                    _filters = filters;
                    if (filters.season != 'All') {
                      _seasonFilter = filters.season;
                    }
                    if (filters.field != 'All') {
                      _fieldFilter = filters.field;
                    }
                  }),
                ),
                const _AnalyticsIntro(),
                _ChartsOverview(data: filteredData),

                // Tab selector
                Container(
                  color: FarmioColors.background,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    child: Row(
                      children: ReportTab.values.map((tab) {
                        final selected = _tab == tab;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => setState(() => _tab = tab),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? FarmioColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: selected
                                      ? FarmioColors.primary
                                      : FarmioColors.softBorder,
                                ),
                              ),
                              child: Text(_tabLabels[tab]!,
                                  style: TextStyle(
                                    fontSize:   12,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? Colors.white
                                        : FarmioColors.textSecond,
                                  )),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Report content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _ReportExportPanel(
                        filters: _filters,
                        data: filteredData,
                        selectedTabs: _exportTabs,
                        onToggle: (tab) => setState(() {
                          if (_exportTabs.contains(tab)) {
                            _exportTabs.remove(tab);
                          } else {
                            _exportTabs.add(tab);
                          }
                        }),
                      ),
                      const SizedBox(height: 16),
                      _ReportTablesOverview(data: filteredData),
                      const SizedBox(height: 18),
                      if (_tab == ReportTab.season)
                        _SeasonTab(data: filteredData.seasonReport),

                      if (_tab == ReportTab.crop)
                        _CropTab(data: filteredData.cropReport),

                      if (_tab == ReportTab.field)
                        _FieldTab(data: filteredData.fieldReport),

                      if (_tab == ReportTab.cropField)
                        _CropFieldTab(
                          data:          filteredData.cropFieldDetail,
                          seasonFilter:  _seasonFilter,
                          fieldFilter:   _fieldFilter,
                          allSeasons: [
                            'All',
                            ...{...filteredData.cropFieldDetail
                                .map((c) => c.season)}.toList()
                              ..sort((a, b) => b.compareTo(a)),
                          ],
                          allFields: [
                            'All',
                            ...{...filteredData.cropFieldDetail
                                .map((c) => c.fieldName)},
                          ],
                          onSeasonChanged: (v) =>
                              setState(() => _seasonFilter = v),
                          onFieldChanged:  (v) =>
                              setState(() => _fieldFilter  = v),
                        ),

                      if (_tab == ReportTab.labour)
                        _LabourTab(data: filteredData.employeeReport),

                      if (_tab == ReportTab.inputs)
                        _InputsTab(data: filteredData.inputReport),

                      if (_tab == ReportTab.yields)
                        _YieldsTab(data: filteredData.yieldsReport),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Finance banner ────────────────────────────────────────────────────────────
class _FinanceBanner extends StatelessWidget {
  final FinanceSummary summary;
  const _FinanceBanner({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: FarmioSummaryBar(stats: [
        FarmioSummaryStat(
            label: 'Income',
            value: Fmt.mwk(summary.totalIncome),
            color: Colors.greenAccent),
        FarmioSummaryStat(
            label: 'Activity cost',
            value: Fmt.mwk(summary.totalActivityCost),
            color: Colors.redAccent),
        FarmioSummaryStat(
            label: 'Overhead',
            value: Fmt.mwk(summary.totalOverheadCost),
            color: Colors.orangeAccent),
        FarmioSummaryStat(
          label: 'Net',
          value: Fmt.mwk(summary.net),
          color: summary.net >= 0 ? Colors.greenAccent : Colors.redAccent,
        ),
      ]),
    );
  }
}

class _AnalyticsIntro extends StatelessWidget {
  const _AnalyticsIntro();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: FarmioColors.softBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: FarmioColors.primaryBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.query_stats_rounded,
                color: FarmioColors.primary),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistics',
                  style: TextStyle(
                    color: FarmioColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Use reports to compare seasons, costs, labour, inputs and yield performance.',
                  style: TextStyle(
                    color: FarmioColors.textSecond,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartsOverview extends StatelessWidget {
  final ReportData data;

  const _ChartsOverview({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 306,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        children: [
          _FinanceMixChart(summary: data.financeSummary),
          const SizedBox(width: 12),
          _CropCostChart(crops: data.cropReport),
          const SizedBox(width: 12),
          _YieldEfficiencyChart(items: data.yieldsReport.byType),
          const SizedBox(width: 12),
          _SeasonCostChart(seasons: data.seasonReport),
          const SizedBox(width: 12),
          _SeasonExpenseMixChart(seasons: data.seasonReport),
        ],
      ),
    );
  }
}

class _ReportExportPanel extends StatelessWidget {
  final ReportRecordFilters filters;
  final ReportData data;
  final Set<ReportTab> selectedTabs;
  final ValueChanged<ReportTab> onToggle;

  const _ReportExportPanel({
    required this.filters,
    required this.data,
    required this.selectedTabs,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final sections = selectedTabs
        .map((tab) => 'report=${tab.name}')
        .join('&');
    final filterParams = filters.toQuery().entries
        .map((entry) => '${entry.key}=${Uri.encodeComponent('${entry.value}')}')
        .join('&');
    final params = [
      if (sections.isNotEmpty) sections,
      if (filterParams.isNotEmpty) filterParams,
    ].join('&');
    final exportUrl = params.isEmpty
        ? '/mobile/reports/export?format=pdf'
        : '/mobile/reports/export?$params&format=pdf';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: FarmioColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: FarmioColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.ios_share_rounded,
                    color: FarmioColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report export',
                      style: TextStyle(
                        color: FarmioColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Select the report sections to include.',
                      style: TextStyle(
                        color: FarmioColors.textSecond,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ReportTab.values.map((tab) {
              final selected = selectedTabs.contains(tab);
              return FilterChip(
                selected: selected,
                label: Text(_tabLabels[tab]!),
                avatar: Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.add_circle_outline_rounded,
                  size: 17,
                ),
                onSelected: (_) => onToggle(tab),
                selectedColor: FarmioColors.primary,
                backgroundColor: Colors.white,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: selected
                      ? FarmioColors.primary
                      : FarmioColors.softBorder,
                ),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : FarmioColors.textSecond,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          SelectableText(
            exportUrl,
            style: const TextStyle(
              color: FarmioColors.info,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('PDF'),
                  onPressed: selectedTabs.isEmpty
                      ? null
                      : () => _generatePdf(context, exportUrl),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.table_chart_outlined),
                  label: const Text('CSV'),
                  onPressed: selectedTabs.isEmpty
                      ? null
                      : () => _generateCsv(context, data, selectedTabs),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _generateCsv(
    BuildContext context,
    ReportData data,
    Set<ReportTab> tabs,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final csv = _buildReportCsv(data, tabs);
      final dir = await getTemporaryDirectory();
      final date = DateTime.now().toIso8601String().split('T').first;
      final file = File('${dir.path}/agrivault-report-$date.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(file.path)],
          text: 'Farmio report export');
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not generate CSV report. Try again.'),
        ),
      );
    }
  }

  Future<void> _generatePdf(BuildContext context, String exportUrl) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Generating PDF report...')),
    );
    try {
      final response = await ApiClient.getBytes(exportUrl);
      final bytes = response.data ?? const <int>[];
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'PDF generated (${(bytes.length / 1024).toStringAsFixed(1)} KB).',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not generate PDF report. Try again.'),
        ),
      );
    }
  }
}

class _ReportTablesOverview extends StatelessWidget {
  final ReportData data;

  const _ReportTablesOverview({required this.data});

  @override
  Widget build(BuildContext context) {
    final crops = [...data.cropReport]
      ..sort((a, b) => b.totalCost.compareTo(a.totalCost));
    final fields = [...data.fieldReport]
      ..sort((a, b) => b.totalCost.compareTo(a.totalCost));
    final yields = [...data.yieldsReport.byType]
      ..sort((a, b) => b.yieldPerHa.compareTo(a.yieldPerHa));

    return Column(
      children: [
        _TableCard(
          title: 'Crop cost table',
          columns: const ['Crop', 'Area', 'Total', 'Cost/ha'],
          rows: crops.take(6).map((item) => [
            item.cropName,
            Fmt.haShort(item.totalArea),
            Fmt.mwk(item.totalCost),
            Fmt.mwk(item.costPerHectare),
          ]).toList(),
          emptyLabel: 'No crop costs match these filters',
        ),
        const SizedBox(height: 14),
        _TableCard(
          title: 'Field cost table',
          columns: const ['Field', 'Planted', 'Total', 'Cost/ha'],
          rows: fields.take(6).map((item) => [
            item.fieldName,
            Fmt.haShort(item.totalAreaPlanted),
            Fmt.mwk(item.totalCost),
            Fmt.mwk(item.costPerHectare),
          ]).toList(),
          emptyLabel: 'No field costs match these filters',
        ),
        const SizedBox(height: 14),
        _TableCard(
          title: 'Yield efficiency table',
          columns: const ['Crop', 'Records', 'Yield', 'Kg/ha'],
          rows: yields.take(6).map((item) => [
            item.cropName,
            '${item.records}',
            item.displayKg,
            '${item.yieldPerHa.round()}',
          ]).toList(),
          emptyLabel: 'No yield records match these filters',
        ),
      ],
    );
  }
}

class _TableCard extends StatelessWidget {
  final String title;
  final List<String> columns;
  final List<List<String>> rows;
  final String emptyLabel;

  const _TableCard({
    required this.title,
    required this.columns,
    required this.rows,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: FarmioColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: FarmioColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                emptyLabel,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                headingRowHeight: 36,
                dataRowMinHeight: 42,
                dataRowMaxHeight: 48,
                dividerThickness: 0.5,
                headingTextStyle: const TextStyle(
                  color: FarmioColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
                dataTextStyle: const TextStyle(
                  color: FarmioColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                columns: columns
                    .map((column) => DataColumn(label: Text(column)))
                    .toList(),
                rows: rows
                    .map((row) => DataRow(
                          cells: row
                              .map((cell) => DataCell(Text(cell)))
                              .toList(),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _FinanceMixChart extends StatelessWidget {
  final FinanceSummary summary;

  const _FinanceMixChart({required this.summary});

  @override
  Widget build(BuildContext context) {
    final activity = summary.totalActivityCost;
    final overhead = summary.totalOverheadCost;
    final income = summary.totalIncome;
    final total = activity + overhead + income;

    return _ChartCard(
      title: 'Cash position',
      subtitle: 'Income vs cost structure',
      child: total <= 0
          ? const _ChartEmpty(label: 'No finance data yet')
          : PieChart(
              PieChartData(
                centerSpaceRadius: 34,
                sectionsSpace: 3,
                sections: [
                  PieChartSectionData(
                    value: income,
                    title: '',
                    radius: 42,
                    color: FarmioColors.success,
                  ),
                  PieChartSectionData(
                    value: activity,
                    title: '',
                    radius: 42,
                    color: FarmioColors.info,
                  ),
                  PieChartSectionData(
                    value: overhead,
                    title: '',
                    radius: 42,
                    color: FarmioColors.purple,
                  ),
                ],
              ),
            ),
      footer: [
        _LegendDot(label: 'Income', color: FarmioColors.success),
        _LegendDot(label: 'Activity', color: FarmioColors.info),
        _LegendDot(label: 'Overhead', color: FarmioColors.purple),
      ],
    );
  }
}

class _CropCostChart extends StatelessWidget {
  final List<CropReport> crops;

  const _CropCostChart({required this.crops});

  @override
  Widget build(BuildContext context) {
    final top = [...crops]
      ..sort((a, b) => b.totalCost.compareTo(a.totalCost));
    final shown = top.take(5).toList();
    final maxValue = shown.isEmpty
        ? 1.0
        : shown
            .map((crop) => crop.totalCost)
            .reduce((a, b) => a > b ? a : b);

    return _ChartCard(
      title: 'Crop cost ranking',
      subtitle: 'Highest total cost crops',
      child: shown.isEmpty
          ? const _ChartEmpty(label: 'No crop cost data yet')
          : BarChart(
              BarChartData(
                maxY: maxValue <= 0 ? 1 : maxValue * 1.18,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                barTouchData: BarTouchData(enabled: false),
                barGroups: [
                  for (var i = 0; i < shown.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: shown[i].totalCost,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                          color: i == 0
                              ? FarmioColors.primary
                              : FarmioColors.cyan,
                        ),
                      ],
                    ),
                ],
              ),
            ),
      footer: shown
          .take(3)
          .map((crop) => _ListMetric(
                label: crop.cropName,
                value: Fmt.mwk(crop.totalCost),
              ))
          .toList(),
    );
  }
}

class _YieldEfficiencyChart extends StatelessWidget {
  final List<YieldByType> items;

  const _YieldEfficiencyChart({required this.items});

  @override
  Widget build(BuildContext context) {
    final top = [...items]
      ..sort((a, b) => b.yieldPerHa.compareTo(a.yieldPerHa));
    final shown = top.take(5).toList();
    final maxValue = shown.isEmpty
        ? 1.0
        : shown
            .map((item) => item.yieldPerHa)
            .reduce((a, b) => a > b ? a : b);

    return _ChartCard(
      title: 'Yield efficiency',
      subtitle: 'Yield per hectare by crop',
      child: shown.isEmpty
          ? const _ChartEmpty(label: 'No yield data yet')
          : LineChart(
              LineChartData(
                minY: 0,
                maxY: maxValue <= 0 ? 1 : maxValue * 1.2,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: maxValue <= 0 ? 1 : maxValue / 3,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: FarmioColors.softBorder,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    barWidth: 3,
                    color: FarmioColors.success,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: FarmioColors.success.withValues(alpha: 0.12),
                    ),
                    spots: [
                      for (var i = 0; i < shown.length; i++)
                        FlSpot(i.toDouble(), shown[i].yieldPerHa),
                    ],
                  ),
                ],
              ),
            ),
      footer: shown
          .take(3)
          .map((item) => _ListMetric(
                label: item.cropName,
                value: '${item.yieldPerHa.round()} kg/ha',
              ))
          .toList(),
    );
  }
}

class _SeasonCostChart extends StatelessWidget {
  final List<SeasonReport> seasons;

  const _SeasonCostChart({required this.seasons});

  @override
  Widget build(BuildContext context) {
    final ordered = [...seasons]
      ..sort((a, b) => a.season.compareTo(b.season));
    final shown = ordered.take(6).toList();
    final maxValue = shown.isEmpty
        ? 1.0
        : shown
            .map((s) => s.costPerHectare)
            .reduce((a, b) => a > b ? a : b);

    return _ChartCard(
      title: 'Cost per hectare by season',
      subtitle: 'Production cost trend across seasons',
      child: shown.isEmpty
          ? const _ChartEmpty(label: 'No season data yet')
          : LineChart(
              LineChartData(
                minY: 0,
                maxY: maxValue <= 0 ? 1 : maxValue * 1.2,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: maxValue <= 0 ? 1 : maxValue / 3,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: FarmioColors.softBorder,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    barWidth: 3,
                    color: FarmioColors.info,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: FarmioColors.info.withValues(alpha: 0.12),
                    ),
                    spots: [
                      for (var i = 0; i < shown.length; i++)
                        FlSpot(i.toDouble(), shown[i].costPerHectare),
                    ],
                  ),
                ],
              ),
            ),
      footer: shown
          .map((s) => _ListMetric(
                label: s.season,
                value: Fmt.mwk(s.costPerHectare),
              ))
          .toList(),
    );
  }
}

class _SeasonExpenseMixChart extends StatelessWidget {
  final List<SeasonReport> seasons;

  const _SeasonExpenseMixChart({required this.seasons});

  @override
  Widget build(BuildContext context) {
    final ordered = [...seasons]
      ..sort((a, b) => a.season.compareTo(b.season));
    final shown = ordered.take(5).toList();
    final maxValue = shown.isEmpty
        ? 1.0
        : shown
            .map((s) => s.labourCost + s.inputCost + s.otherCost)
            .reduce((a, b) => a > b ? a : b);

    return _ChartCard(
      title: 'Expense breakdown by season',
      subtitle: 'Labour, inputs and other costs',
      child: shown.isEmpty
          ? const _ChartEmpty(label: 'No season data yet')
          : BarChart(
              BarChartData(
                maxY: maxValue <= 0 ? 1 : maxValue * 1.18,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                barTouchData: BarTouchData(enabled: false),
                barGroups: [
                  for (var i = 0; i < shown.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: shown[i].labourCost +
                              shown[i].inputCost +
                              shown[i].otherCost,
                          width: 16,
                          borderRadius: BorderRadius.circular(6),
                          rodStackItems: [
                            BarChartRodStackItem(
                                0, shown[i].labourCost, Colors.orangeAccent),
                            BarChartRodStackItem(
                                shown[i].labourCost,
                                shown[i].labourCost + shown[i].inputCost,
                                FarmioColors.info),
                            BarChartRodStackItem(
                                shown[i].labourCost + shown[i].inputCost,
                                shown[i].labourCost +
                                    shown[i].inputCost +
                                    shown[i].otherCost,
                                FarmioColors.purple),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
      footer: const [
        _LegendDot(label: 'Labour', color: Colors.orangeAccent),
        _LegendDot(label: 'Inputs', color: FarmioColors.info),
        _LegendDot(label: 'Other', color: FarmioColors.purple),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> footer;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: FarmioColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: FarmioColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: FarmioColors.textSecond,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: child),
          if (footer.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 6, children: footer),
          ],
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
        style: const TextStyle(
          color: FarmioColors.textSecond,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ListMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ListMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: FarmioColors.slate100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: FarmioColors.softBorder),
      ),
      child: Text(
        '$label: $value',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: FarmioColors.textSecond,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ChartEmpty extends StatelessWidget {
  final String label;

  const _ChartEmpty({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: FarmioColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BannerItem extends StatelessWidget {
  final String label, value;
  final Color  color;

  const _BannerItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Season tab ────────────────────────────────────────────────────────────────
class _SeasonTab extends StatelessWidget {
  final List<SeasonReport> data;
  const _SeasonTab({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const _Empty(label: 'No season data yet');

    return Column(
      children: [
        _ReportHeader(
          title: 'Season profitability',
          sub:   'Cost breakdown per growing season',
        ),
        ...data.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child:   _SeasonCard(season: s),
        )),
      ],
    );
  }
}

class _SeasonCard extends StatelessWidget {
  final SeasonReport season;
  const _SeasonCard({required this.season});

  @override
  Widget build(BuildContext context) {
    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(season.season,
                    style: const TextStyle(
                      fontSize:   15,
                      fontWeight: FontWeight.w800,
                      color:      Colors.white,
                    )),
                Text(season.fields.join(', '),
                    style: const TextStyle(
                      fontSize: 11,
                      color:    Colors.white60,
                    )),
              ],
            )),
            _StatusBadge(
              label: '${season.cropCount} crop'
                  '${season.cropCount != 1 ? "s" : ""}',
              color: FarmioColors.primary,
            ),
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing:    6,
            runSpacing: 6,
            children: season.crops
                .map((c) => _Tag(label: c))
                .toList(),
          ),
          const SizedBox(height: 12),
          const Divider(color: FarmioColors.border, height: 1),
          const SizedBox(height: 12),
          Row(children: [
            _MetricCol(
              label: 'Area',
              value: Fmt.haShort(season.totalArea),
            ),
            _MetricCol(
              label: 'Labour',
              value: Fmt.mwk(season.labourCost),
            ),
            _MetricCol(
              label: 'Inputs',
              value: Fmt.mwk(season.inputCost),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _MetricCol(
              label: 'Other',
              value: Fmt.mwk(season.otherCost),
            ),
            _MetricCol(
              label: 'Total cost',
              value: Fmt.mwk(season.totalCost),
              color: FarmioColors.danger,
            ),
            _MetricCol(
              label: 'Cost/ha',
              value: Fmt.mwk(season.costPerHectare),
              color: const Color(0xFF2563EB),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Crop tab ──────────────────────────────────────────────────────────────────
class _CropTab extends StatelessWidget {
  final List<CropReport> data;
  const _CropTab({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const _Empty(label: 'No crop data yet');

    final maxCost = data.isEmpty ? 1.0 : data.first.totalCost;

    return Column(
      children: [
        _ReportHeader(
          title: 'Crop cost analysis',
          sub:   'Aggregated costs per crop type',
        ),
        ...data.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child:   _CropReportCard(crop: c, maxCost: maxCost),
        )),
      ],
    );
  }
}

class _CropReportCard extends StatelessWidget {
  final CropReport crop;
  final double     maxCost;
  const _CropReportCard({required this.crop, required this.maxCost});

  @override
  Widget build(BuildContext context) {
    final pct = maxCost > 0
        ? (crop.costPerHectare /
        (maxCost > 0 ? maxCost : 1))
        .clamp(0.0, 1.0)
        : 0.0;

    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.grass_outlined,
                size: 20, color: FarmioColors.primary),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(crop.cropName,
                    style: const TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w800,
                      color:      Colors.white,
                    )),
                Text(
                  '${crop.count} record'
                      '${crop.count != 1 ? "s" : ""}'
                      ' · ${crop.seasons.length} season'
                      '${crop.seasons.length != 1 ? "s" : ""}',
                  style: const TextStyle(
                    fontSize: 11,
                    color:    Colors.white60,
                  ),
                ),
              ],
            )),
            Text(Fmt.mwk(crop.totalCost),
                style: const TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w800,
                  color:      FarmioColors.danger,
                )),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _MetricCol(
              label: 'Area',
              value: Fmt.haShort(crop.totalArea),
            ),
            _MetricCol(
              label: 'Labour',
              value: Fmt.mwk(crop.labourCost),
            ),
            _MetricCol(
              label: 'Inputs',
              value: Fmt.mwk(crop.inputCost),
            ),
            _MetricCol(
              label: 'Cost/ha',
              value: Fmt.mwk(crop.costPerHectare),
              color: const Color(0xFF2563EB),
            ),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value:           pct,
              minHeight:       4,
              backgroundColor: FarmioColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  FarmioColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Field tab ─────────────────────────────────────────────────────────────────
class _FieldTab extends StatelessWidget {
  final List<FieldReport> data;
  const _FieldTab({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const _Empty(label: 'No field data yet');

    return Column(
      children: [
        _ReportHeader(
          title: 'Field cost analysis',
          sub:   'Total costs incurred per field',
        ),
        ...data.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child:   _FieldReportCard(field: f),
        )),
      ],
    );
  }
}

class _FieldReportCard extends StatelessWidget {
  final FieldReport field;
  const _FieldReportCard({required this.field});

  @override
  Widget build(BuildContext context) {
    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.map_outlined,
                size: 20, color: FarmioColors.primary),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(field.fieldName,
                    style: const TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w800,
                      color:      Colors.white,
                    )),
                Text(field.soilType,
                    style: const TextStyle(
                      fontSize: 11,
                      color:    Colors.white60,
                    )),
              ],
            )),
            Text(Fmt.mwk(field.totalCost),
                style: const TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w800,
                  color:      FarmioColors.danger,
                )),
          ]),
          const SizedBox(height: 10),
          if (field.crops.isNotEmpty)
            Wrap(
              spacing:    6,
              runSpacing: 4,
              children: field.crops
                  .map((c) => _Tag(label: c))
                  .toList(),
            ),
          const SizedBox(height: 10),
          Row(children: [
            _MetricCol(
              label: 'Total area',
              value: Fmt.haShort(field.totalArea),
            ),
            _MetricCol(
              label: 'Planted',
              value: Fmt.haShort(field.totalAreaPlanted),
            ),
            _MetricCol(
              label: 'Labour',
              value: Fmt.mwk(field.labourCost),
            ),
            _MetricCol(
              label: 'Cost/ha',
              value: Fmt.mwk(field.costPerHectare),
              color: const Color(0xFF2563EB),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Crop-field detail tab ─────────────────────────────────────────────────────
class _CropFieldTab extends StatelessWidget {
  final List<CropFieldDetail>  data;
  final String                 seasonFilter;
  final String                 fieldFilter;
  final List<String>           allSeasons;
  final List<String>           allFields;
  final void Function(String)  onSeasonChanged;
  final void Function(String)  onFieldChanged;

  const _CropFieldTab({
    required this.data,
    required this.seasonFilter,
    required this.fieldFilter,
    required this.allSeasons,
    required this.allFields,
    required this.onSeasonChanged,
    required this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = data.where((c) {
      if (seasonFilter != 'All' && c.season    != seasonFilter) return false;
      if (fieldFilter  != 'All' && c.fieldName != fieldFilter)  return false;
      return true;
    }).toList();

    final totalArea     = filtered.fold(0.0, (s, c) => s + c.areaPlanted);
    final totalLabour   = filtered.fold(0.0, (s, c) => s + c.labour);
    final totalInputs   = filtered.fold(0.0, (s, c) => s + c.inputs);
    final totalCost     = filtered.fold(0.0, (s, c) => s + c.totalCost);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReportHeader(
          title: 'Crop-field detail',
          sub:   'Every crop with full cost breakdown',
        ),

        // Filters
        Row(children: [
          Expanded(
            child: _DropdownFilter(
              value:    seasonFilter,
              items:    allSeasons,
              onChanged: onSeasonChanged,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _DropdownFilter(
              value:    fieldFilter,
              items:    allFields,
              onChanged: onFieldChanged,
            ),
          ),
        ]),
        const SizedBox(height: 10),

        // Totals bar
        if (filtered.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:        const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              _BannerItem(
                label: '${filtered.length} records',
                value: Fmt.haShort(totalArea),
                color: Colors.white,
              ),
              _BannerItem(
                label: 'Labour',
                value: Fmt.mwk(totalLabour),
                color: Colors.orangeAccent,
              ),
              _BannerItem(
                label: 'Inputs',
                value: Fmt.mwk(totalInputs),
                color: Colors.blueAccent,
              ),
              _BannerItem(
                label: 'Total',
                value: Fmt.mwk(totalCost),
                color: Colors.redAccent,
              ),
            ]),
          ),
        const SizedBox(height: 10),

        if (filtered.isEmpty)
          const _Empty(label: 'No records match these filters')
        else
          ...filtered.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child:   _CropFieldCard(item: c),
          )),
      ],
    );
  }
}

class _CropFieldCard extends StatelessWidget {
  final CropFieldDetail item;
  const _CropFieldCard({required this.item});

  Color get _statusColor {
    switch (item.status) {
      case 'Active':    return FarmioColors.primary;
      case 'Harvested': return const Color(0xFF2563EB);
      case 'Failed':    return FarmioColors.danger;
      default:          return FarmioColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.cropName} · ${item.variety}',
                    style: const TextStyle(
                      fontSize:   13,
                      fontWeight: FontWeight.w800,
                      color:      Colors.white,
                    )),
                Text('${item.fieldName} · ${item.season}',
                    style: const TextStyle(
                      fontSize: 11,
                      color:    Colors.white60,
                    )),
              ],
            )),
            _StatusBadge(
              label: item.status,
              color: _statusColor,
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _MetricCol(
              label: 'Area',
              value: Fmt.haShort(item.areaPlanted),
            ),
            _MetricCol(
              label: 'Labour',
              value: Fmt.mwk(item.labour),
            ),
            _MetricCol(
              label: 'Inputs',
              value: Fmt.mwk(item.inputs),
            ),
            _MetricCol(
              label: 'Cost/ha',
              value: Fmt.mwk(item.costPerHectare),
              color: const Color(0xFF2563EB),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Labour tab ────────────────────────────────────────────────────────────────
class _LabourTab extends StatelessWidget {
  final List<EmployeeReport> data;
  const _LabourTab({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const _Empty(label: 'No labour records yet');
    }

    final totalActivities = data.fold(0, (s, e) => s + e.activities);
    final totalDays       = data.fold(0.0, (s, e) => s + e.totalDays);
    final totalHours      = data.fold(0.0, (s, e) => s + e.totalHours);
    final totalEarned     = data.fold(0.0, (s, e) => s + e.totalEarned);

    return Column(
      children: [
        _ReportHeader(
          title: 'Labour summary',
          sub:   'Days, hours and earnings per employee',
        ),

        // Totals
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:        const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            _BannerItem(
              label: '${data.length} employees',
              value: '$totalActivities activities',
              color: Colors.white,
            ),
            _BannerItem(
              label: 'Days',
              value: totalDays.toStringAsFixed(1),
              color: Colors.blueAccent,
            ),
            _BannerItem(
              label: 'Hours',
              value: totalHours.toStringAsFixed(1),
              color: Colors.orangeAccent,
            ),
            _BannerItem(
              label: 'Total paid',
              value: Fmt.mwk(totalEarned),
              color: Colors.greenAccent,
            ),
          ]),
        ),
        const SizedBox(height: 10),

        ...data.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child:   _EmployeeCard(employee: e),
        )),
      ],
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final EmployeeReport employee;
  const _EmployeeCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    return _ReportCard(
      child: Row(children: [
        CircleAvatar(
          radius:          22,
          backgroundColor: FarmioColors.primary
              .withValues(alpha: 0.1),
          child: Text(employee.initials,
              style: const TextStyle(
                fontSize:   13,
                fontWeight: FontWeight.w800,
                color:      FarmioColors.primary,
              )),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(employee.name,
                style: const TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w800,
                  color:      Colors.white,
                )),
            Text(employee.role,
                style: const TextStyle(
                  fontSize: 11,
                  color:    Colors.white60,
                )),
            const SizedBox(height: 6),
            Row(children: [
              _MetricCol(
                label: 'Activities',
                value: '${employee.activities}',
              ),
              _MetricCol(
                label: 'Days',
                value: employee.totalDays.toStringAsFixed(1),
              ),
              _MetricCol(
                label: 'Hours',
                value: employee.totalHours.toStringAsFixed(1),
              ),
              _MetricCol(
                label: 'Earned',
                value: Fmt.mwk(employee.totalEarned),
                color: FarmioColors.primary,
              ),
            ]),
          ],
        )),
      ]),
    );
  }
}

// ── Inputs tab ────────────────────────────────────────────────────────────────
class _InputsTab extends StatelessWidget {
  final List<InputReport> data;
  const _InputsTab({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const _Empty(label: 'No input records yet');
    }

    final totalUsage = data.fold(0, (s, i) => s + i.usageCount);
    final totalCost  = data.fold(0.0, (s, i) => s + i.totalCost);

    return Column(
      children: [
        _ReportHeader(
          title: 'Input usage report',
          sub:   'Quantity and cost of every input used',
        ),

        // Totals
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:        const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            _BannerItem(
              label: '${data.length} inputs',
              value: '$totalUsage uses',
              color: Colors.white,
            ),
            _BannerItem(
              label: 'Total cost',
              value: Fmt.mwk(totalCost),
              color: Colors.redAccent,
            ),
          ]),
        ),
        const SizedBox(height: 10),

        ...data.map((i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child:   _InputCard(input: i, maxCost: data.first.totalCost),
        )),
      ],
    );
  }
}

class _InputCard extends StatelessWidget {
  final InputReport input;
  final double      maxCost;
  const _InputCard({required this.input, required this.maxCost});

  @override
  Widget build(BuildContext context) {
    final pct = maxCost > 0
        ? (input.totalCost / maxCost).clamp(0.0, 1.0)
        : 0.0;

    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.science_outlined,
                size: 18, color: FarmioColors.primary),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(input.inputName,
                    style: const TextStyle(
                      fontSize:   13,
                      fontWeight: FontWeight.w800,
                      color:      Colors.white,
                    )),
                Text(input.category,
                    style: const TextStyle(
                      fontSize: 11,
                      color:    Colors.white60,
                    )),
              ],
            )),
            Text(Fmt.mwk(input.totalCost),
                style: const TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w800,
                  color:      FarmioColors.danger,
                )),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _MetricCol(
              label: 'Total qty',
              value: '${input.totalQuantity.toStringAsFixed(1)}'
                  ' ${input.unit}',
            ),
            _MetricCol(
              label: 'Times used',
              value: '${input.usageCount}×',
            ),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value:           pct,
              minHeight:       4,
              backgroundColor: FarmioColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  FarmioColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Yields tab ────────────────────────────────────────────────────────────────
class _YieldsTab extends StatelessWidget {
  final YieldsReport data;
  const _YieldsTab({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ReportHeader(
          title: 'Yield analysis',
          sub:   'Aggregated yield by crop type',
        ),

        if (data.byType.isEmpty)
          const _Empty(label: 'No yield records yet')
        else ...[
          // By type
          ...data.byType.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child:   _YieldTypeCard(item: t),
          )),
          const SizedBox(height: 16),

          // Detail records
          const Text('Yield detail records',
              style: TextStyle(
                fontSize:   15,
                fontWeight: FontWeight.w800,
                color:      Colors.white,
              )),
          const SizedBox(height: 10),
          ...data.records.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child:   _YieldDetailCard(record: r),
          )),
        ],
      ],
    );
  }
}

class _YieldTypeCard extends StatelessWidget {
  final YieldByType item;
  const _YieldTypeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.agriculture_outlined,
                size: 20, color: FarmioColors.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(item.cropName,
                style: const TextStyle(
                  fontSize:   14,
                  fontWeight: FontWeight.w800,
                  color:      Colors.white,
                ))),
            Text(item.displayKg,
                style: const TextStyle(
                  fontSize:   14,
                  fontWeight: FontWeight.w800,
                  color:      FarmioColors.primary,
                )),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _MetricCol(
              label: 'Records',
              value: '${item.records}',
            ),
            _MetricCol(
              label: 'Area',
              value: Fmt.haShort(item.totalAreaPlanted),
            ),
            _MetricCol(
              label: 'Yield/ha',
              value: item.totalAreaPlanted > 0
                  ? '${item.yieldPerHa.round()} kg'
                  : '—',
              color: const Color(0xFF2563EB),
            ),
            _MetricCol(
              label: 'Cost/kg',
              value: item.totalYieldKg > 0
                  ? Fmt.mwk(item.costPerKg)
                  : '—',
              color: FarmioColors.danger,
            ),
          ]),
        ],
      ),
    );
  }
}

class _YieldDetailCard extends StatelessWidget {
  final YieldDetailRecord record;
  const _YieldDetailCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${record.cropName} · ${record.variety}',
                    style: const TextStyle(
                      fontSize:   13,
                      fontWeight: FontWeight.w800,
                      color:      Colors.white,
                    )),
                Text('${record.fieldName} · ${record.season}',
                    style: const TextStyle(
                      fontSize: 11,
                      color:    Colors.white60,
                    )),
              ],
            )),
            Text(record.displayKg,
                style: const TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w800,
                  color:      FarmioColors.primary,
                )),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _MetricCol(
              label: 'Area',
              value: Fmt.haShort(record.areaPlanted),
            ),
            _MetricCol(
              label: 'Total cost',
              value: Fmt.mwk(record.totalCost),
              color: FarmioColors.danger,
            ),
            _MetricCol(
              label: 'Cost/kg',
              value: record.totalYieldKg > 0
                  ? Fmt.mwk(record.costPerKg)
                  : '—',
            ),
            _MetricCol(
              label: 'Yield/ha',
              value: record.areaPlanted > 0
                  ? '${record.yieldPerHa.round()} kg'
                  : '—',
              color: const Color(0xFF2563EB),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────
class _ReportCard extends StatelessWidget {
  final Widget child;
  const _ReportCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(22),
        border:       Border.all(color: FarmioColors.softBorder),
        boxShadow: [
          BoxShadow(
            color: FarmioColors.slate900.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: FarmioColors.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  final String title, sub;
  const _ReportHeader({required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.w800,
                color:      FarmioColors.textPrimary,
              )),
          Text(sub,
              style: const TextStyle(
                fontSize: 12,
                color:    FarmioColors.textSecond,
              )),
        ],
      ),
    );
  }
}

class _MetricCol extends StatelessWidget {
  final String label, value;
  final Color  color;
  const _MetricCol({
    required this.label,
    required this.value,
    this.color = FarmioColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color:    FarmioColors.textSecond,
              )),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                fontSize:   12,
                fontWeight: FontWeight.w900,
                color:      color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color  color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize:   10,
            fontWeight: FontWeight.w700,
            color:      color,
          )),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        FarmioColors.primary
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: const TextStyle(
            fontSize:   10,
            fontWeight: FontWeight.w600,
            color:      FarmioColors.primary,
          )),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final String              value;
  final List<String>        items;
  final void Function(String) onChanged;

  const _DropdownFilter({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color:        FarmioColors.slate50,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: FarmioColors.softBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value:      value,
          isExpanded: true,
          style: const TextStyle(
            fontSize:   12,
            color:      FarmioColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Colors.white,
          iconEnabledColor: FarmioColors.textSecond,
          items: items.map((i) => DropdownMenuItem(
            value: i,
            child: Text(i, overflow: TextOverflow.ellipsis),
          )).toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String label;
  const _Empty({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(Icons.query_stats_rounded,
                color: FarmioColors.primary, size: 48),
            const SizedBox(height: 16),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize:   15,
                  fontWeight: FontWeight.w700,
                  color:      FarmioColors.textPrimary,
                )),
          ],
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding:          const EdgeInsets.all(16),
      itemCount:        5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => Container(
        height:     i == 0 ? 60 : 100,
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: FarmioColors.softBorder),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: FarmioColors.danger, size: 48),
            const SizedBox(height: 12),
            const Text('Could not load report',
                style: TextStyle(
                  fontSize:   16,
                  fontWeight: FontWeight.w700,
                  color:      FarmioColors.textPrimary,
                )),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color:    FarmioColors.textMuted,
                )),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon:      const Icon(Icons.refresh),
              label:     const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
