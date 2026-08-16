import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../models/farm_document.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import 'documents_provider.dart';

const _maxUploadBytes = 10 * 1024 * 1024;

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documents = ref.watch(documentsProvider);

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Documents',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(documentsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const _UploadForm(),
        ),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Add evidence'),
      ),
      body: documents.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(documentsProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No evidence uploaded yet. Add receipts, field photos, certificates and other documents.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: FarmioColors.textMuted),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(documentsProvider),
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: list.length,
              itemBuilder: (context, index) => _DocumentCard(doc: list[index]),
            ),
          );
        },
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final FarmDocument doc;
  const _DocumentCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FarmioColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FarmioColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _Thumbnail(doc: doc)),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                Text(documentTypeLabel(doc.type),
                    style: const TextStyle(
                        fontSize: 11, color: FarmioColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final FarmDocument doc;
  const _Thumbnail({required this.doc});

  @override
  Widget build(BuildContext context) {
    if (!doc.isImage) {
      return Container(
        color: FarmioColors.slate100,
        alignment: Alignment.center,
        child: const Icon(Icons.insert_drive_file_outlined,
            size: 36, color: FarmioColors.textMuted),
      );
    }

    return Image.file(
      File(doc.url),
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: FarmioColors.slate100,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined,
            size: 36, color: FarmioColors.textMuted),
      ),
    );
  }
}

class _UploadForm extends ConsumerStatefulWidget {
  const _UploadForm();

  @override
  ConsumerState<_UploadForm> createState() => _UploadFormState();
}

class _UploadFormState extends ConsumerState<_UploadForm> {
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
      if (mounted) Navigator.pop(context);
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Add evidence',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
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
                  decoration:
                      const InputDecoration(labelText: 'Notes (optional)'),
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
            const Text('Could not load documents',
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
