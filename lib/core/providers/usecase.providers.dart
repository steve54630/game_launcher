import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/domain/usecases/launcher.usecase.dart';
import 'repository.providers.dart';
import 'package:game_launcher/domain/usecases/librairy.usecase.dart';
import 'package:game_launcher/domain/usecases/save_game.usecase.dart';

final saveGameUseCaseProvider = Provider(
  (ref) =>
      SaveGameUseCase(ref.watch(gameProvider), ref.watch(igdbCacheProvider)),
);

final librairyUseCaseProvider = Provider(
  (ref) => LibrairyUseCase(
    gameRepo: ref.watch(gameProvider),
    igdbRepo: ref.watch(igdbCacheProvider),
  ),
);

final launchGameSessionProvider = Provider<LaunchGameSession>((ref) {
  return LaunchGameSession(
    ref.watch(gameProvider), // Ton provider de repository
    ref.watch(processProvider), // Ton provider de process
  );
});
