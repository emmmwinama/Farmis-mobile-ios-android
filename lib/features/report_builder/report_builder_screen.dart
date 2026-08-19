import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../models/report_builder.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'report_builder_provider.dart';

String _sectionLabel(String key) {
  switch (key) {
    case 'season':
      return 'Season summary';
    case 'crop':
      return 'Crop performance';
    case 'field':
      return 'Field performance';
    case 'cropField':
      return 'Crop x field detail';
    case 'labour':
      return 'Labour';
    case 'inputs':
      return 'Inputs';
    case 'yields':
      return 'Yields';
    default:
      return key;
  }
}

class ReportBuilderScreen extends ConsumerStatefulWidget {
  const ReportBuilderScreen({super.key});

  @override
  ConsumerState<ReportBuilderScreen> createState() =>
      _ReportBuilderScreenState();
}

class _ReportBuilderScreenState extends ConsumerState<ReportBuilderScreen> {
  final Set<String> _selected = {...reportBuilderSections};
  bool _exporting = false;
  String? _error;

  Future<void> _export() async {
    if (_selected.isEmpty) {
      setState(() => _error = 'Select at least one report section.');
      return;
    }
    setState(() {
      _exporting = true;
      _error = null;
    });

    try {
      final path = await ref
          .read(reportBuilderRepositoryProvider)
          .exportPdf(_selected.toList());
      await Share.shareXFiles([XFile(path)], text: 'Farmio report export');
    } catch (e) {
      setState(() => _error = 'Could not export the report. Try again.');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(reportBuilderProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Report builder',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(reportBuilderProvider),
        ),
        data: (report) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            const Text('Select sections to export',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: FarmioColors.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: reportBuilderSections
                  .map((key) => FilterChip(
                        label: Text(_sectionLabel(key)),
                        selected: _selected.contains(key),
                        onSelected: (v) => setState(() {
                          if (v) {
                            _selected.add(key);
                          } else {
                            _selected.remove(key);
                          }
                        }),
                      ))
                  .toList(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              FarmioErrorBanner(message: _error!),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _exporting ? null : _export,
                icon: _exporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined),
                label: Text(_exporting ? 'Preparing PDF…' : 'Export PDF'),
              ),
            ),
            const SizedBox(height: 24),
            if (report.cropProfitability.isNotEmpty) ...[
              const Text('Crop profitability',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: FarmioColors.textPrimary)),
              const SizedBox(height: 8),
              ...report.cropProfitability.map((row) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: FarmioColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: FarmioColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${row.cropName} · ${row.variety}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800)),
                              Text('${row.fieldName} · ${row.season}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: FarmioColors.textMuted)),
                            ],
                          ),
                        ),
                        Text(Fmt.mwk(row.netProfit),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: row.netProfit >= 0
                                  ? FarmioColors.success
                                  : FarmioColors.danger,
                            )),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load report builder',
                style: TextStyle(
                    color: FarmioColors.textPrimary,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: FarmioColors.textMuted)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
