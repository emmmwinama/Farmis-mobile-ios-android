import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/filters/report_record_filters.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'records_provider.dart';
import '../../core/theme/app_spacing.dart';

class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({super.key});

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  String _selectedPack = 'loan';
  ReportRecordFilters _filters = const ReportRecordFilters();
  final Set<String> _sections = {
    'fields',
    'activities',
    'finance',
    'payroll',
    'livestock',
  };

  @override
  Widget build(BuildContext context) {
    final selected = _packs.firstWhere((pack) => pack.key == _selectedPack);
    final records = ref.watch(recordsDataProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.textPrimary,
        shape: const Border(),
        title: const Text('Records'),
      ),
      body: records.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl2),
            child: FarmioErrorBanner(message: 'Could not load your farm records: $e'),
          ),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg2, AppSpacing.lg2, AppSpacing.lg2, 96),
          children: [
            _RecordsHero(pack: selected),
            ReportRecordFilterBar(
              value: _filters,
              crops: data.crops,
              seasons: data.seasons,
              fields: data.fieldNames,
              onChanged: (filters) => setState(() => _filters = filters),
            ),
            const SizedBox(height: 18),
            const _SectionHeader(
              eyebrow: 'Document type',
              title: 'Choose an evidence pack',
              subtitle: 'Records are export-ready bundles for people outside the farm.',
            ),
            const SizedBox(height: 12),
            ..._packs.map((pack) => _RecordPackTile(
                  pack: pack,
                  selected: _selectedPack == pack.key,
                  onTap: () => setState(() => _selectedPack = pack.key),
                )),
            const SizedBox(height: 18),
            const _SectionHeader(
              eyebrow: 'Contents',
              title: 'Sections to include',
              subtitle: 'Turn sections on or off before generating the final file.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _exportSections
                  .map((section) => _SectionToggle(
                        section: section,
                        selected: _sections.contains(section.key),
                        onTap: () => setState(() {
                          if (_sections.contains(section.key)) {
                            _sections.remove(section.key);
                          } else {
                            _sections.add(section.key);
                          }
                        }),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 22),
            _ExportPanel(
              pack: _selectedPack,
              sections: _sections,
              filters: _filters,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordsHero extends StatelessWidget {
  final _Pack pack;

  const _RecordsHero({required this.pack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.softBorder),
        boxShadow: [
          BoxShadow(
            color: FarmioColors.slate900.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: pack.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: pack.color.withValues(alpha: 0.14),
                  ),
                ),
                child: Icon(pack.icon, color: pack.color),
              ),
              const Spacer(),
              const _DarkPill(label: 'Export builder'),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Farm evidence, ready to share.',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 25,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            pack.description,
            style: TextStyle(
              color: context.colors.textSecond,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            color: FarmioColors.info,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            color: context.colors.textSecond,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _Pack {
  final String key;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _Pack({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _ExportSection {
  final String key;
  final String label;
  final String description;
  final IconData icon;

  const _ExportSection({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
  });
}

const _packs = [
  _Pack(
    key: 'loan',
    title: 'Loan readiness',
    description:
        'Cashflow, production history, payroll capacity and repayment evidence.',
    icon: Icons.account_balance_outlined,
    color: FarmioColors.info,
  ),
  _Pack(
    key: 'buyer',
    title: 'Buyer records',
    description:
        'Traceability, activity proof, crop volumes, sales history and quality notes.',
    icon: Icons.handshake_outlined,
    color: FarmioColors.primary,
  ),
  _Pack(
    key: 'audit',
    title: 'Audit file',
    description:
        'Field, input, activity, finance, employee and livestock evidence.',
    icon: Icons.verified_outlined,
    color: FarmioColors.purple,
  ),
  _Pack(
    key: 'insurance',
    title: 'Insurance file',
    description:
        'Acreage, crop status, activities, harvest proof, livestock and loss evidence.',
    icon: Icons.health_and_safety_outlined,
    color: FarmioColors.warning,
  ),
];

const _exportSections = [
  _ExportSection(
    key: 'fields',
    label: 'Fields and crops',
    description: 'Land, soil, crop status and harvest timing.',
    icon: Icons.map_outlined,
  ),
  _ExportSection(
    key: 'activities',
    label: 'Activities and inputs',
    description: 'Field work, input usage, labour and other costs.',
    icon: Icons.assignment_outlined,
  ),
  _ExportSection(
    key: 'finance',
    label: 'Finance records',
    description: 'Income, expenses, fields, crops and seasons.',
    icon: Icons.account_balance_wallet_outlined,
  ),
  _ExportSection(
    key: 'payroll',
    label: 'Payroll capacity',
    description: 'Roles, pay rates, contacts and active status.',
    icon: Icons.people_alt_outlined,
  ),
  _ExportSection(
    key: 'livestock',
    label: 'Livestock summary',
    description: 'Animal records when mobile endpoints are enabled.',
    icon: Icons.pets_outlined,
  ),
];

class _RecordPackTile extends StatelessWidget {
  final _Pack pack;
  final bool selected;
  final VoidCallback onTap;

  const _RecordPackTile({
    required this.pack,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? pack.color
                    : context.colors.softBorder,
                width: selected ? 1.8 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: FarmioColors.slate900.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: pack.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(pack.icon, color: pack.color, size: 21),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pack.title,
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          )),
                      const SizedBox(height: 4),
                      Text(pack.description,
                          style: TextStyle(
                            color: context.colors.textSecond,
                            fontSize: 12,
                            height: 1.28,
                          )),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? pack.color : FarmioColors.slate300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionToggle extends StatelessWidget {
  final _ExportSection section;
  final bool selected;
  final VoidCallback onTap;

  const _SectionToggle({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 46) / 2,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minHeight: 132),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: selected
                  ? FarmioColors.primary.withValues(alpha: 0.14)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? FarmioColors.info
                    : context.colors.softBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(section.icon,
                        color: selected
                            ? FarmioColors.info
                            : context.colors.textMuted,
                        size: 20),
                    const Spacer(),
                    Icon(
                      selected
                          ? Icons.check_circle
                          : Icons.add_circle_outline_rounded,
                      color: selected
                          ? FarmioColors.info
                          : FarmioColors.slate300,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(section.label,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    )),
                const SizedBox(height: 4),
                Text(section.description,
                    style: TextStyle(
                      color: context.colors.textSecond,
                      fontSize: 11,
                      height: 1.25,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExportPanel extends ConsumerStatefulWidget {
  final String pack;
  final Set<String> sections;
  final ReportRecordFilters filters;

  const _ExportPanel({
    required this.pack,
    required this.sections,
    required this.filters,
  });

  @override
  ConsumerState<_ExportPanel> createState() => _ExportPanelState();
}

class _ExportPanelState extends ConsumerState<_ExportPanel> {
  bool _exporting = false;
  String? _error;

  Future<void> _export(bool asPdf) async {
    if (widget.sections.isEmpty) {
      setState(() => _error = 'Select at least one section to include.');
      return;
    }
    setState(() { _exporting = true; _error = null; });
    try {
      final repo = ref.read(recordsRepositoryProvider);
      final path = asPdf
          ? await repo.exportPdf(pack: widget.pack, filters: widget.filters, sections: widget.sections)
          : await repo.exportCsv(pack: widget.pack, filters: widget.filters, sections: widget.sections);
      await Share.shareXFiles([XFile(path)], text: 'Farmio ${widget.pack} records');
    } catch (e) {
      setState(() => _error = 'Could not generate that file. Try again.');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generate document',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Built on-device from ${widget.filters.summary}. Nothing leaves this phone until you share it.',
            style: TextStyle(
              color: context.colors.textSecond,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            FarmioErrorBanner(message: _error!),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: _exporting
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('PDF'),
                  onPressed: _exporting ? null : () => _export(true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.table_chart_outlined),
                  label: const Text('CSV'),
                  onPressed: _exporting ? null : () => _export(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DarkPill extends StatelessWidget {
  final String label;

  const _DarkPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: FarmioColors.primaryBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.colors.softBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: FarmioColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
