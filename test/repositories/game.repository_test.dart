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
        executablePath: 'C:\\Games\\Doom\\DoomEternal.exe',
      );
      await gameRepo.upsertGame(newGame);
      final results = await gameRepo.getAllGames();
      expect(results.length, 1);
    });

    test('Should handle multiple games and preserve order', () async {
      await gameRepo.upsertGame(Game(executablePath: 'z.exe'));
      await gameRepo.upsertGame(Game(executablePath: 'a.exe'));
      final results = await gameRepo.getAllGames();
      expect(results.first.executablePath, 'z.exe');
      expect(results.last.executablePath, 'a.exe');
    });
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
      Game(igdbId: igdbId, executablePath: 'hades.exe'),
    );

    final found = await gameRepo.getByIgdbId(igdbId);
    expect(found?.executablePath, 'hades.exe');
  });

  test('Should find game by executable path', () async {
    const path = 'C:\\Games\\Tunic.exe';
    await gameRepo.upsertGame(Game(executablePath: path));

    final found = await gameRepo.getByPath(path);
    expect(found?.executablePath, path);
  });

  test('Should handle date parsing and null fields from SQL join', () async {
    final now = DateTime.now().toIso8601String().split('.')[0];

    await db.insert('games', {
      'executable_path': 'map.exe',
      'playtime_seconds': 120,
      'is_favorite': 1,
      'last_played_at': now,
    });

    final results = await gameRepo.getAllGames();
    expect(results.first.isFavorite, isTrue);
    expect(results.first.lastPlayedAt, isNotNull);
  });
}

Matcher containsWith({required String displayName}) {
  return predicate<List<Game>>((list) {
    return list.any((g) => g.executablePath == displayName);
  });
}
