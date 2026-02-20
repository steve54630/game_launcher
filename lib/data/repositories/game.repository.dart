import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/data/models/game.model.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../core/utils/database_helper.dart';
import '../../domain/entities/game.entity.dart';

class GameRepositoryImpl implements GameRepository {
  final DatabaseHelper dbHelper;

  GameRepositoryImpl(this.dbHelper);

  @override
  Future<List<Game>> getAllGames() async {
    try {
      final db = await dbHelper.database;

      // On garde la jointure car elle est nécessaire pour le tri
      // et potentiellement pour remplir des champs de l'entité Game
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

      return maps.map((map) {
        return Game(
          id: map['id'],
          igdbId: map['igdb_id'],
          displayName: map['display_name'],
          executablePath: map['executable_path'],
          playtimeSeconds: map['playtime_seconds'] ?? 0,
          isFavorite: map['is_favorite'] == 1,
          lastPlayedAt: map['last_played_at'] != null
              ? DateTime.parse(map['last_played_at'])
              : null,
          // Si ton entité Game a des champs pour le genre ou la cover,
          // tu peux les ajouter ici en utilisant map['genre_name'], etc.
        );
      }).toList();
    } catch (e, stack) {
      AppLogger.error("Erreur lors de la récupération des jeux", e, stack);
      rethrow;
    }
  }

  @override
  Future<void> upsertGame(Game game) async {
    try {
      final db = await dbHelper.database;

      // Utilisation de ton GameModel pour le mapping SQL
      final GameModel model = GameModel.fromEntity(game);

      await db.insert(
        'games',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      AppLogger.debug("Jeu synchronisé : ${game.displayName}");
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
    } catch (e, stack) {
      AppLogger.error("Erreur lors de la suppression du jeu ID $id", e, stack);
      rethrow;
    }
  }
}
