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
    gameRepo.dispose();
    await db.close();
  });

  group('GameRepositoryImpl - Integration Tests', () {
    test('Should retrieve a game with local data only', () async {
      final newGame = Game(
        igdbId: null,
        displayName: 'Doom Eternal',
        executablePath: 'C:\\Games\\Doom\\DoomEternal.exe',
      );
      await gameRepo.upsertGame(newGame);
      final results = await gameRepo.getAllGames();
      expect(results.length, 1);
      expect(results.first.displayName, 'Doom Eternal');
    });

    test('Should handle multiple games and preserve order', () async {
      await gameRepo.upsertGame(
        Game(displayName: 'Zelda', executablePath: 'z.exe'),
      );
      await gameRepo.upsertGame(
        Game(displayName: 'A-Train', executablePath: 'a.exe'),
      );
      final results = await gameRepo.getAllGames();
      expect(results.first.displayName, 'A-Train');
      expect(results.last.displayName, 'Zelda');
    });

    test('Should watchAllGames and emit updates on changes', () async {
      final stream = gameRepo.watchAllGames();

      final futureExpect = expectLater(
        stream,
        emitsThrough(containsWith(displayName: 'Stray')),
      );

      await gameRepo.upsertGame(
        Game(displayName: 'Stray', executablePath: 'stray.exe'),
      );
      await futureExpect;
    });

    test('Should find game by IGDB ID', () async {
      const igdbId = 42;

      await db.insert('igdb_cache', {
        'igdb_id': igdbId,
        'name': 'Hades',
        'screenshot_urls': '[]',
        'updated_at': DateTime.now().toIso8601String(),
      });

      await gameRepo.upsertGame(
        Game(igdbId: igdbId, displayName: 'Hades', executablePath: 'hades.exe'),
      );

      final found = await gameRepo.getByIgdbId(igdbId);
      expect(found?.displayName, 'Hades');
    });

    test('Should find game by executable path', () async {
      const path = 'C:\\Games\\Tunic.exe';
      await gameRepo.upsertGame(
        Game(displayName: 'Tunic', executablePath: path),
      );

      final found = await gameRepo.getByPath(path);
      expect(found?.displayName, 'Tunic');
    });

    test('Should handle date parsing and null fields from SQL join', () async {
      final now = DateTime.now().toIso8601String().split('.')[0];

      await db.insert('games', {
        'display_name': 'Mapped Game',
        'executable_path': 'map.exe',
        'playtime_seconds': 120,
        'is_favorite': 1,
        'last_played_at': now,
      });

      final results = await gameRepo.getAllGames();
      expect(results.first.isFavorite, isTrue);
      expect(results.first.lastPlayedAt, isNotNull);
    });
  });
}

Matcher containsWith({required String displayName}) {
  return predicate<List<Game>>((list) {
    return list.any((g) => g.displayName == displayName);
  });
}
