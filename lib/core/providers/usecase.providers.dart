import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/domain/usecases/delete_game.usecase.dart';
import 'package:game_launcher/domain/usecases/launcher.usecase.dart';
import 'package:game_launcher/domain/usecases/search_game.usecase.dart';
import 'repository.providers.dart';
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
  // On observe le displayName.
  // Dès que cette String change, TOUT ce bloc est ré-exécuté.
  final query = ref.watch(importProvider.select((s) => s.displayName));

  if (query == null || query.isEmpty) return [];

  // Debounce technique
  await Future.delayed(const Duration(milliseconds: 500));

  // On utilise ref.watch pour s'assurer que si SearchGameUseCase
  // change (ex: credentials mis à jour), la recherche est relancée.
  final useCase = ref.watch(searchIgdbProvider);

  return await useCase.execute(query);
});

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
