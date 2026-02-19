import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/data/utils/file_picker.dart';
import 'package:game_launcher/providers.dart';
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
    try {
      final path = await FilePickerService.pickExecutable();
      if (path == null) return;

      // Extraction propre du nom du fichier
      final fileName = path.split(RegExp(r'[/\\]')).last.split('.').first;

      // FORCE : On met à jour le displayName systématiquement pour
      // déclencher la synchronisation avec le TextField dans l'UI
      state = state.copyWith(
        localPath: path,
        displayName: fileName,
        selectedIgdbGame: () => null,
        searchResults: [],
        clearError: true,
      );

      // On lance la recherche IGDB avec le nouveau nom
      searchIgdb(fileName);
    } catch (e) {
      state = state.copyWith(
        errorMessage: "Erreur lors de la sélection du fichier.",
      );
    }
  }

  void updateDisplayName(String newName) {
    if (newName == state.displayName) return;

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
      state = state.copyWith(isSearching: false, searchResults: []);
      return;
    }

    // On active le loader immédiatement
    state = state.copyWith(isSearching: true, clearError: true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final credentials = await ref.read(igdbCredentialsProvider.future);
        if (credentials == null) {
          state = state.copyWith(
            isSearching: false,
            errorMessage: "Identifiants IGDB manquants.",
          );
          return;
        }

        final repository = ref.read(igdbRepositoryProvider);
        final results = await repository
            .searchGames(query, credentials)
            .timeout(const Duration(seconds: 10));

        // Protection contre les réponses désynchronisées
        if (query != state.displayName) return;

        state = state.copyWith(
          isSearching: false,
          searchResults: results,
          selectedIgdbGame: () => results.isNotEmpty ? results.first : null,
          errorMessage: results.isEmpty ? "Aucun match trouvé." : null,
        );
      } catch (e) {
        if (query != state.displayName) return;
        state = state.copyWith(isSearching: false, errorMessage: e.toString());
      }
    });
  }

  void setIgdbMatch(IgdbSearchResult game) =>
      state = state.copyWith(selectedIgdbGame: () => game, clearError: true);

  Future<bool> executeImport() async {
    if (!state.canImport) return false;

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final useCase = ref.read(saveGameUseCaseProvider);
      final finalGame = GameWithDetails(
        game: Game(
          displayName: state.displayName ?? state.selectedIgdbGame!.name,
          executablePath: state.localPath!,
          igdbId: state.selectedIgdbGame!.igdbId,
        ),
        details: state.selectedIgdbGame,
      );

      await useCase.execute(finalGame);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: "Échec de l'enregistrement.");
      return false;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}
