import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/domain/entities/game_details.entity.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';
import 'package:game_launcher/domain/repositories/igbd_cache.repository.dart';

class SaveGameUseCase {
  final GameRepository gameRepo;
  final IgdbCacheRepository igdbRepo;

  SaveGameUseCase(this.gameRepo, this.igdbRepo);

  Future<void> execute(GameWithDetails gameDetails) async {
    final game = gameDetails.game;
    final details = gameDetails.details;
    final gameName = game.displayName;

    try {
      // 1. Validation de base : Chemin obligatoire
      if (game.executablePath.isEmpty) {
        throw Exception("L'exécutable du jeu est requis.");
      }

      // 2. LOGIQUE ANTI-DOUBLON (IDENTITÉ)
      // A. Vérification par Chemin (Le fichier est-il déjà utilisé par une autre entrée ?)
      final existingByPath = await gameRepo.getByPath(game.executablePath);
      if (existingByPath != null) {
        AppLogger.info(
          "SaveGameUseCase: Un jeu utilise déjà ce chemin : ${game.executablePath}.",
        );
        return;
      }
      // B. Vérification par ID IGDB (Le jeu est-il déjà présent via API ?)
      if (game.igdbId != null) {
        final existingById = await gameRepo.getByIgdbId(game.igdbId!);
        if (existingById != null) {
          AppLogger.info(
            "SaveGameUseCase: Le jeu '$gameName' est déjà dans la bibliothèque (ID IGDB: ${game.igdbId}).",
          );
          return;
        }
      }

      // 3. Persistance des métadonnées (Cache)
      if (details != null) {
        await igdbRepo.saveToCache(details);
      }

      // 4. Enregistrement final du jeu
      AppLogger.info("SaveGameUseCase: Création de l'entrée pour '$gameName'.");
      await gameRepo.upsertGame(game);
    } catch (e) {
      AppLogger.error("SaveGameUseCase: Échec de l'enregistrement", e);
      rethrow;
    }
  }
}
