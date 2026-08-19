import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../models/farm_document.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'documents_provider.dart';

const _maxUploadBytes = 10 * 1024 * 1024;

class DocumentFormScreen extends ConsumerStatefulWidget {
  const DocumentFormScreen({super.key});

  @override
  ConsumerState<DocumentFormScreen> createState() => _DocumentFormScreenState();
}

class _DocumentFormScreenState extends ConsumerState<DocumentFormScreen> {
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _type = documentTypes.first;
  XFile? _picked;
  bool _saving = false;
  bool _picking = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _picking = true);
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );
      if (file != null) {
        setState(() {
          _picked = file;
          if (_nameCtrl.text.trim().isEmpty) {
            _nameCtrl.text = file.name;
          }
        });
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _save() async {
    if (_picked == null) {
      setState(() => _error = 'Add a photo first.');
      return;
    }
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Name is required.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final bytes = await _picked!.readAsBytes();
      if (bytes.length > _maxUploadBytes) {
        setState(() {
          _error = 'File is too large. Documents must be 10 MB or smaller.';
          _saving = false;
        });
        return;
      }

      await ref.read(documentsRepositoryProvider).uploadDocument(
            name: _nameCtrl.text.trim(),
            type: _type,
            bytes: bytes,
            extension: _extensionFor(_picked!.name),
            notes: _notesCtrl.text.trim(),
          );
      ref.invalidate(documentsProvider);
      if (mounted) context.pop();
    } catch (_) {
      setState(() => _error = 'Could not upload document.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _extensionFor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.webp')) return 'webp';
    return 'jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Add evidence',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _picking ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _picking
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            if (_picked != null) ...[
              const SizedBox(height: 12),
              Text('Selected: ${_picked!.name}',
                  style: const TextStyle(
                      fontSize: 12, color: FarmioColors.textMuted)),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: documentTypes
                  .map((t) => DropdownMenuItem(
                      value: t, child: Text(documentTypeLabel(t))))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
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
                    : const Text('Upload'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
