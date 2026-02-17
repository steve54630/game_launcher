import 'package:game_launcher/domain/entities/discovery_result.entity.dart';
import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';

class AddGamesToLibrary {
  final GameRepository repository;

  AddGamesToLibrary(this.repository);

  Future<void> execute(List<DiscoveryResult> selectedResults) async {
    for (var result in selectedResults) {
      final newGame = Game(
        displayName: result.rawName,
        executablePath: result.fullPath,
      );
      await repository.upsertGame(newGame);
    }
  }
}
