import 'package:game_launcher/domain/model/game.model.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';

class GetLibrary {
  final GameRepository repository;

  GetLibrary(this.repository);

  Future<List<GameWithDetails>> execute() {
    return repository.getAllGames();
  }
}
