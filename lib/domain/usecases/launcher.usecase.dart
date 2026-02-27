import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';
import 'package:game_launcher/domain/repositories/process.repository.dart';
import 'package:game_launcher/core/utils/logger.dart';

class LaunchGameSession {
  final GameRepository gameRepository;
  final ProcessRepository processRepository;

  LaunchGameSession(this.gameRepository, this.processRepository);

  Future<void> execute(Game game) async {
    final gameName = game.executablePath;
    AppLogger.info(
      "LaunchGameSession: Tentative de lancement pour '$gameName'...",
    );

    if (game.id == null) {
      AppLogger.warning(
        "LaunchGameSession: Annulation, l'ID du jeu est nul (jeu non enregistré).",
      );
      return;
    }

    try {
      // 1. Mettre à jour la date de dernier lancement
      AppLogger.info(
        "LaunchGameSession: Mise à jour de 'lastPlayedAt' pour '$gameName' dans la DB.",
      );
      final updatedGame = game.copyWith(lastPlayedAt: DateTime.now());
      await gameRepository.upsertGame(updatedGame);

      // 2. Lancer l'exécutable
      AppLogger.info(
        "LaunchGameSession: Appel système pour ouvrir l'exécutable à: ${game.executablePath}",
      );

      // On n'attend pas forcément la fermeture du processus, mais on logue le succès de l'ouverture
      await processRepository.openExecutable(game.executablePath);

      AppLogger.info(
        "LaunchGameSession: Commande de lancement envoyée avec succès pour '$gameName'.",
      );
    } catch (e) {
      AppLogger.error(
        "LaunchGameSession: Erreur fatale lors du lancement de '$gameName'",
        e,
      );
      // On rethrow pour que l'UI puisse éventuellement afficher une SnackBar d'erreur
      rethrow;
    }
  }
}
