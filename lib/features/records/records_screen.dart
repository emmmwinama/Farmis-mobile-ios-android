import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/filters/report_record_filters.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
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

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.textPrimary,
        shape: const Border(),
        title: const Text('Records'),
        actions: [
          IconButton(
            tooltip: 'Preview',
            icon: const Icon(Icons.visibility_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
        children: [
          _RecordsHero(pack: selected),
          ReportRecordFilterBar(
            value: _filters,
            crops: _recordCrops,
            seasons: _recordSeasons,
            fields: _recordFields,
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
            sections: _sections.toList(),
            filters: _filters,
          ),
        ],
      ),
    );
  }
}

const _recordCrops = [
  'Maize',
  'Soya',
  'Groundnuts',
  'Tobacco',
  'Beans',
];

const _recordSeasons = [
  '2026',
  '2025/2026',
  '2025',
  '2024/2025',
];

const _recordFields = [
  'North field',
  'River block',
  'Demo plot',
  'Home field',
];

class _RecordsHero extends StatelessWidget {
  final _Pack pack;

  const _RecordsHero({required this.pack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: FarmioColors.softBorder),
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
          const Text(
            'Farm evidence, ready to share.',
            style: TextStyle(
              color: FarmioColors.textPrimary,
              fontSize: 25,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            pack.description,
            style: TextStyle(
              color: FarmioColors.textSecond,
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
          style: const TextStyle(
            color: FarmioColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: FarmioColors.textSecond,
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? pack.color
                    : FarmioColors.softBorder,
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
                          style: const TextStyle(
                            color: FarmioColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          )),
                      const SizedBox(height: 4),
                      Text(pack.description,
                          style: const TextStyle(
                            color: FarmioColors.textSecond,
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected
                  ? FarmioColors.primary.withValues(alpha: 0.14)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? FarmioColors.info
                    : FarmioColors.softBorder,
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
                            : FarmioColors.textMuted,
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
                    style: const TextStyle(
                      color: FarmioColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    )),
                const SizedBox(height: 4),
                Text(section.description,
                    style: const TextStyle(
                      color: FarmioColors.textSecond,
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

class _ExportPanel extends StatelessWidget {
  final String pack;
  final List<String> sections;
  final ReportRecordFilters filters;

  const _ExportPanel({
    required this.pack,
    required this.sections,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    final params = [
      'type=$pack',
      ...sections.map((section) => 'section=$section'),
      ...filters.toQuery().entries.map((entry) =>
          '${entry.key}=${Uri.encodeComponent('${entry.value}')}'),
    ].join('&');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FarmioColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generate document',
            style: TextStyle(
              color: FarmioColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Direct mobile download needs the web export route to accept mobile JWT authentication.',
            style: TextStyle(
              color: FarmioColors.textSecond,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          SelectableText(
            '/api/export/records?$params&format=pdf',
            style: const TextStyle(
              color: FarmioColors.info,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('PDF'),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.table_chart_outlined),
                  label: const Text('CSV'),
                  onPressed: () {},
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: FarmioColors.primaryBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: FarmioColors.softBorder),
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
