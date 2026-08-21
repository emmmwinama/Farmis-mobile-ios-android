import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/farm_document.dart';
import '../../shared/filters/entity_filter_bar.dart';
import 'documents_provider.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  String _typeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final documents = ref.watch(documentsProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
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
        onPressed: () => context.push('/documents/new'),
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

          final types = {...list.map((d) => documentTypeLabel(d.type))}
              .toList();
          final filtered = _typeFilter == 'All'
              ? list
              : list
                  .where((d) => documentTypeLabel(d.type) == _typeFilter)
                  .toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(documentsProvider),
            child: Column(
              children: [
                EntityFilterBar(
                  dimensions: [
                    FilterDimension(
                      label: 'Type',
                      icon: Icons.description_outlined,
                      value: _typeFilter,
                      options: types,
                      onSelected: (v) => setState(() => _typeFilter = v),
                    ),
                  ],
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'No documents match this filter',
                            style: TextStyle(color: FarmioColors.textMuted),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => _DocumentCard(
                            doc: filtered[index],
                            onTap: () => _openDocument(context, ref, filtered[index]),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openDocument(
      BuildContext context, WidgetRef ref, FarmDocument doc) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DocumentSheet(doc: doc),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final FarmDocument doc;
  final VoidCallback onTap;
  const _DocumentCard({required this.doc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
      ),
    );
  }
}

class _DocumentSheet extends ConsumerWidget {
  final FarmDocument doc;
  const _DocumentSheet({required this.doc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(height: 220, child: _Thumbnail(doc: doc)),
              ),
              const SizedBox(height: 16),
              Text(doc.name,
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w900, color: context.colors.textPrimary)),
              const SizedBox(height: 4),
              Text(documentTypeLabel(doc.type),
                  style: TextStyle(fontSize: 13, color: context.colors.textMuted)),
              if (doc.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                Text(doc.notes!,
                    style: TextStyle(fontSize: 13, color: context.colors.textSecond)),
              ],
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline, color: FarmioColors.danger),
                  label: const Text('Delete', style: TextStyle(color: FarmioColors.danger)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: FarmioColors.danger),
                  ),
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete document'),
        content: Text('Delete "${doc.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: FarmioColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(documentsRepositoryProvider).deleteDocument(doc.id);
      ref.invalidate(documentsProvider);
      if (context.mounted) Navigator.pop(context);
    }
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
