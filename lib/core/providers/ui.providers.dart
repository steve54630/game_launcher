import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:game_launcher/core/extensions.dart';
import 'package:game_launcher/core/providers/repository.providers.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
import 'package:game_launcher/domain/entities/credentials.entity.dart';
import 'package:game_launcher/domain/entities/game_details.entity.dart';
import 'package:game_launcher/presentation/notifiers/credentials.notifier.dart';
import 'package:game_launcher/presentation/notifiers/import.notifier.dart';
import 'package:game_launcher/presentation/state/import.state.dart';
import 'package:game_launcher/presentation/state/matchable.entity.dart';

final editCredentialsProvider = NotifierProvider<CredentialsNotifier, void>(() {
  return CredentialsNotifier();
});

final importProvider =
    NotifierProvider.autoDispose<ImportNotifier, ImportState>(() {
      return ImportNotifier();
    });

final activeImportTargetProvider = StateProvider<IgdbMatchable?>((ref) => null);

final navigationIndexProvider = StateProvider<int>((ref) => 0);

final getGamesProvider = StreamProvider<List<GameWithDetails>>((ref) {
  final repo = ref.watch(librairyUseCaseProvider);
  return repo.execute();
});

final igdbCredentialsProvider = FutureProvider<IgdbCredentials?>((ref) async {
  final repo = ref.watch(credentialsProvider);
  return await repo.getIgdbCredentials();
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
