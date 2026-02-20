import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/repository.providers.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
import 'package:game_launcher/domain/entities/credentials.entity.dart';
import 'package:game_launcher/domain/model/game.model.dart';
import 'package:game_launcher/presentation/notifiers/credentials.notifier.dart';
import 'package:game_launcher/presentation/notifiers/import.notifier.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, void>(() {
  return SettingsNotifier();
});

final importProvider =
    NotifierProvider.autoDispose<ImportNotifier, ImportState>(() {
      return ImportNotifier();
    });

final getGamesProvider = StreamProvider<List<GameWithDetails>>((ref) {
  final repo = ref.watch(librairyUseCaseProvider);
  return repo.execute();
});

final igdbCredentialsProvider = FutureProvider<IgdbCredentials?>((ref) async {
  final repo = ref.watch(credentialsProvider);
  return await repo.getIgdbCredentials();
});
