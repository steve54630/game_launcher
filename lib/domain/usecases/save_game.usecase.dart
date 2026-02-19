// lib/domain/usecases/save_game.usecase.dart
import 'package:game_launcher/domain/repositories/game.repository.dart';

import '../model/game.model.dart';

class SaveGameUseCase {
  final GameRepository repository;

  SaveGameUseCase(this.repository);

  Future<void> execute(GameWithDetails gameDetails) async {
    final game = gameDetails.game;
    // Règle métier : validation de base
    if (game.executablePath.isEmpty) {
      throw Exception("Le chemin local de l'exécutable est requis.");
    }
    return await repository.upsertGame(game);
  }
}
