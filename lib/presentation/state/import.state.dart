import 'package:game_launcher/domain/entities/search_result.entity.dart';

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
    IgdbSearchResult? Function()? selectedIgdbGame,
    bool? isSaving,
    bool? isSearching,
    String? Function()? errorMessage,
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
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      searchResults: searchResults ?? this.searchResults,
    );
  }
}
