import 'package:flutter_test/flutter_test.dart';
import 'package:game_launcher/core/utils/database_helper.dart';
import 'package:game_launcher/data/repositories/game.repository.dart';
import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../test.utilities.dart'; // Vérifie que le nom du fichier est exact (test_utilities.dart)

void main() {
  // Initialisation du moteur pour l'environnement de test
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late GameRepositoryImpl gameRepo;
  late Database db;

  setUp(() async {
    // Utilisation de ton utilitaire pour créer une DB en mémoire
    dbHelper = await createTestDatabase();
    db = await dbHelper.database;
    gameRepo = GameRepositoryImpl(dbHelper);
  });

  tearDown(() async {
    await db.close();
  });

  group('GameRepositoryImpl - Integration Tests', () {
    test('Should retrieve a game with full metadata (Cache + Genre)', () async {
      // 1. Arrange : On prépare le terrain SQL
      // On insère d'abord le genre (référentiel)
      await db.insert('genres', {'id': 1, 'name': 'Action'});

      // On insère le cache IGDB lié au genre
      await db.insert('igdb_cache', {
        'igdb_id': 500,
        'name': 'Doom Eternal',
        'cover_url': 'https://image.com/doom.jpg',
        'summary': 'Rip and tear.',
        'genre_id':
            1, // Assure-toi que cette colonne existe bien dans ton schéma igdb_cache
        'updated_at': DateTime.now().toIso8601String(),
      });

      // On insère le jeu local lié à l'ID IGDB
      final newGame = Game(
        igdbId: 500,
        displayName: 'Doom Eternal',
        executablePath: 'C:\\Games\\Doom\\DoomEternal.exe',
      );
      await gameRepo.upsertGame(newGame);

      // 2. Act
      final results = await gameRepo.getAllGames();

      // 3. Assert
      expect(results.length, 1);
      final item = results.first;

      // Correction de l'accès : item.game (entité locale) et item.details (cache IGDB)
      expect(item.game.displayName, 'Doom Eternal');
      expect(item.details, isNotNull);
      expect(item.details?.coverUrl, 'https://image.com/doom.jpg');

      // C'est ici que ça échouait si la jointure n'était pas faite dans le Repo
      expect(item.details?.genre?.name, 'Action');
    });

    test('Should handle game without IGDB metadata (Left Join test)', () async {
      // Arrange : Un jeu sans ID IGDB
      final simpleGame = Game(
        displayName: 'My Custom Script',
        executablePath: 'C:\\Scripts\\test.bat',
      );

      // Act
      await gameRepo.upsertGame(simpleGame);
      final results = await gameRepo.getAllGames();

      // Assert
      expect(results.length, 1);
      expect(results.first.game.displayName, 'My Custom Script');
      expect(results.first.details, isNull);
    });

    test('Should update existing game but keep same ID (Upsert)', () async {
      // Arrange : Utilisation du même chemin d'exécutable pour simuler l'unicité
      const path = 'C:\\Games\\Solo.exe';
      final v1 = Game(displayName: 'Version 1', executablePath: path);
      final v2 = Game(displayName: 'Version 2', executablePath: path);

      // Act
      await gameRepo.upsertGame(v1);
      await gameRepo.upsertGame(v2);
      final results = await gameRepo.getAllGames();

      // Assert
      expect(results.length, 1);
      expect(results.first.game.displayName, 'Version 2');
    });

    test('Should delete game record but preserve IGDB cache', () async {
      // Arrange
      await db.insert('igdb_cache', {
        'igdb_id': 777,
        'name': 'Cyberpunk',
        'updated_at': '2026-02-19',
      });

      await gameRepo.upsertGame(
        Game(
          displayName: 'Cyberpunk 2077',
          executablePath: 'cp.exe',
          igdbId: 777,
        ),
      );

      final list = await gameRepo.getAllGames();
      final localId = list.first.game.id!;

      // Act
      await gameRepo.deleteGame(localId);

      // Assert
      final games = await gameRepo.getAllGames();
      expect(games, isEmpty);

      // Vérifier que le cache est toujours là (indépendance des tables)
      final cache = await db.query(
        'igdb_cache',
        where: 'igdb_id = ?',
        whereArgs: [777],
      );
      expect(cache, isNotEmpty);
    });

    test('Should return games ordered by display name', () async {
      // Arrange
      await gameRepo.upsertGame(
        Game(displayName: 'Zelda', executablePath: 'z.exe'),
      );
      await gameRepo.upsertGame(
        Game(displayName: 'A-Train', executablePath: 'a.exe'),
      );

      // Act
      final results = await gameRepo.getAllGames();

      // Assert : Vérification du tri alphabétique (ORDER BY)
      expect(results.first.game.displayName, 'A-Train');
      expect(results.last.game.displayName, 'Zelda');
    });
  });
}
