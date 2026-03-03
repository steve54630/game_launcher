import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/repository.providers.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
import 'package:game_launcher/data/models/game_with_details.dart';
import 'package:game_launcher/domain/entities/credentials.entity.dart';
import 'package:game_launcher/domain/entities/discovery_result.entity.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/presentation/notifiers/igbd_matchable.notifier.dart';
import 'package:game_launcher/presentation/state/import_all.state.dart';

class ImportAllNotifier extends Notifier<ImportAllState>
    with IgdbMatchableNotifier<ImportAllState> {
  String? _editingPath;

  @override
  ImportAllState build() => ImportAllState();

  void prepareEditing(String path) => _editingPath = path;

  // Plus besoin de toucher à un Set de strings, on filtre juste la liste
  void removeResult(String path) {
    state = state.copyWith(
      items: state.items.where((r) => r.fullPath != path).toList(),
    );
  }

  @override
  void applyMatch(IgdbSearchResult game, {String? path}) {
    final targetPath = path ?? _editingPath;
    if (targetPath == null) return;

    state = state.copyWith(
      items: state.items.map((item) {
        if (item.fullPath == targetPath) {
          return item.copyWith(
            selectedMatch: () => game,
            status: DiscoveryStatus.matched,
          );
        }
        return item;
      }).toList(),
    );
  }

  // La sélection est maintenant un flag interne à l'item
  void toggleSelection(String path) {
    state = state.copyWith(
      items: state.items
          .map(
            (item) => item.fullPath == path
                ? item.copyWith(isSelected: !item.isSelected)
                : item,
          )
          .toList(),
    );
  }

  void toggleAll(bool selected) {
    state = state.copyWith(
      items: state.items
          .map((item) => item.copyWith(isSelected: selected))
          .toList(),
    );
  }

  Future<void> importSelectedGames() async {
    // On utilise le getter calculé readyToImport défini dans le state
    if (state.readyToImport.isEmpty) return;

    state = state.copyWith(isSaving: true);
    try {
      final saveUseCase = ref.read(saveGameUseCaseProvider);
      for (final item in state.readyToImport) {
        await saveUseCase.execute(GameWithDetailsModel.fromDiscovery(item));
      }
      reset();
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  @override
  void updateSearchName(String name, {String? path}) {
    final targetPath = path ?? _editingPath;
    if (targetPath == null) return;

    state = state.copyWith(
      items: state.items.map((item) {
        if (item.fullPath == targetPath) {
          // Si le nom change, on réinitialise le match et on passe en mode 'pending'
          // pour que l'UI sache qu'une nouvelle recherche est nécessaire.
          final isDifferent = item.selectedMatch?.name != name;

          return item.copyWith(
            customSearchTerm: name,
            status: isDifferent ? DiscoveryStatus.pending : item.status,
            selectedMatch: isDifferent ? () => null : () => item.selectedMatch,
          );
        }
        return item;
      }).toList(),
    );
  }

  void reset() {
    _editingPath = null;
    state = ImportAllState();
  }

  Future<void> scanDirectory(String directoryPath) async {
    state = state.copyWith(
      isScanning: true,
      currentScanningPath: directoryPath,
      items: [],
    );

    try {
      final discoveredItems = await ref
          .read(librairyScanProvider)
          .execute(directoryPath);

      state = state.copyWith(
        items: discoveredItems
            .map((e) => e.copyWith(isSelected: true))
            .toList(),
        isScanning: false,
      );

      // On récupère les credentials une seule fois avant la boucle
      final credentials = await ref.read(igdbCredentialsProvider.future);

      if (credentials == null) {
        state = state.copyWith(error: "IGDB non configuré (Clés manquantes)");
        return;
      }

      // Matching auto
      for (final item in state.items) {
        _autoMatchIgdb(item, credentials);
      }
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        error: "Erreur lors du scan : ${e.toString()}",
      );
    }
  }

  Future<void> _autoMatchIgdb(
    DiscoveryResult item,
    IgdbCredentials credentials,
  ) async {
    _updateItemStatus(item.fullPath, DiscoveryStatus.searching);

    try {
      // On passe le terme et l'objet credentials complet
      final results = await ref
          .read(igdbSearchProvider)
          .search(item.effectiveSearchTerm, credentials);

      if (results.isNotEmpty) {
        applyMatch(results.first, path: item.fullPath);
      } else {
        _updateItemStatus(item.fullPath, DiscoveryStatus.pending);
      }
    } catch (e) {
      _updateItemStatus(item.fullPath, DiscoveryStatus.pending);
    }
  }

  /// Helper pour mettre à jour le statut d'un item sans reconstruire toute la logique
  void _updateItemStatus(String path, DiscoveryStatus status) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.fullPath == path) {
          return item.copyWith(status: status);
        }
        return item;
      }).toList(),
    );
  }
}
