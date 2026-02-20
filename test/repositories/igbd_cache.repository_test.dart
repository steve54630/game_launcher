import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_launcher/data/repositories/igbd_cache.repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:game_launcher/core/utils/database_helper.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';

void main() {
  late IgdbCacheRepositoryImpl repository;
  late Database db;

  // Initialisation de sqflite pour les tests desktop/serveur
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Création d'une base de données en mémoire pour isoler les tests
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);

    // On configure le singleton DatabaseHelper pour utiliser notre DB de test
    final dbHelper = DatabaseHelper.instance;
    dbHelper.setTestDatabase(db);

    // On exécute la création des tables (ton script de migration)
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
    screenshots: ["https://example.com/s1.jpg", "https://example.com/s2.jpg"],
    releaseDate: DateTime(2022, 02, 25),
    youtubeVideoId: "AKXyDUMID_0",
  );

  group('IgdbCacheRepository Integration Tests', () {
    test(
      'saveToCache doit insérer les métadonnées et encoder les screenshots en JSON',
      () async {
        // Action
        await repository.saveToCache(tMetadata);

        // Vérification SQL brute
        final List<Map<String, dynamic>> results = await db.query(
          'igdb_cache',
          where: 'igdb_id = ?',
          whereArgs: [456],
        );

        expect(results.length, 1);
        expect(results.first['name'], "Elden Ring");

        // Vérification que les screenshots sont bien stockés en String JSON
        final List decodedScreenshots = jsonDecode(
          results.first['screenshot_urls'],
        );
        expect(decodedScreenshots.length, 2);
      },
    );

    test(
      'getCachedMetadata doit retourner une entité complète depuis la DB',
      () async {
        // Pré-remplissage
        await repository.saveToCache(tMetadata);

        // Action
        final result = await repository.getCachedMetadata(456);

        // Assertions
        expect(result, isNotNull);
        expect(result!.name, "Elden Ring");
        expect(result.igdbId, 456);
        expect(result.screenshots.length, 2);
      },
    );

    test(
      'getCachedMetadata doit retourner null si le jeu n\'existe pas',
      () async {
        final result = await repository.getCachedMetadata(999);
        expect(result, isNull);
      },
    );

    test('deleteFromCache doit supprimer l\'entrée correspondante', () async {
      // Pré-remplissage
      await repository.saveToCache(tMetadata);

      // Suppression
      await repository.deleteFromCache(456);

      // Vérification
      final result = await repository.getCachedMetadata(456);
      expect(result, isNull);
    });
  });
}
