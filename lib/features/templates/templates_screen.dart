import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/seasonal_template.dart';
import '../crops/crops_provider.dart';
import 'templates_provider.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final templates = ref.watch(templatesProvider);
    final crops = ref.watch(allCropsProvider);

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Seasonal Templates',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(templatesProvider),
          ),
        ],
      ),
      body: templates.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(templatesProvider),
        ),
        data: (data) {
          final activeCropTypes = crops.valueOrNull
                  ?.where((c) => c.status == 'Active')
                  .map((c) => c.cropTypeName.toLowerCase())
                  .toSet() ??
              <String>{};
          final visible = _showAll
              ? data
              : data
                  .where((t) =>
                      activeCropTypes.contains(t.crop.toLowerCase()))
                  .toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(templatesProvider),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const _IntroCard(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _showAll
                            ? 'Showing all templates'
                            : 'Showing templates for your active crops',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: FarmioColors.textMuted,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _showAll = !_showAll),
                      icon: Icon(
                        _showAll
                            ? Icons.filter_alt_outlined
                            : Icons.filter_alt_off_outlined,
                        size: 16,
                      ),
                      label: Text(_showAll
                          ? 'Active crops only'
                          : 'Show all (incl. inactive)'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (visible.isEmpty)
                  _EmptyFilteredState(
                    onShowAll: () => setState(() => _showAll = true),
                  )
                else
                  ...visible.map(_TemplateCard.new),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyFilteredState extends StatelessWidget {
  final VoidCallback onShowAll;
  const _EmptyFilteredState({required this.onShowAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FarmioColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.eco_outlined,
              size: 40, color: FarmioColors.textMuted),
          const SizedBox(height: 10),
          const Text(
            'No templates match your active crops yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: FarmioColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onShowAll,
            child: const Text('Show all templates'),
          ),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FarmioColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guided seasonal records',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Use the same crop workflows from the web dashboard to plan activities, payroll and sales evidence before the season gets busy.',
            style: TextStyle(color: Colors.white70, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatefulWidget {
  final SeasonalTemplate template;

  const _TemplateCard(this.template);

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final template = widget.template;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FarmioColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: FarmioColors.primaryBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.eco_rounded,
                        color: FarmioColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(template.name,
                            style: const TextStyle(
                              color: FarmioColors.textPrimary,
                              fontWeight: FontWeight.w900,
                            )),
                        Text('${template.crop} - ${template.season}',
                            style: const TextStyle(
                              color: FarmioColors.textMuted,
                              fontSize: 12,
                            )),
                      ],
                    ),
                  ),
                  Icon(_expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded),
                ],
              ),
              const SizedBox(height: 12),
              Text(template.description,
                  style: const TextStyle(
                    color: FarmioColors.textSecond,
                    height: 1.35,
                  )),
              if (_expanded) ...[
                const SizedBox(height: 16),
                _Section(
                  title: 'Activity plan',
                  children: template.activities
                      .map((a) => _DetailLine(
                            title: a.activityType,
                            body: '${a.timing}: ${a.notes}',
                          ))
                      .toList(),
                ),
                _Section(
                  title: 'Payroll roles',
                  children: template.payroll
                      .map((p) => _DetailLine(
                            title: p.role,
                            body: '${p.payRateUnit}: ${p.notes}',
                          ))
                      .toList(),
                ),
                _Section(
                  title: 'Evidence packs',
                  children: template.recordPackHints
                      .map((hint) => _DetailLine(title: hint, body: ''))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                color: FarmioColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              )),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String title;
  final String body;

  const _DetailLine({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FarmioColors.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FarmioColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                color: FarmioColors.textPrimary,
                fontWeight: FontWeight.w800,
              )),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(body,
                style: const TextStyle(
                  color: FarmioColors.textMuted,
                  fontSize: 12,
                  height: 1.35,
                )),
          ],
        ],
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
            const Text('Could not load templates',
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
