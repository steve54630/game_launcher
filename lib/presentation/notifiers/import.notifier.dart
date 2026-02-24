import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/repository.providers.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/domain/model/game.model.dart';
import 'package:game_launcher/presentation/notifiers/import.state.dart';

class ImportNotifier extends Notifier<ImportState> {
  @override
  ImportState build() => ImportState();

  void setErrorMessage(String? message) {
    state = state.copyWith(errorMessage: message);
  }

  Future<void> selectGameFile() async {
    try {
      final path = await ref.read(filePickerService).pickExecutable();
      if (path == null) return;

      final fileName = path.split(RegExp(r'[/\\]')).last.split('.').first;

      state = state.copyWith(
        localPath: path,
        displayName: fileName,
        selectedIgdbGame: () => null,
      );
    } catch (e) {
      AppLogger.error("ImportNotifier: Erreur picking", e);
      state = state.copyWith(errorMessage: "Erreur lors de la sélection.");
    }
  }

  void updateDisplayName(String name) {
    if (name == state.displayName) return;
    state = state.copyWith(displayName: name, selectedIgdbGame: () => null);
  }

  Future<bool> executeImport() async {
    final selected = state.selectedIgdbGame;
    final path = state.localPath;

    if (selected == null || path == null) return false;

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final gameToSave = GameWithDetails(
        game: Game(
          displayName: state.displayName ?? selected.name,
          executablePath: path,
          igdbId: selected.igdbId,
        ),
        details: selected,
      );

      await ref.read(saveGameUseCaseProvider).execute(gameToSave);
      return true;
    } catch (e) {
      AppLogger.error("ImportNotifier: Erreur sauvegarde", e);
      state = state.copyWith(errorMessage: "Échec de l'enregistrement.");
      return false;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  void setIgdbMatch(IgdbSearchResult game) {
    state = state.copyWith(selectedIgdbGame: () => game, clearError: true);
  }

  void reset() {
    state = ImportState();
  }
}
