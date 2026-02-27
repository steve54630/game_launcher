import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/repository.providers.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/domain/entities/game_details.entity.dart';
import 'package:game_launcher/presentation/notifiers/igbd_matchable.notifier.dart';
import 'package:game_launcher/presentation/state/import.state.dart';

class ImportNotifier extends Notifier<ImportState>
    with IgdbMatchableNotifier<ImportState> {
  @override
  ImportState build() => ImportState();

  void setErrorMessage(String? message) {
    if (message != null) {
      dev.log('Import Error: $message', name: 'ImportNotifier');
    }
    state = state.copyWith(errorMessage: () => message);
  }

  @override
  void applyMatch(IgdbSearchResult game, {String? path}) {
    state = state.copyWith(
      selectedIgdbGame: () => game,
      searchName: game.name,
      errorMessage: () => null,
    );
  }

  @override
  void updateSearchName(String name, {String? path}) {
    final isDifferent = state.selectedIgdbGame?.name != name;
    state = state.copyWith(
      searchName: name,
      selectedIgdbGame: isDifferent ? () => null : () => state.selectedIgdbGame,
    );
  }

  Future<void> selectGameFile() async {
    try {
      final path = await ref.read(filePickerService).pickExecutable();
      if (path == null) return;

      final fileName = path.split(RegExp(r'[/\\]')).last.split('.').first;

      state = state.copyWith(
        localPath: path,
        searchName: fileName,
        selectedIgdbGame: () => null,
        errorMessage: () => null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: () => "Erreur lors de la sélection.",
      );
    }
  }

  Future<bool> executeImport() async {
    final selected = state.selectedIgdbGame;
    final path = state.localPath;
    if (selected == null || path == null) return false;

    state = state.copyWith(isSaving: true, errorMessage: () => null);

    try {
      final gameToSave = GameWithDetails(
        game: Game(executablePath: path, igdbId: selected.igdbId),
        details: selected,
      );
      await ref.read(saveGameUseCaseProvider).execute(gameToSave);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: () => "Échec de l'enregistrement.");
      return false;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  void reset() {
    state = ImportState();
  }
}
