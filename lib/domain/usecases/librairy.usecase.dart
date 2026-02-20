import 'package:game_launcher/domain/model/game.model.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';
import 'package:game_launcher/domain/repositories/igbd_cache.repository.dart';

class LibrairyUseCase {
  final GameRepository gameRepo;
  final IgdbCacheRepository igdbRepo;

  LibrairyUseCase({required this.gameRepo, required this.igdbRepo});

  // On change le type de retour en Stream
  Stream<List<GameWithDetails>> execute() {
    // 1. On écoute le Stream du repository (ex: watcher SQLite/Drift)
    return gameRepo.watchAllGames().asyncMap((games) async {
      // 2. Pour chaque nouvelle liste de jeux, on enrichit avec le cache
      return await Future.wait(
        games.map((game) async {
          final details = game.igdbId != null
              ? await igdbRepo.getCachedMetadata(game.igdbId!)
              : null;

          return GameWithDetails(game: game, details: details);
        }),
      );
    });
  }
}
