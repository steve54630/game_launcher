import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';
import 'package:game_launcher/domain/repositories/process.repository.dart';

class LaunchGameSession {
  final GameRepository gameRepository;
  final ProcessRepository processRepository;

  LaunchGameSession(this.gameRepository, this.processRepository);

  Future<void> execute(Game game) async {
    if (game.id == null) return;

    // 2. Mettre à jour la date de dernier lancement
    final updatedGame = game.copyWith(lastPlayedAt: DateTime.now());
    await gameRepository.upsertGame(updatedGame);

    await processRepository.openExecutable(game.executablePath);
  }
}
