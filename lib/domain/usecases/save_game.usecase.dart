import 'package:game_launcher/domain/repositories/game.repository.dart';
import 'package:game_launcher/domain/repositories/igbd_cache.repository.dart';

import '../model/game.model.dart';

class SaveGameUseCase {
  final GameRepository gameRepo;
  final IgdbCacheRepository igbdRepo;

  SaveGameUseCase(this.gameRepo, this.igbdRepo);

  Future<void> execute(GameWithDetails gameDetails) async {
    final game = gameDetails.game;
    final details = gameDetails.details;

    await igbdRepo.saveToCache(details!);

    // Règle métier : validation de base
    if (game.executablePath.isEmpty) {
      throw Exception("Le chemin local de l'exécutable est requis.");
    }
    return await gameRepo.upsertGame(game);
  }
}
