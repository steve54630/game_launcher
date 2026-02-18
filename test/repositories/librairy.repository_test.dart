import 'package:flutter_test/flutter_test.dart';
import 'package:game_launcher/core/utils/database_helper.dart';
import 'package:game_launcher/data/repositories/library.repository.dart';

import '../test.utilities.dart';

void main() {
  late DatabaseHelper dbHelper;
  late LibrarySourceRepositoryImpl repository;

  setUp(() async {
    dbHelper = await createTestKeysDatabase();
    repository = LibrarySourceRepositoryImpl(dbHelper);
  });

  tearDown(() async {
    final db = await dbHelper.database;
    await db.close();
  });

  group('LibrarySourceRepositoryImpl - Integration Tests', () {
    test('Should add and retrieve library sources', () async {
      final testPath = 'C:\\Games\\Steam';

      await repository.addSource(testPath);
      final sources = await repository.getAllSources();

      expect(sources.length, 1);
      expect(sources.first.path, testPath);
    });

    test('Should not allow duplicate paths (UNIQUE constraint)', () async {
      final testPath = 'D:\\Games\\Epic';

      await repository.addSource(testPath);

      // L'insertion d'un doublon doit jeter une exception (ou être gérée par un replace)
      // Vu ton code (db.insert), ça va jeter une DatabaseException
      expect(() => repository.addSource(testPath), throwsA(isA<Exception>()));
    });

    test('Should remove a source by ID', () async {
      await repository.addSource('C:\\Temp');
      final sourcesBefore = await repository.getAllSources();
      final id = sourcesBefore.first.id!;

      await repository.removeSource(id);

      final sourcesAfter = await repository.getAllSources();
      expect(sourcesAfter.isEmpty, true);
    });
  });
}
