import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/domain/usecases/delete_game.usecase.dart';
import 'package:game_launcher/domain/usecases/launcher.usecase.dart';
import 'package:game_launcher/domain/usecases/librairy_scan.usecase.dart';
import 'package:game_launcher/domain/usecases/search_game.usecase.dart';
import 'package:game_launcher/domain/usecases/librairy.usecase.dart';
import 'package:game_launcher/domain/usecases/save_game.usecase.dart';
import 'repository.providers.dart';

// --- Tes noms et ta logique d'origine ---

final saveGameUseCaseProvider = Provider(
  (ref) =>
      SaveGameUseCase(ref.watch(gameProvider), ref.watch(igdbCacheProvider)),
);

final deleteGameUseCaseProvider = Provider(
  (ref) =>
      DeleteGameUseCase(ref.watch(gameProvider), ref.watch(igdbCacheProvider)),
);

final searchIgdbProvider = Provider(
  (ref) => SearchGameUseCase(
    ref.watch(igdbSearchProvider),
    ref.watch(credentialsProvider),
  ),
);

final librairyUseCaseProvider = Provider(
  (ref) => LibrairyUseCase(
    gameRepo: ref.watch(gameProvider),
    igdbRepo: ref.watch(igdbCacheProvider),
  ),
);

final librairyScanProvider = Provider(
  (ref) => ScanLibrarySource(ref.watch(processProvider)),
);

final launchGameSessionProvider = Provider<LaunchGameSession>((ref) {
  return LaunchGameSession(ref.watch(gameProvider), ref.watch(processProvider));
});
