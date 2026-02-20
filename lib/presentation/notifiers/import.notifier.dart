import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/repository.providers.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/data/utils/file_picker.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/domain/entities/game.entity.dart';
import '../../../domain/model/game.model.dart';

class ImportState {
  final String? localPath;
  final String? displayName;
  final IgdbSearchResult? selectedIgdbGame;
  final bool isSaving;
  final bool isSearching;
  final String? errorMessage;
  final List<IgdbSearchResult> searchResults;

  ImportState({
    this.localPath,
    this.displayName,
    this.selectedIgdbGame,
    this.isSaving = false,
    this.isSearching = false,
    this.errorMessage,
    this.searchResults = const [],
  });

  bool get canImport =>
      localPath != null && selectedIgdbGame != null && !isSaving;

  ImportState copyWith({
    String? localPath,
    String? displayName,
    IgdbSearchResult? Function()?
    selectedIgdbGame, // Permet de passer null explicitement
    bool? isSaving,
    bool? isSearching,
    String? errorMessage,
    bool clearError = false,
    List<IgdbSearchResult>? searchResults,
  }) {
    return ImportState(
      localPath: localPath ?? this.localPath,
      displayName: displayName ?? this.displayName,
      selectedIgdbGame: selectedIgdbGame != null
          ? selectedIgdbGame()
          : this.selectedIgdbGame,
      isSaving: isSaving ?? this.isSaving,
      isSearching: isSearching ?? this.isSearching,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchResults: searchResults ?? this.searchResults,
    );
  }
}

class ImportNotifier extends Notifier<ImportState> {
  Timer? _debounce;

  @override
  ImportState build() {
    ref.onDispose(() => _debounce?.cancel());
    return ImportState();
  }

  Future<void> selectGameFile() async {
    AppLogger.info("ImportNotifier: Démarrage de la sélection de fichier...");
    try {
      final path = await FilePickerService.pickExecutable();
      if (path == null) {
        AppLogger.info("ImportNotifier: Sélection annulée par l'utilisateur.");
        return;
      }

      final fileName = path.split(RegExp(r'[/\\]')).last.split('.').first;
      AppLogger.info(
        "ImportNotifier: Fichier sélectionné: $fileName (Path: $path)",
      );

      state = state.copyWith(
        localPath: path,
        displayName: fileName,
        selectedIgdbGame: () => null,
        searchResults: [],
        clearError: true,
      );

      searchIgdb(fileName);
    } catch (e) {
      AppLogger.error(
        "ImportNotifier: Erreur lors de la sélection du fichier",
        e,
      );
      state = state.copyWith(
        errorMessage: "Erreur lors de la sélection du fichier.",
      );
    }
  }

  void updateDisplayName(String newName) {
    if (newName == state.displayName) return;
    AppLogger.info(
      "ImportNotifier: DisplayName modifié par l'utilisateur: $newName",
    );

    state = state.copyWith(
      displayName: newName,
      selectedIgdbGame: () => null,
      searchResults: [],
      clearError: true,
    );

    searchIgdb(newName);
  }

  Future<void> searchIgdb(String query) async {
    _debounce?.cancel();

    if (query.isEmpty) {
      AppLogger.info("ImportNotifier: Query vide, arrêt de la recherche.");
      state = state.copyWith(isSearching: false, searchResults: []);
      return;
    }

    state = state.copyWith(isSearching: true, clearError: true);
    AppLogger.info(
      "ImportNotifier: Recherche IGDB programmée pour '$query' (debounce 500ms)",
    );

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      AppLogger.info(
        "ImportNotifier: Exécution de la recherche IGDB pour '$query'...",
      );

      try {
        final credentials = await ref.read(igdbCredentialsProvider.future);
        if (credentials == null) {
          AppLogger.error(
            "ImportNotifier: Échec de récupération des credentials IGDB.",
          );
          state = state.copyWith(
            isSearching: false,
            errorMessage: "Identifiants IGDB manquants.",
          );
          return;
        }

        final repository = ref.read(igdbSearchProvider);
        final results = await repository
            .search(query, credentials)
            .timeout(const Duration(seconds: 10));

        // Protection contre les race conditions
        if (query != state.displayName) {
          AppLogger.warning(
            "ImportNotifier: Résultat ignoré (Query obsolète: $query != ${state.displayName})",
          );
          return;
        }

        AppLogger.info(
          "ImportNotifier: Recherche réussie pour '$query'. ${results.length} résultats trouvés.",
        );

        state = state.copyWith(
          isSearching: false,
          searchResults: results,
          selectedIgdbGame: () => (results.isNotEmpty) ? results.first : null,
          errorMessage: (results.isEmpty) ? "Aucun match trouvé." : null,
        );

        if (results.isNotEmpty) {
          AppLogger.info(
            "ImportNotifier: Match automatique sur '${results.first.name}' (ID: ${results.first.igdbId})",
          );
        }
      } catch (e) {
        AppLogger.error(
          "ImportNotifier: Crash pendant searchIgdb('$query')",
          e,
        );

        if (query != state.displayName) return;

        state = state.copyWith(
          isSearching: false,
          errorMessage: "Erreur réseau ou mapping IGDB.",
        );
      }
    });
  }

  void setIgdbMatch(IgdbSearchResult game) {
    AppLogger.info(
      "ImportNotifier: Match sélectionné manuellement: ${game.name} (ID: ${game.igdbId})",
    );
    state = state.copyWith(selectedIgdbGame: () => game, clearError: true);
  }

  Future<bool> executeImport() async {
    AppLogger.info("ImportNotifier: Lancement de l'import final...");

    if (!state.canImport) {
      AppLogger.warning(
        "ImportNotifier: Import impossible (Data manquante ou déjà en cours)",
      );
      return false;
    }

    final selected = state.selectedIgdbGame;
    final path = state.localPath;

    if (selected == null || path == null) return false;

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final useCase = ref.read(saveGameUseCaseProvider);

      final finalGame = GameWithDetails(
        game: Game(
          displayName: state.displayName ?? selected.name,
          executablePath: path,
          igdbId: selected.igdbId,
        ),
        details: selected,
      );

      AppLogger.info(
        "ImportNotifier: Exécution du UseCase de sauvegarde pour '${finalGame.game.displayName}'",
      );
      await useCase.execute(finalGame);

      AppLogger.info("ImportNotifier: Import réussi avec succès.");
      return true;
    } catch (e) {
      AppLogger.error("ImportNotifier: Échec critique de l'import", e);
      state = state.copyWith(errorMessage: "Échec de l'enregistrement.");
      return false;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  void reset() {
    AppLogger.info("ImportNotifier: Reset de l'état d'import.");
    _debounce?.cancel();
    state = ImportState();
  }
}
