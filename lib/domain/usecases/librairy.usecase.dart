import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';

class GetLibrary {
  final GameRepository repository;

  GetLibrary(this.repository);

  Future<List<Game>> execute() {
    return repository.getAllGames();
  }
}
