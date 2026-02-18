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

      // On utilise le SQL brut pour la jointure avec le cache IGDB
      // afin de récupérer toutes les métadonnées d'un coup.
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT g.*, c.cover_url, c.summary, c.screenshot_urls, c.video_id
        FROM games g
        LEFT JOIN igdb_cache c ON g.igdb_id = c.igdb_id
      ''');

      AppLogger.info("${maps.length} jeux récupérés depuis la base.");

      return maps.map((map) => GameModel.fromMap(map)).toList();
    } catch (e, stack) {
      AppLogger.error("Erreur lors de la récupération des jeux", e, stack);
      rethrow;
    }
  }

  @override
  Future<void> upsertGame(Game game) async {
    try {
      final db = await dbHelper.database;

      // On convertit l'entité en Model pour utiliser toMap()
      final GameModel model = GameModel.fromEntity(game);

      await db.insert(
        'games',
        model.toMap(),
        // 'replace' gère l'aspect "Upsert" grâce à la contrainte UNIQUE
        // sur executable_path dans ton script SQL
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

      final deletedCount = await db.delete(
        'games',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (deletedCount > 0) {
        AppLogger.info("Jeu ID $id supprimé avec succès.");
      }
    } catch (e, stack) {
      AppLogger.error("Erreur lors de la suppression du jeu ID $id", e, stack);
      rethrow;
    }
  }
}
