import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/livestock.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'livestock_provider.dart';

class AnimalFormScreen extends ConsumerWidget {
  final Animal? existing;
  const AnimalFormScreen({super.key, this.existing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livestock = ref.watch(livestockProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(existing != null ? 'Edit animal' : 'Add animal',
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: livestock.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load livestock types: $error',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.textMuted)),
          ),
        ),
        data: (data) => _AnimalFormBody(types: data.types, existing: existing),
      ),
    );
  }
}

class _AnimalFormBody extends ConsumerStatefulWidget {
  final List<LivestockType> types;
  final Animal? existing;
  const _AnimalFormBody({required this.types, this.existing});

  @override
  ConsumerState<_AnimalFormBody> createState() => _AnimalFormBodyState();
}

class _AnimalFormBodyState extends ConsumerState<_AnimalFormBody> {
  late final _tagCtrl = TextEditingController(text: widget.existing?.tag);
  late final _nameCtrl = TextEditingController(text: widget.existing?.name);
  late final _breedCtrl = TextEditingController(text: widget.existing?.breed);
  String? _typeId;
  late String _sex = widget.existing?.sex ?? 'Unknown';
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.existing != null;

  final _sexes = const ['Unknown', 'Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _typeId = widget.existing?.livestockTypeId ??
        (widget.types.isNotEmpty ? widget.types.first.id : null);
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

    final data = {
      'livestockTypeId': _typeId,
      'tag': _tagCtrl.text.trim().isEmpty ? null : _tagCtrl.text.trim(),
      'name': _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      'sex': _sex,
      'breed':
          _breedCtrl.text.trim().isEmpty ? null : _breedCtrl.text.trim(),
    };

    try {
      final existing = widget.existing;
      if (existing != null) {
        await ref.read(livestockRepositoryProvider).updateAnimal(existing.id, data);
        ref.invalidate(animalDetailProvider(existing.id));
      } else {
        await ref.read(livestockRepositoryProvider).createAnimal(data);
      }
      ref.invalidate(livestockProvider);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = 'Could not save animal: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _typeId,
            decoration: const InputDecoration(labelText: 'Type'),
            items: widget.types
                .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
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
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _sex = v ?? _sex),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _breedCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Breed (optional)'),
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
                  : Text(_isEditing ? 'Save changes' : 'Save animal'),
            ),
          ),
        ],
      ),
    );
  }
}
