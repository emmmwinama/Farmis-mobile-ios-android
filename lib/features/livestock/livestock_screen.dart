import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/livestock.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'livestock_detail_screen.dart';
import 'livestock_provider.dart';

class LivestockScreen extends ConsumerWidget {
  const LivestockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livestock = ref.watch(livestockProvider);

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
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
        data: (data) => FloatingActionButton.extended(
          onPressed: () => _showAddAnimal(context, ref, data.types),
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
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(livestockProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              itemCount: data.animals.length,
              itemBuilder: (context, index) {
                final animal = data.animals[index];
                return _AnimalCard(
                  animal: animal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AnimalDetailScreen(animalId: animal.id),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddAnimal(
    BuildContext context,
    WidgetRef ref,
    List<LivestockType> types,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddAnimalForm(types: types),
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
          color: FarmioColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FarmioColors.border),
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

class _AddAnimalForm extends ConsumerStatefulWidget {
  final List<LivestockType> types;
  const _AddAnimalForm({required this.types});

  @override
  ConsumerState<_AddAnimalForm> createState() => _AddAnimalFormState();
}

class _AddAnimalFormState extends ConsumerState<_AddAnimalForm> {
  final _tagCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  String? _typeId;
  String _sex = 'Unknown';
  bool _saving = false;
  String? _error;

  final _sexes = const ['Unknown', 'Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _typeId = widget.types.isNotEmpty ? widget.types.first.id : null;
  }

  @override
  void dispose() {
    _tagCtrl.dispose();
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_typeId == null) {
      setState(() => _error = 'Select a livestock type.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref.read(livestockRepositoryProvider).createAnimal({
        'livestockTypeId': _typeId,
        'tag': _tagCtrl.text.trim().isEmpty ? null : _tagCtrl.text.trim(),
        'name': _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
        'sex': _sex,
        'breed':
            _breedCtrl.text.trim().isEmpty ? null : _breedCtrl.text.trim(),
      });
      ref.invalidate(livestockProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Could not save animal.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add animal',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _typeId,
                decoration: const InputDecoration(labelText: 'Type'),
                items: widget.types
                    .map((t) =>
                        DropdownMenuItem(value: t.id, child: Text(t.name)))
                    .toList(),
                onChanged: (v) => setState(() => _typeId = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Name (optional)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _tagCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Tag (optional)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _sex,
                      decoration: const InputDecoration(labelText: 'Sex'),
                      items: _sexes
                          .map((s) =>
                              DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _sex = v ?? _sex),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _breedCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Breed (optional)'),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                FarmioErrorBanner(message: _error!),
              ],
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Save animal'),
                ),
              ),
            ],
          ),
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
