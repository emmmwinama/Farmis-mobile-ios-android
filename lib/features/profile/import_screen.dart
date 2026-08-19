import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../core/db/database_provider.dart';
import '../../core/migration/import_service.dart';
import '../../core/theme/app_theme.dart';
import 'farm_profile_provider.dart';

const _expectedFileName = 'mobile-export.json';

/// One-time bridge for farmers switching from the old backend-connected app:
/// run `npm run export-mobile -- <farmId>` on the old backend, rename the
/// result to `mobile-export.json`, copy it onto the device into this app's
/// documents folder, then run the import from here. Safe to ignore (and
/// this screen safe to delete later) for anyone starting fresh.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  bool _importing = false;
  String? _error;
  ImportSummary? _summary;
  String? _targetPath;

  @override
  void initState() {
    super.initState();
    _resolvePath();
  }

  Future<void> _resolvePath() async {
    final dir = await getApplicationDocumentsDirectory();
    if (mounted) {
      setState(() => _targetPath = p.join(dir.path, _expectedFileName));
    }
  }

  Future<void> _runImport() async {
    setState(() {
      _importing = true;
      _error = null;
      _summary = null;
    });
    try {
      final path = _targetPath!;
      final file = File(path);
      if (!file.existsSync()) {
        setState(() =>
            _error = 'No file found at $path. Copy your export there first.');
        return;
      }
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Import existing data',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'If you used the old web-connected app, you can bring your existing '
            'fields, crops, finances and records into this device.',
            style: TextStyle(color: FarmioColors.textSecond),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FarmioColors.infoBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Steps',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: FarmioColors.info)),
                const SizedBox(height: 8),
                const Text(
                  '1. On a computer with access to the old backend, run:\n'
                  '   npm run export-mobile -- <your farm id>\n'
                  '2. Rename the resulting file to "$_expectedFileName".\n'
                  '3. Copy it onto this device at the path below.\n'
                  '4. Tap "Import now".',
                  style: TextStyle(color: FarmioColors.info, fontSize: 13),
                ),
                if (_targetPath != null) ...[
                  const SizedBox(height: 10),
                  SelectableText(
                    _targetPath!,
                    style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: FarmioColors.info,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: FarmioColors.danger)),
            const SizedBox(height: 12),
          ],
          if (_summary != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FarmioColors.successBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Imported ${_summary!.total} records.\n${_summary.toString()}',
                style: const TextStyle(color: FarmioColors.success, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _importing || _targetPath == null ? null : _runImport,
              child: _importing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Import now'),
            ),
          ),
        ],
      ),
    );
  }
}
