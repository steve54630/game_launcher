import 'dart:async';
import 'package:game_launcher/core/utils/database_helper.dart';
import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/data/models/game.model.dart';
import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class GameRepositoryImpl implements GameRepository {
  final DatabaseHelper dbHelper;
  final _gamesStreamController = StreamController<List<Game>>.broadcast();

  GameRepositoryImpl(this.dbHelper);

  @override
  Stream<List<Game>> watchAllGames() {
    AppLogger.info("GameRepository: Nouveau listener sur le flux des jeux.");
    _refreshStream();
    return _gamesStreamController.stream;
  }

  Future<void> _refreshStream() async {
    try {
      final games = await getAllGames();
      if (!_gamesStreamController.isClosed) {
        _gamesStreamController.add(games);
        AppLogger.debug(
          "GameRepository: Stream mis à jour (${games.length} jeux).",
        );
      }
    } catch (e) {
      AppLogger.error("GameRepository: Échec de la notification du flux", e);
    }
  }

  @override
  Future<List<Game>> getAllGames() async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT 
          g.*, 
          c.name as cache_name,
          gen.name as genre_name
        FROM games g
        LEFT JOIN igdb_cache c ON g.igdb_id = c.igdb_id
        LEFT JOIN genres gen ON c.genre_id = gen.id
        ORDER BY c.name ASC
      ''');

      return maps.map((map) => _mapToEntity(map)).toList();
    } catch (e, stack) {
      AppLogger.error(
        "GameRepository: Erreur fatale lors de getAllGames()",
        e,
        stack,
      );
      rethrow;
    }
  }

  @override
  Future<void> upsertGame(Game game) async {
    try {
      final db = await dbHelper.database;
      final model = GameModel.fromEntity(game);

      AppLogger.info("GameRepository: Upsert pour '${game.executablePath}'");

      await db.insert(
        'games',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await _refreshStream();
    } catch (e, stack) {
      AppLogger.error(
        "GameRepository: Échec de l'upsert (${game.executablePath})",
        e,
        stack,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteGame(Game game) async {
    try {
      final db = await dbHelper.database;

      final count = await db.delete(
        'games',
        where: 'id = ?',
        whereArgs: [game.id],
      );

      if (count > 0) {
        AppLogger.info("GameRepository: Jeu supprimé (ID: ${game.id})");
        await _refreshStream();
      }
    } catch (e, stack) {
      AppLogger.error(
        "GameRepository: Erreur lors de la suppression (ID: ${game.id})",
        e,
        stack,
      );
      rethrow;
    }
  }

  @override
  Future<Game?> getByIgdbId(int igdbId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'games',
        where: 'igdb_id = ?',
        whereArgs: [igdbId],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return _mapToEntity(maps.first);
    } catch (e) {
      AppLogger.error("GameRepository: Erreur lors de getByIgdbId($igdbId)", e);
      return null;
    }
  }

  @override
  Future<Game?> getByPath(String executablePath) async {
    try {
      final db = await dbHelper.database;

      // NOCASE est crucial pour Windows car le système de fichiers n'est pas case-sensitive
      final List<Map<String, dynamic>> maps = await db.query(
        'games',
        where: 'executable_path = ? COLLATE NOCASE',
        whereArgs: [executablePath],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return _mapToEntity(maps.first);
    } catch (e) {
      AppLogger.error(
        "GameRepository: Erreur lors de getByPath($executablePath)",
        e,
      );
      return null;
    }
  }

  /// Centralisation du mapping pour garantir la cohérence des données
  Game _mapToEntity(Map<String, dynamic> map) {
    try {
      return Game(
        id: map['id'] as int?,
        igdbId: map['igdb_id'] as int?,
        executablePath: map['executable_path'] as String,
        playtimeSeconds: map['playtime_seconds'] as int? ?? 0,
        isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
        lastPlayedAt: map['last_played_at'] != null
            ? DateTime.tryParse(map['last_played_at'] as String)
            : null,
      );
    } catch (e) {
      AppLogger.error("GameRepository: Erreur de mapping SQL -> Entity", e);
      rethrow;
    }
  }

  void dispose() {
    AppLogger.info("GameRepository: Fermeture du StreamController.");
    _gamesStreamController.close();
  }
}
