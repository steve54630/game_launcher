import 'package:game_launcher/domain/entities/game_details.entity.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';
import 'package:game_launcher/domain/repositories/igbd_cache.repository.dart';
import 'package:game_launcher/core/utils/logger.dart';

class LibrairyUseCase {
  final GameRepository gameRepo;
  final IgdbCacheRepository igdbRepo;

  LibrairyUseCase({required this.gameRepo, required this.igdbRepo});

  Stream<List<GameWithDetails>> execute() {
    AppLogger.info(
      "LibrairyUseCase: Initialisation du flux de la bibliothèque.",
    );

    return gameRepo.watchAllGames().asyncMap((games) async {
      AppLogger.info(
        "LibrairyUseCase: Mise à jour reçue du repository (${games.length} jeux détectés).",
      );

      try {
        final enrichedGames = await Future.wait(
          games.map((game) async {
            if (game.igdbId == null) {
              AppLogger.warning(
                "LibrairyUseCase: Le jeu '${game.executablePath}' n'a pas d'ID IGDB associé.",
              );
              return GameWithDetails(game: game, details: null);
            }

            final details = await igdbRepo.getCachedMetadata(game.igdbId!);

            if (details == null) {
              AppLogger.warning(
                "LibrairyUseCase: Cache manquant pour IGDB ID: ${game.igdbId} (${game.executablePath}).",
              );
            }

            return GameWithDetails(game: game, details: details);
          }),
        );

        AppLogger.info(
          "LibrairyUseCase: Enrichissement terminé pour ${enrichedGames.length} jeux.",
        );
        return enrichedGames;
      } catch (e) {
        AppLogger.error(
          "LibrairyUseCase: Erreur lors de l'enrichissement de la bibliothèque",
          e,
        );
        // On retourne une liste vide ou on propage l'erreur selon ta stratégie UI
        return [];
      }
    });
  }
}
