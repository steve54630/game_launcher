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
    AppLogger.info(
      "GameRepository: Un nouvel écouteur s'est branché au Stream des jeux.",
    );
    _refreshStream();
    return _gamesStreamController.stream;
  }

  Future<void> _refreshStream() async {
    try {
      AppLogger.debug(
        "GameRepository: Rafraîchissement du flux (Stream) demandé...",
      );
      final games = await getAllGames();

      if (!_gamesStreamController.isClosed) {
        _gamesStreamController.add(games);
        AppLogger.debug(
          "GameRepository: Flux mis à jour avec ${games.length} jeux.",
        );
      } else {
        AppLogger.warning(
          "GameRepository: Tentative de mise à jour d'un StreamController fermé.",
        );
      }
    } catch (e) {
      AppLogger.error("GameRepository: Échec de la notification du Stream", e);
    }
  }

  @override
  Future<List<Game>> getAllGames() async {
    try {
      final db = await dbHelper.database;
      AppLogger.info("GameRepository: Exécution de la requête SQL globale...");

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

      AppLogger.info(
        "GameRepository: ${maps.length} entrées récupérées de la base.",
      );

      return maps.map((map) {
        // En tant que dev, on logue si un parsing de date échoue spécifiquement
        try {
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
          );
        } catch (e) {
          AppLogger.error(
            "GameRepository: Erreur de parsing sur le jeu ${map['display_name']}",
            e,
          );
          rethrow;
        }
      }).toList();
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
      final GameModel model = GameModel.fromEntity(game);

      AppLogger.info(
        "GameRepository: Upsert SQLite pour '${game.displayName}' (ID: ${game.id ?? 'Nouveau'})",
      );

      await db.insert(
        'games',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      AppLogger.info(
        "GameRepository: Upsert réussi. Déclenchement de la notification Stream.",
      );
      await _refreshStream();
    } catch (e, stack) {
      AppLogger.error(
        "GameRepository: Échec de l'upsert pour ${game.displayName}",
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
      AppLogger.warning("GameRepository: Suppression du jeu ID: ${game.id}");

      final count = await db.delete(
        'games',
        where: 'id = ?',
        whereArgs: [game.id],
      );

      if (count > 0) {
        AppLogger.info(
          "GameRepository: Jeu supprimé avec succès. Rafraîchissement du flux.",
        );
        await _refreshStream();
      } else {
        AppLogger.warning(
          "GameRepository: Aucun jeu trouvé avec l'ID ${game.id} pour la suppression.",
        );
      }
    } catch (e, stack) {
      AppLogger.error(
        "GameRepository: Erreur lors de la suppression du jeu ID ${game.id}",
        e,
        stack,
      );
      rethrow;
    }
  }

  void dispose() {
    AppLogger.info("GameRepository: Fermeture définitive du StreamController.");
    _gamesStreamController.close();
  }
}
