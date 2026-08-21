import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:farmio_mobile/core/db/app_database.dart';
import 'package:farmio_mobile/features/documents/documents_repository.dart';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.dir);
  final Directory dir;

  @override
  Future<String?> getApplicationDocumentsPath() async => dir.path;
}

void main() {
  late AppDatabase db;
  late DocumentsRepository repo;
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('documents_repo_test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir);
    db = AppDatabase(NativeDatabase.memory());
    repo = DocumentsRepository(db);
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('uploadDocument writes a real file and records its path', () async {
    final bytes = Uint8List.fromList([1, 2, 3, 4]);

    await repo.uploadDocument(
      name: 'Fertiliser receipt',
      type: 'receipt',
      bytes: bytes,
      extension: 'jpg',
      notes: 'ADMARC',
    );

    final docs = await repo.getDocuments();
    expect(docs, hasLength(1));
    expect(docs.first.size, 4);
    expect(File(docs.first.url).existsSync(), isTrue);
    expect(File(docs.first.url).readAsBytesSync(), bytes);
  });

  test('getDocuments filters by type', () async {
    await repo.uploadDocument(
      name: 'Receipt',
      type: 'receipt',
      bytes: [1],
      extension: 'jpg',
    );
    await repo.uploadDocument(
      name: 'Certificate',
      type: 'certificate',
      bytes: [2],
      extension: 'png',
    );

    final receipts = await repo.getDocuments(type: 'receipt');
    expect(receipts, hasLength(1));
    expect(receipts.first.name, 'Receipt');
  });

  test('deleteDocument removes both the row and the backing file', () async {
    await repo.uploadDocument(
      name: 'Receipt',
      type: 'receipt',
      bytes: [1, 2, 3],
      extension: 'jpg',
    );
    final doc = (await repo.getDocuments()).first;
    expect(File(doc.url).existsSync(), isTrue);

    await repo.deleteDocument(doc.id);

    expect(await repo.getDocuments(), isEmpty);
    expect(File(doc.url).existsSync(), isFalse);
  });
}
