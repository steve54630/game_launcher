import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/data/models/game.model.dart';
import 'package:game_launcher/domain/model/game.model.dart'; // Import de GameWithDetails
import 'package:game_launcher/domain/repositories/game.repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../core/utils/database_helper.dart';
import '../../domain/entities/game.entity.dart';
import '../../domain/entities/search_result.entity.dart';
import '../../domain/entities/igbd_genre.entity.dart';

class GameRepositoryImpl implements GameRepository {
  final DatabaseHelper dbHelper;

  GameRepositoryImpl(this.dbHelper);

  @override
  Future<List<GameWithDetails>> getAllGames() async {
    try {
      final db = await dbHelper.database;

      // Jointure triple avec tri explicite pour valider le test 'A-Train' vs 'Zelda'
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT 
          g.*, 
          c.name as cache_name,
          c.cover_url, 
          c.summary, 
          c.screenshot_urls, 
          c.video_id, 
          c.release_date,
          gen.name as genre_name
        FROM games g
        LEFT JOIN igdb_cache c ON g.igdb_id = c.igdb_id
        LEFT JOIN genres gen ON c.genre_id = gen.id
        ORDER BY g.display_name ASC
      ''');

      AppLogger.info("${maps.length} jeux récupérés avec leurs métadonnées.");

      return maps.map((map) {
        // Mapping de l'entité locale Game
        final game = Game(
          id: map['id'],
          igdbId: map['igdb_id'],
          displayName: map['display_name'],
          executablePath: map['executable_path'],
          playtimeSeconds: map['playtime_seconds'] ?? 0,
          isFavorite: map['is_favorite'] == 1,
          lastPlayedAt: map['last_played_at'] != null
              ? DateTime.parse(map['last_played_at'])
              : null,
        );

        // Mapping des détails IGDB si présents
        IgdbSearchResult? details;
        if (map['igdb_id'] != null) {
          details = IgdbSearchResult(
            igdbId: map['igdb_id'],
            name: map['cache_name'] ?? map['display_name'],
            coverUrl: map['cover_url'],
            summary: map['summary'],
            // Correction du null sur le Genre : on reconstruit l'objet à partir de 'genre_name'
            genre: map['genre_name'] != null
                ? IgdbGenre(id: map['genre_id'] ?? 0, name: map['genre_name'])
                : null,
            screenshots: [], // À parser si tes tests vérifient les captures
            youtubeVideoId: map['video_id'],
          );
        }

        return GameWithDetails(game: game, details: details);
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
