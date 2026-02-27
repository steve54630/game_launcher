import 'package:flutter_test/flutter_test.dart';
import 'package:game_launcher/data/repositories/igbd_cache.repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:game_launcher/core/utils/database_helper.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/domain/entities/igbd_genre.entity.dart';

void main() {
  late IgdbCacheRepositoryImpl repository;
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    final dbHelper = DatabaseHelper.instance;
    dbHelper.setTestDatabase(db);
    await dbHelper.createDB(db, 1);
    repository = IgdbCacheRepositoryImpl(dbHelper);
  });

  tearDown(() async {
    await db.close();
  });

  final tMetadata = IgdbSearchResult(
    igdbId: 456,
    name: "Elden Ring",
    coverUrl: "https://example.com/cover.jpg",
    summary: "Rise, Tarnished",
    screenshots: ["https://example.com/s1.jpg"],
    genre: IgdbGenre(id: 1, name: "RPG"),
  );

  group('IgdbCacheRepository Integration Tests', () {
    test(
      'saveToCache doit insérer les métadonnées et synchroniser le genre',
      () async {
        await repository.saveToCache(tMetadata);

        final cacheResults = await db.query(
          'igdb_cache',
          where: 'igdb_id = ?',
          whereArgs: [456],
        );
        expect(cacheResults.length, 1);

        final genreResults = await db.query(
          'genres',
          where: 'id = ?',
          whereArgs: [1],
        );
        expect(genreResults.length, 1);
      },
    );

    test(
      'getCachedMetadata doit reconstruire une entité complète depuis la DB',
      () async {
        await repository.saveToCache(tMetadata);
        final result = await repository.getCachedMetadata(456);

        expect(result, isNotNull);
        expect(result!.name, "Elden Ring");
        expect(result.genre?.name, "RPG");
      },
    );

    test(
      'getCachedMetadata doit gérer les champs vides (video et date)',
      () async {
        await db.insert('igdb_cache', {
          'igdb_id': 111,
          'name': 'Empty Fields Game',
          'screenshot_urls': '[]',
          'video_id': '',
          'release_date': '',
          'updated_at': DateTime.now().toIso8601String(),
        });

        final result = await repository.getCachedMetadata(111);
        expect(result?.youtubeVideoId, isNull);
        expect(result?.releaseDate, isNull);
      },
    );

    test('deleteFromCache doit supprimer l\'entrée et les fichiers', () async {
      await repository.saveToCache(tMetadata);
      await repository.deleteFromCache(456);

      final result = await repository.getCachedMetadata(456);
      expect(result, isNull);
    });
  });
}
