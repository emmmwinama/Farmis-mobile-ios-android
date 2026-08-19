import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/livestock.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'livestock_provider.dart';

class AnimalFormScreen extends ConsumerWidget {
  const AnimalFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livestock = ref.watch(livestockProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Add animal',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: livestock.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load livestock types: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: FarmioColors.textMuted)),
          ),
        ),
        data: (data) => _AnimalFormBody(types: data.types),
      ),
    );
  }
}

class _AnimalFormBody extends ConsumerStatefulWidget {
  final List<LivestockType> types;
  const _AnimalFormBody({required this.types});

  @override
  ConsumerState<_AnimalFormBody> createState() => _AnimalFormBodyState();
}

class _AnimalFormBodyState extends ConsumerState<_AnimalFormBody> {
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
                  : const Text('Save animal'),
            ),
          ),
        ],
      ),
    );
  }
}
