import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_utils.dart';
import '../../models/farm_document.dart';

class DocumentsRepository {
  DocumentsRepository(this._db);

  final AppDatabase _db;

  Future<List<FarmDocument>> getDocuments({String? type}) async {
    final query = _db.select(_db.farmDocuments)
      ..orderBy([(t) => OrderingTerm.desc(t.uploadedAt)]);
    if (type != null) query.where((t) => t.type.equals(type));
    final rows = await query.get();
    return rows.map((r) => FarmDocument.fromJson(r.toJson())).toList();
  }

  Future<void> uploadDocument({
    required String name,
    required String type,
    required List<int> bytes,
    required String extension,
    String? notes,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final docsDir = Directory(p.join(dir.path, 'documents'));
    await docsDir.create(recursive: true);
    final id = newId();
    final file = File(p.join(docsDir.path, '$id.$extension'));
    await file.writeAsBytes(bytes);

    await _db.into(_db.farmDocuments).insert(FarmDocumentsCompanion.insert(
          id: id,
          name: name,
          type: type,
          url: file.path,
          size: Value(bytes.length),
          notes: Value(notes),
          uploadedAt: DateTime.now(),
        ));
  }

  Future<void> deleteDocument(String id) async {
    final row = await (_db.select(_db.farmDocuments)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    await (_db.delete(_db.farmDocuments)..where((t) => t.id.equals(id))).go();
    if (row == null) return;
    // Best-effort: the on-device file backing this record — a missing file
    // (e.g. already cleared) shouldn't block the record itself being gone.
    try {
      final file = File(row.url);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}
