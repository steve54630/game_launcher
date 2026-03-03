import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/repository.providers.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
import 'package:game_launcher/data/models/game_with_details.dart';
import 'package:game_launcher/domain/entities/discovery_result.entity.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/presentation/notifiers/igbd_matchable.notifier.dart';
import 'package:game_launcher/presentation/state/import.state.dart';

class ImportNotifier extends Notifier<ImportState>
    with IgdbMatchableNotifier<ImportState> {
  @override
  ImportState build() => ImportState();

  @override
  void applyMatch(IgdbSearchResult game, {String? path}) {
    state = state.copyWith(
      result: () => state.result?.copyWith(
        selectedMatch: () => game,
        status: DiscoveryStatus.matched,
      ),
    );
  }

  Future<void> selectGameFile() async {
    final path = await ref.read(filePickerService).pickExecutable();
    if (path == null) return;

    // On crée un DiscoveryResult "unitaire" à la volée
    final discovery = DiscoveryResult(
      fullPath: path,
      rawName: path.split(RegExp(r'[/\\]')).last.split('.').first,
      fileSize: 0, // Optionnel ici
      pathSegments: path.split(RegExp(r'[/\\]')),
    );

    state = state.copyWith(result: () => discovery);
  }

  Future<bool> executeImport() async {
    final res = state.result;
    if (res == null || !res.isReady) return false;

    state = state.copyWith(isSaving: true);
    try {
      await ref
          .read(saveGameUseCaseProvider)
          .execute(GameWithDetailsModel.fromDiscovery(res));
      return true;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  @override
  void updateSearchName(String name) {
    final currentResult = state.result;
    if (currentResult == null) return;

    // On vérifie si le nom saisi est différent du nom du match IGDB actuel
    final isDifferent = currentResult.selectedMatch?.name != name;

    state = state.copyWith(
      result: () => currentResult.copyWith(
        customSearchTerm: name,
        // Si le nom change, on repasse en pending et on vide le match sélectionné
        status: isDifferent ? DiscoveryStatus.pending : currentResult.status,
        selectedMatch: isDifferent
            ? () => null
            : () => currentResult.selectedMatch,
      ),
    );
  }

  void reset() {
    state = ImportState();
  }
}
