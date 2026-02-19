import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';

class AddGamesToLibrary {
  final GameRepository repository;

  AddGamesToLibrary(this.repository);

  Future<void> execute(List<Game> games) async {
    // Le use case reçoit déjà des objets "Game" valides
    // Il s'occupe juste de la persistence
    for (var game in games) {
      await repository.upsertGame(game);
    }
  }
}
