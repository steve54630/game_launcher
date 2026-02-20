import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/utils/database_helper.dart';
import 'package:game_launcher/data/repositories/credential.repository.dart';
import 'package:game_launcher/data/repositories/game.repository.dart';
import 'package:game_launcher/data/repositories/igbd.repository.dart';
import 'package:game_launcher/data/repositories/igbd_cache.repository.dart';
import 'package:game_launcher/domain/entities/credentials.entity.dart';
import 'package:game_launcher/domain/repositories/credentails.repository.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';
import 'package:game_launcher/domain/repositories/igbd.repository.dart';
import 'package:game_launcher/domain/repositories/igbd_cache.repository.dart';
import 'package:game_launcher/domain/usecases/save_game.usecase.dart';
import 'package:game_launcher/presentation/providers/import.provider.dart';

// --- 1. Providers des Repositories ---

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepositoryImpl(DatabaseHelper.instance);
});

final igdbSearchRepositoryProvider = Provider<IgdbSearchRepository>((ref) {
  return IgdbSearchRepositoryImpl();
});

final igdbCacheRepositoryProvider = Provider<IgdbCacheRepository>((ref) {
  return IgdbCacheRepositoryImpl(DatabaseHelper.instance);
});

final credentialsProvider = Provider<CredentialsRepository>((ref) {
  return CredentialsRepositoryImpl();
});

// --- 2. Providers du Domain (Logic) ---

final igdbCredentialsProvider = FutureProvider<IgdbCredentials?>((ref) async {
  final repo = ref.watch(credentialsProvider);
  return await repo.getIgdbCredentials();
});

final saveGameUseCaseProvider = Provider<SaveGameUseCase>((ref) {
  final gameRepo = ref.watch(gameRepositoryProvider);
  final cacheRepo = ref.watch(igdbCacheRepositoryProvider);

  return SaveGameUseCase(gameRepo, cacheRepo);
});

// --- 3. Providers de la Presentation (UI State) ---

final importProvider =
    NotifierProvider.autoDispose<ImportNotifier, ImportState>(() {
      return ImportNotifier();
    });
