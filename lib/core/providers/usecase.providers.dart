import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/domain/usecases/delete_game.usecase.dart';
import 'package:game_launcher/domain/usecases/launcher.usecase.dart';
import 'package:game_launcher/domain/usecases/librairy_scan.usecase.dart';
import 'package:game_launcher/domain/usecases/search_game.usecase.dart';
import 'package:game_launcher/presentation/notifiers/import_all.notifier.dart';
import 'package:game_launcher/presentation/state/import_all.state.dart';
import 'package:game_launcher/presentation/notifiers/search_game.notifier.dart';
import 'repository.providers.dart';
import 'package:flutter/foundation.dart';
import 'package:game_launcher/domain/usecases/librairy.usecase.dart';
import 'package:game_launcher/domain/usecases/save_game.usecase.dart';

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

final igdbResultsProvider = FutureProvider.autoDispose<List<IgdbSearchResult>>((
  ref,
) async {
  // Écoute le terme tapé dans la modale, quel que soit le mode
  final query = ref.watch(gameSearchTermProvider);

  if (query.isEmpty) return [];

  await Future.delayed(const Duration(milliseconds: 500));

  final useCase = ref.read(
    searchIgdbProvider,
  ); // Utilise read ici pour éviter les boucles

  final results = await useCase.execute(query);

  // Log de vérification ici
  debugPrint("Provider IGDB: ${results.length} trouvés pour '$query'");

  return results;
});

final librairyUseCaseProvider = Provider(
  (ref) => LibrairyUseCase(
    gameRepo: ref.watch(gameProvider),
    igdbRepo: ref.watch(igdbCacheProvider),
  ),
);

final gameSearchTermProvider = NotifierProvider<GameSearchTermNotifier, String>(
  () {
    return GameSearchTermNotifier();
  },
);

final importAllProvider =
    NotifierProvider.autoDispose<ImportAllNotifier, ImportAllState>(() {
      return ImportAllNotifier();
    });

final librairyScanProvider = Provider(
  (ref) => ScanLibrarySource(ref.watch(processProvider)),
);

final launchGameSessionProvider = Provider<LaunchGameSession>((ref) {
  return LaunchGameSession(ref.watch(gameProvider), ref.watch(processProvider));
});
