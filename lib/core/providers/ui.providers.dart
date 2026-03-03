import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:game_launcher/core/extensions.dart';
import 'package:game_launcher/core/providers/repository.providers.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
import 'package:game_launcher/data/models/settings.model.dart';
import 'package:game_launcher/domain/entities/credentials.entity.dart';
import 'package:game_launcher/domain/entities/game_details.entity.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';

// Notifiers & States (Harmonisation des chemins vers notifiers)
import 'package:game_launcher/presentation/notifiers/credentials.notifier.dart';
import 'package:game_launcher/presentation/notifiers/import.notifier.dart';
import 'package:game_launcher/presentation/notifiers/import_all.notifier.dart';
import 'package:game_launcher/presentation/notifiers/search_game.notifier.dart';
import 'package:game_launcher/presentation/notifiers/settings.notifier.dart';
import 'package:game_launcher/presentation/state/import.state.dart';
import 'package:game_launcher/presentation/state/import_all.state.dart';
import 'package:game_launcher/presentation/state/matchable.entity.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

final activeImportTargetProvider = StateProvider<IgdbMatchable?>((ref) => null);

final editCredentialsProvider = NotifierProvider<CredentialsNotifier, void>(() {
  return CredentialsNotifier();
});

final gameSearchTermProvider = NotifierProvider<GameSearchTermNotifier, String>(
  () {
    return GameSearchTermNotifier();
  },
);

final importProvider =
    NotifierProvider.autoDispose<ImportNotifier, ImportState>(() {
      return ImportNotifier();
    });

final importAllProvider =
    NotifierProvider.autoDispose<ImportAllNotifier, ImportAllState>(() {
      return ImportAllNotifier();
    });

final getGamesProvider = StreamProvider<List<GameWithDetails>>((ref) {
  final repo = ref.watch(librairyUseCaseProvider);
  return repo.execute();
});

final igdbResultsProvider = FutureProvider.autoDispose<List<IgdbSearchResult>>((
  ref,
) async {
  final query = ref.watch(gameSearchTermProvider);
  if (query.isEmpty) return [];

  await Future.delayed(const Duration(milliseconds: 500));
  final useCase = ref.read(searchIgdbProvider);

  final results = await useCase.execute(query);
  debugPrint("Provider IGDB: ${results.length} trouvés pour '$query'");
  return results;
});

final filteredGamesProvider = Provider<AsyncValue<List<GameWithDetails>>>((
  ref,
) {
  final libraryAsync = ref.watch(getGamesProvider);
  final sortType = ref.watch(librarySortProvider);
  final search = ref.watch(librarySearchProvider);

  return libraryAsync.whenData(
    (games) => games.filteredBySearch(search).sortedBy(sortType),
  );
});

final librarySearchProvider = StateProvider<String>((ref) => "");

final igdbCredentialsProvider = FutureProvider<IgdbCredentials?>((ref) async {
  final repo = ref.watch(credentialsProvider);
  return await repo.getIgdbCredentials();
});

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsModel>(
  SettingsNotifier.new,
);
