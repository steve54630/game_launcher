import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';
import 'package:game_launcher/domain/repositories/igbd_cache.repository.dart';

class DeleteGameUseCase {
  final GameRepository gameRepo;
  final IgdbCacheRepository igdbRepo;

  DeleteGameUseCase(this.gameRepo, this.igdbRepo);

  Future<void> execute(Game game) async {
    final gameName = game.displayName;

    try {
      // 1. Validation métier (fail fast)
      if (game.id == null) {
        throw Exception("Impossible de supprimer un jeu sans ID.");
      }

      // 2. Suppression de la DB (Action principale)
      AppLogger.info("DeleteGameUseCase: Suppression de '$gameName' de la DB.");
      await gameRepo.deleteGame(game);

      // 3. Nettoyage du cache (Action secondaire / Side effect)
      if (game.igdbId != null) {
        AppLogger.info("DeleteGameUseCase: Nettoyage du cache IGDB.");
        await igdbRepo.deleteFromCache(game.igdbId!);
      }

      AppLogger.info("DeleteGameUseCase: Succès pour '$gameName'.");
    } catch (e) {
      AppLogger.error("DeleteGameUseCase: Échec pour '$gameName'", e);
      rethrow;
    }
  }
}
