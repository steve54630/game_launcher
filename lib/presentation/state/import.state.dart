import 'package:game_launcher/domain/entities/search_result.entity.dart';

class ImportState {
  final String? localPath;
  final String? searchName;
  final IgdbSearchResult? selectedIgdbGame;
  final bool isSaving;
  final bool isSearching;
  final String? error;
  final List<IgdbSearchResult> searchResults;

  ImportState({
    this.localPath,
    this.searchName,
    this.selectedIgdbGame,
    this.isSaving = false,
    this.isSearching = false,
    this.error,
    this.searchResults = const [],
  });

  bool get canImport =>
      localPath != null && selectedIgdbGame != null && !isSaving;

  ImportState copyWith({
    String? localPath,
    String? searchName,
    IgdbSearchResult? Function()? selectedIgdbGame,
    bool? isSaving,
    bool? isSearching,
    String? Function()? errorMessage,
    List<IgdbSearchResult>? searchResults,
  }) {
    return ImportState(
      localPath: localPath ?? this.localPath,
      searchName: searchName ?? this.searchName,
      selectedIgdbGame: selectedIgdbGame != null
          ? selectedIgdbGame()
          : this.selectedIgdbGame,
      isSaving: isSaving ?? this.isSaving,
      isSearching: isSearching ?? this.isSearching,
      error: errorMessage != null ? errorMessage() : error,
      searchResults: searchResults ?? this.searchResults,
    );
  }
}
