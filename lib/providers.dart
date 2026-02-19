import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/utils/database_helper.dart';
import 'package:game_launcher/data/repositories/credential.repository.dart';
import 'package:game_launcher/data/repositories/game.repository.dart';
import 'package:game_launcher/data/repositories/search_result.repository.dart';
import 'package:game_launcher/domain/entities/credentials.entity.dart';
import 'package:game_launcher/domain/repositories/credentails.repository.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';
import 'package:game_launcher/domain/repositories/search_result.repository.dart';
import 'package:game_launcher/domain/usecases/save_game.usecase.dart';
import 'package:game_launcher/presentation/providers/import.provider.dart';

// 1. Repository
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepositoryImpl(DatabaseHelper.instance);
});

// 2. UseCase
final saveGameUseCaseProvider = Provider<SaveGameUseCase>((ref) {
  final repository = ref.watch(gameRepositoryProvider);
  return SaveGameUseCase(repository);
});

// 3. Provider pour l'UI
// Utilise StateNotifierProvider (SANS legacy)
final importProvider =
    NotifierProvider.autoDispose<ImportNotifier, ImportState>(() {
      return ImportNotifier();
    });

final igdbRepositoryProvider = Provider<IgdbRepository>((ref) {
  return IgdbRepositoryImpl();
});

final credentialsProvider = Provider<CredentialsRepository>((ref) {
  return CredentialsRepositoryImpl();
});

final igdbCredentialsProvider = FutureProvider<IgdbCredentials?>((ref) async {
  final repo = ref.watch(credentialsProvider);
  // C'est cet appel qui est mis en cache par Riverpod
  return await repo.getIgdbCredentials();
});
