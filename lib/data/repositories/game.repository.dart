import 'dart:async'; // Ajout nécessaire
import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/data/models/game.model.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/utils/database_helper.dart';
import '../../domain/entities/game.entity.dart';

class GameRepositoryImpl implements GameRepository {
  final DatabaseHelper dbHelper;

  // Le broadcast permet d'avoir plusieurs écouteurs (ex: LibraryPage et une sidebar)
  final _gamesStreamController = StreamController<List<Game>>.broadcast();

  GameRepositoryImpl(this.dbHelper);

  @override
  Stream<List<Game>> watchAllGames() {
    _refreshStream();
    return _gamesStreamController.stream;
  }

  /// Méthode interne pour récupérer les données et les pousser dans le Stream
  Future<void> _refreshStream() async {
    try {
      final games = await getAllGames();
      if (!_gamesStreamController.isClosed) {
        _gamesStreamController.add(games);
      }
    } catch (e) {
      AppLogger.error("Erreur lors de la notification du Stream", e);
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
        ORDER BY g.display_name ASC
      ''');

      AppLogger.info("${maps.length} jeux récupérés.");

      return maps
          .map(
            (map) => Game(
              id: map['id'],
              igdbId: map['igdb_id'],
              displayName: map['display_name'],
              executablePath: map['executable_path'],
              playtimeSeconds: map['playtime_seconds'] ?? 0,
              isFavorite: map['is_favorite'] == 1,
              lastPlayedAt: map['last_played_at'] != null
                  ? DateTime.parse(map['last_played_at'])
                  : null,
            ),
          )
          .toList();
    } catch (e, stack) {
      AppLogger.error("Erreur lors de la récupération des jeux", e, stack);
      rethrow;
    }
  }

  @override
  Future<void> upsertGame(Game game) async {
    try {
      final db = await dbHelper.database;
      final GameModel model = GameModel.fromEntity(game);

      await db.insert(
        'games',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      AppLogger.debug("Jeu synchronisé : ${game.displayName}");

      // NOTIFICATION : On rafraîchit le stream après l'ajout
      await _refreshStream();
    } catch (e, stack) {
      AppLogger.error(
        "Erreur lors de l'upsert du jeu: ${game.displayName}",
        e,
        stack,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteGame(int id) async {
    try {
      final db = await dbHelper.database;
      await db.delete('games', where: 'id = ?', whereArgs: [id]);

      AppLogger.info("Jeu ID $id supprimé.");

      // NOTIFICATION : On rafraîchit le stream après la suppression
      await _refreshStream();
    } catch (e, stack) {
      AppLogger.error("Erreur lors de la suppression du jeu ID $id", e, stack);
      rethrow;
    }
  }

  // N'oublie pas de fermer le controller si le repository est détruit
  void dispose() {
    _gamesStreamController.close();
  }
}
