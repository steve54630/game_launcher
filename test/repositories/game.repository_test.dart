import 'package:flutter_test/flutter_test.dart';
import 'package:game_launcher/core/utils/database_helper.dart';
import 'package:game_launcher/data/repositories/game.repository.dart';
import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../test.utilities.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late GameRepositoryImpl gameRepo;
  late Database db;

  setUp(() async {
    dbHelper = await createTestDatabase();
    db = await dbHelper.database;
    gameRepo = GameRepositoryImpl(dbHelper);
  });

  tearDown(() async {
    await db.close();
  });

  group('GameRepositoryImpl - Integration Tests', () {
    test('Should retrieve a game with local data only', () async {
      // 1. Arrange
      final newGame = Game(
        igdbId: 500,
        displayName: 'Doom Eternal',
        executablePath: 'C:\\Games\\Doom\\DoomEternal.exe',
      );
      await gameRepo.upsertGame(newGame);

      // 2. Act
      // Le Repo renvoie maintenant une List<Game>
      final results = await gameRepo.getAllGames();

      // 3. Assert
      expect(results.length, 1);
      final item = results.first;

      // On vérifie les données propres à la table 'games'
      expect(item.displayName, 'Doom Eternal');
      expect(item.igdbId, 500);
      expect(item.executablePath, 'C:\\Games\\Doom\\DoomEternal.exe');
    });

    test('Should handle multiple games and preserve order', () async {
      // Arrange
      await gameRepo.upsertGame(
        Game(displayName: 'Zelda', executablePath: 'z.exe'),
      );
      await gameRepo.upsertGame(
        Game(displayName: 'A-Train', executablePath: 'a.exe'),
      );

      // Act
      final results = await gameRepo.getAllGames();

      // Assert
      expect(results.length, 2);
      expect(results.first.displayName, 'A-Train'); // Test du ORDER BY
      expect(results.last.displayName, 'Zelda');
    });

    test('Should update existing game on duplicate path (Upsert)', () async {
      // Arrange
      const path = 'C:\\Games\\Solo.exe';
      await gameRepo.upsertGame(Game(displayName: 'V1', executablePath: path));
      await gameRepo.upsertGame(Game(displayName: 'V2', executablePath: path));

      // Act
      final results = await gameRepo.getAllGames();

      // Assert
      expect(results.length, 1);
      expect(results.first.displayName, 'V2');
    });

    test('Should delete game record from database', () async {
      // Arrange
      await gameRepo.upsertGame(
        Game(displayName: 'To Delete', executablePath: 'del.exe'),
      );
      var list = await gameRepo.getAllGames();
      final game = list.first;

      // Act
      await gameRepo.deleteGame(game);
      final results = await gameRepo.getAllGames();

      // Assert
      expect(results, isEmpty);
    });
  });
}
