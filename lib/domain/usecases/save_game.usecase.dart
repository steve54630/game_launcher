import 'package:game_launcher/domain/model/game.model.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';
import 'package:game_launcher/domain/repositories/igbd_cache.repository.dart';
import 'package:game_launcher/core/utils/logger.dart';

class SaveGameUseCase {
  final GameRepository gameRepo;
  final IgdbCacheRepository igbdRepo;

  SaveGameUseCase(this.gameRepo, this.igbdRepo);

  Future<void> execute(GameWithDetails gameDetails) async {
    final game = gameDetails.game;
    final details = gameDetails.details;
    final gameName = game.displayName;

    AppLogger.info(
      "SaveGameUseCase: Début de l'enregistrement pour '$gameName'.",
    );

    try {
      // 1. Sauvegarde des métadonnées riches dans le cache
      if (details != null) {
        AppLogger.info(
          "SaveGameUseCase: Mise en cache des métadonnées IGDB (ID: ${details.igdbId}).",
        );
        await igbdRepo.saveToCache(details);
      } else {
        AppLogger.warning(
          "SaveGameUseCase: Aucune métadonnée IGDB fournie pour '$gameName'.",
        );
      }

      // 2. Règle métier : validation de base
      if (game.executablePath.isEmpty) {
        AppLogger.error(
          "SaveGameUseCase: Échec de validation - Chemin de l'exécutable vide.",
        );
        throw Exception("Le chemin local de l'exécutable est requis.");
      }

      // 3. Persistance du jeu
      AppLogger.info(
        "SaveGameUseCase: Upsert du jeu dans la bibliothèque locale (Path: ${game.executablePath}).",
      );
      await gameRepo.upsertGame(game);

      AppLogger.info(
        "SaveGameUseCase: Enregistrement terminé avec succès pour '$gameName'.",
      );
    } catch (e) {
      AppLogger.error(
        "SaveGameUseCase: Erreur lors de l'exécution pour '$gameName'",
        e,
      );
      // On rethrow pour que le Notifier/UI puisse capturer l'erreur
      rethrow;
    }
  }
}
