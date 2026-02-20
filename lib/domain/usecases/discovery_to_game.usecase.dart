import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';
import 'package:game_launcher/core/utils/logger.dart';

class AddGamesToLibrary {
  final GameRepository repository;

  AddGamesToLibrary(this.repository);

  Future<void> execute(List<Game> games) async {
    if (games.isEmpty) {
      AppLogger.warning(
        "AddGamesToLibrary: Liste de jeux vide reçue. Fin de l'exécution.",
      );
      return;
    }

    AppLogger.info(
      "AddGamesToLibrary: Début du traitement de ${games.length} jeu(x)...",
    );

    int successCount = 0;
    int errorCount = 0;

    for (var game in games) {
      try {
        AppLogger.info(
          "AddGamesToLibrary: Upsert du jeu: ${game.displayName} (ID IGDB: ${game.igdbId})",
        );

        await repository.upsertGame(game);

        successCount++;
      } catch (e) {
        errorCount++;
        AppLogger.error(
          "AddGamesToLibrary: Échec de l'upsert pour ${game.displayName}",
          e,
        );
        // On continue la boucle malgré l'erreur sur un jeu spécifique
      }
    }

    AppLogger.info(
      "AddGamesToLibrary: Traitement terminé. Succès: $successCount, Erreurs: $errorCount",
    );

    if (errorCount > 0) {
      AppLogger.warning(
        "AddGamesToLibrary: L'opération s'est terminée avec des erreurs partielles.",
      );
    }
  }
}
