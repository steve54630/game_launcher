import 'package:flutter_test/flutter_test.dart';
import 'package:game_launcher/core/utils/database_helper.dart';
import 'package:game_launcher/data/repositories/game.repository.dart';
import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../test.utilities.dart';

void main() {
  // 1. Initialiser le moteur FFI pour les tests
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late GameRepositoryImpl gameRepo;
  late Database db;

  setUp(() async {
    // Appel à l'utilitaire global
    dbHelper = await createTestDatabase();
    db = await dbHelper.database;
    gameRepo = GameRepositoryImpl(dbHelper);
  });

  tearDown(() async {
    // On récupère la db via le helper pour la fermer
    final db = await dbHelper.database;
    await db.close();
  });

  group('GameRepositoryImpl - Integration Tests', () {
    test('Should insert and retrieve a game with its IGDB cache', () async {
      // 1. Préparer les données IGDB en cache (nécessaire pour la jointure SQL)
      await db.insert('igdb_cache', {
        'igdb_id': 123,
        'name': 'The Witcher 3',
        'cover_url': 'https://image.com/cover.jpg',
        'summary': 'Un super jeu de test',
        'screenshot_urls': 'url1,url2',
        'video_id': 'abc123',
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 2. Créer l'entité de jeu
      final newGame = Game(
        igdbId: 123,
        executablePath: 'C:\\Games\\TestGame.exe',
        displayName: 'Test Game',
        playtimeSeconds: 0,
      );

      // 3. Act : Synchronisation en base et lecture
      await gameRepo.upsertGame(newGame);

      final games = await gameRepo.getAllGames();

      // 4. Assert
      expect(games.length, 1);
      expect(games.first.displayName, 'Test Game');
      expect(games.first.igdbId, 123);
    });

    test('Should update an existing game (Upsert via UNIQUE path)', () async {
      final path = 'C:\\Games\\UniqueGame.exe';

      final gameV1 = Game(executablePath: path, displayName: 'Version 1.0');

      final gameV2 = Game(executablePath: path, displayName: 'Version 2.0');

      // On insère V1 puis V2
      await gameRepo.upsertGame(gameV1);
      await gameRepo.upsertGame(gameV2);

      final games = await gameRepo.getAllGames();

      // Grâce à ConflictAlgorithm.replace sur executable_path
      expect(games.length, 1);
      expect(games.first.displayName, 'Version 2.0');
    });

    test('Should delete a game by its ID', () async {
      final game = Game(
        executablePath: 'path/to/delete.exe',
        displayName: 'To Delete',
      );

      await gameRepo.upsertGame(game);
      final listBefore = await gameRepo.getAllGames();
      final id = listBefore.first.id!;

      await gameRepo.deleteGame(id);

      final listAfter = await gameRepo.getAllGames();
      expect(listAfter.isEmpty, true);
    });
  });
}
