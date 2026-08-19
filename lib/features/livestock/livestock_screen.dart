import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/livestock.dart';
import '../../shared/filters/entity_filter_bar.dart';
import 'livestock_provider.dart';

class LivestockScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const LivestockScreen({super.key, this.embedded = false});

  @override
  ConsumerState<LivestockScreen> createState() => _LivestockScreenState();
}

class _LivestockScreenState extends ConsumerState<LivestockScreen> {
  String _typeFilter = 'All';
  String _sexFilter = 'All';
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final livestock = ref.watch(livestockProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: widget.embedded
          ? null
          : AppBar(
              title: const Text('Livestock',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.invalidate(livestockProvider),
                ),
              ],
            ),
      floatingActionButton: livestock.maybeWhen(
        data: (_) => FloatingActionButton.extended(
          onPressed: () => context.push('/animals/new'),
          icon: const Icon(Icons.add),
          label: const Text('Add animal'),
        ),
        orElse: () => null,
      ),
      body: livestock.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(livestockProvider),
        ),
        data: (data) {
          if (data.animals.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No animals registered yet.',
                  style: TextStyle(color: FarmioColors.textMuted),
                ),
              ),
            );
          }

          final types = {
            ...data.animals.map((a) => a.livestockTypeName).whereType<String>(),
          }.toList();
          final sexes = {...data.animals.map((a) => a.sex)}.toList();
          final statuses = {...data.animals.map((a) => a.status)}.toList();

          final filtered = data.animals.where((a) {
            if (_typeFilter != 'All' && a.livestockTypeName != _typeFilter) {
              return false;
            }
            if (_sexFilter != 'All' && a.sex != _sexFilter) return false;
            if (_statusFilter != 'All' && a.status != _statusFilter) {
              return false;
            }
            return true;
          }).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(livestockProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              itemCount: (filtered.isEmpty ? 1 : filtered.length) + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return EntityFilterBar(
                    dimensions: [
                      FilterDimension(
                        label: 'Type',
                        icon: Icons.pets_outlined,
                        value: _typeFilter,
                        options: types,
                        onSelected: (v) => setState(() => _typeFilter = v),
                      ),
                      FilterDimension(
                        label: 'Sex',
                        icon: Icons.wc_outlined,
                        value: _sexFilter,
                        options: sexes,
                        onSelected: (v) => setState(() => _sexFilter = v),
                      ),
                      FilterDimension(
                        label: 'Status',
                        icon: Icons.info_outline_rounded,
                        value: _statusFilter,
                        options: statuses,
                        onSelected: (v) => setState(() => _statusFilter = v),
                      ),
                    ],
                  );
                }
                if (filtered.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No animals match this filter',
                        style: TextStyle(color: FarmioColors.textMuted),
                      ),
                    ),
                  );
                }
                final animal = filtered[index - 1];
                return _AnimalCard(
                  animal: animal,
                  onTap: () => context.push('/animals/${animal.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AnimalCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback onTap;
  const _AnimalCard({required this.animal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: FarmioColors.successBg,
              child: const Icon(Icons.pets_outlined,
                  color: FarmioColors.success),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(animal.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  Text(
                    '${animal.livestockTypeName ?? 'Livestock'} · ${animal.sex}${animal.breed != null ? ' · ${animal.breed}' : ''}',
                    style: const TextStyle(
                        fontSize: 12, color: FarmioColors.textMuted),
                  ),
                ],
              ),
            ),
            if (animal.status != 'Active')
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: FarmioColors.slate100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(animal.status,
                    style: const TextStyle(
                        fontSize: 11, color: FarmioColors.textMuted)),
              ),
            const Icon(Icons.chevron_right_rounded,
                color: FarmioColors.textMuted),
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
            const Text('Could not load livestock',
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
