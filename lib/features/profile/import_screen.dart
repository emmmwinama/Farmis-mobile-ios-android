import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/db/database_provider.dart';
import '../../core/migration/export_service.dart';
import '../../core/migration/import_service.dart';
import '../../core/theme/app_theme.dart';
import 'farm_profile_provider.dart';

/// Import brings a `mobile-export.json` into this install's database —
/// either the one-time bridge from the old backend-connected app (see
/// `Farmis/scripts/export-mobile-data.ts`), or a file this same app
/// exported earlier (below), letting a farmer move data between devices
/// or keep an off-device backup. Both directions use the same JSON shape,
/// so anything this screen exports can be re-imported unchanged.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  bool _importing = false;
  bool _exporting = false;
  String? _error;
  String? _exportError;
  ImportSummary? _summary;

  Future<void> _pickAndImport() async {
    setState(() {
      _importing = true;
      _error = null;
      _summary = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        setState(() => _importing = false);
        return;
      }

      final picked = result.files.single;
      final bytes = picked.bytes ??
          (picked.path != null ? await File(picked.path!).readAsBytes() : null);
      if (bytes == null) {
        setState(() => _error = 'Could not read the selected file.');
        return;
      }

      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final service = ImportService(ref.read(databaseProvider));
      final summary = await service.importFromJson(json);
      ref.invalidate(farmProfileProvider);
      setState(() => _summary = summary);
    } catch (e) {
      setState(() => _error =
          'Could not import that file. Check its format and try again.\n$e');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _exportAndShare() async {
    setState(() {
      _exporting = true;
      _exportError = null;
    });
    try {
      final service = ExportService(ref.read(databaseProvider));
      final json = await service.exportToJson();
      final dir = await getApplicationDocumentsDirectory();
      final date = DateTime.now().toIso8601String().split('T').first;
      final file = File(p.join(dir.path, 'mobile-export-$date.json'));
      await file.writeAsString(jsonEncode(json));
      await Share.shareXFiles([XFile(file.path)],
          text: 'Farmis Mobile data export');
    } catch (e) {
      setState(() => _exportError = 'Could not export data.\n$e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Import & export data',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Bring your existing fields, crops, finances and records into '
            'this device, or save a backup you can restore later or move '
            'to another device.',
            style: TextStyle(color: colors.textSecond),
          ),
          const SizedBox(height: 20),
          _SectionCard(
            icon: Icons.file_upload_outlined,
            iconColor: FarmioColors.info,
            title: 'Import data',
            body: 'Works with a file this app exported, or the old '
                'web-connected app\'s export (run `npm run export-mobile '
                '-- <farm id>` on the old backend first).',
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _importing ? null : _pickAndImport,
                icon: _importing
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: colors.textPrimary),
                      )
                    : const Icon(Icons.folder_open_outlined),
                label: Text(_importing ? 'Importing…' : 'Choose file to import'),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: FarmioColors.danger)),
          ],
          if (_summary != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FarmioColors.successBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Imported ${_summary!.total} records.\n$_summary',
                style: const TextStyle(color: FarmioColors.success, fontSize: 12),
              ),
            ),
          ],
          const SizedBox(height: 20),
          _SectionCard(
            icon: Icons.file_download_outlined,
            iconColor: FarmioColors.success,
            title: 'Export data',
            body: 'Saves everything in this app to a JSON file you can '
                'back up or import into another install.',
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _exporting ? null : _exportAndShare,
                icon: _exporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.ios_share_rounded),
                label: Text(_exporting ? 'Exporting…' : 'Export & share'),
              ),
            ),
          ),
          if (_exportError != null) ...[
            const SizedBox(height: 12),
            Text(_exportError!,
                style: const TextStyle(color: FarmioColors.danger)),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: colors.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: TextStyle(color: colors.textMuted, fontSize: 13)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
