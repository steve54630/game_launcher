import 'package:game_launcher/domain/model/game.model.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';
import 'package:game_launcher/domain/repositories/igbd_cache.repository.dart';

class LibrairyUseCase {
  final GameRepository gameRepo;
  final IgdbCacheRepository igdbRepo;

  LibrairyUseCase({required this.gameRepo, required this.igdbRepo});

  Future<List<GameWithDetails>> execute() async {
    // 1. On récupère d'abord la liste des jeux
    final games = await gameRepo.getAllGames();

    // 2. On lance toutes les récupérations de cache en parallèle
    return await Future.wait(
      games.map((game) async {
        // On ne récupère les détails que si on a un igdbId
        final details = game.igdbId != null
            ? await igdbRepo.getCachedMetadata(game.igdbId!)
            : null;

        return GameWithDetails(game: game, details: details);
      }),
    );
  }
}
