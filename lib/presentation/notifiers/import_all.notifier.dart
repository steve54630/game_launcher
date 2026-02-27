import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
import 'package:game_launcher/data/models/game_with_details.dart';
import 'package:game_launcher/domain/entities/discovery_result.entity.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/presentation/notifiers/igbd_matchable.notifier.dart';
import 'package:game_launcher/presentation/state/import_all.state.dart';

class ImportAllNotifier extends Notifier<ImportAllState>
    with IgdbMatchableNotifier<ImportAllState> {
  String? _editingPath;

  @override
  ImportAllState build() => ImportAllState();

  void prepareEditing(String path) {
    _editingPath = path;
  }

  void removeResult(String path) {
    state = state.copyWith(
      results: state.results.where((r) => r.fullPath != path).toList(),
      selectedPaths: state.selectedPaths.where((p) => p != path).toSet(),
    );
    if (_editingPath == path) _editingPath = null;
  }

  @override
  void applyMatch(IgdbSearchResult game, {String? path}) {
    final targetPath = path ?? _editingPath;
    if (targetPath == null) return;

    state = state.copyWith(
      results: state.results.map((item) {
        if (item.fullPath == targetPath) {
          return item.copyWith(igdbMatch: () => game, rawName: game.name);
        }
        return item;
      }).toList(),
    );
    _editingPath = null;
  }

  @override
  void updateSearchName(String name, {String? path}) {
    final targetPath = path ?? _editingPath;
    if (targetPath == null) return;

    state = state.copyWith(
      results: state.results.map((item) {
        if (item.fullPath == targetPath) {
          return item.copyWith(rawName: name);
        }
        return item;
      }).toList(),
    );
  }

  void toggleSelection(String path) {
    final current = Set<String>.from(state.selectedPaths);
    if (current.contains(path)) {
      current.remove(path);
    } else {
      current.add(path);
    }
    state = state.copyWith(selectedPaths: current);
  }

  void setResults(List<DiscoveryResult> results) {
    state = state.copyWith(
      results: results,
      selectedPaths: results.map((r) => r.fullPath).toSet(),
    );
  }

  void toggleAll(bool selected) {
    final allPaths = selected
        ? state.results.map((r) => r.fullPath).toSet()
        : <String>{};
    state = state.copyWith(selectedPaths: allPaths);
  }

  Future<void> scanDirectory(String directoryPath) async {
    state = state.copyWith(isScanning: true, currentPath: directoryPath);
    try {
      final results = await ref
          .read(librairyScanProvider)
          .execute(directoryPath);
      state = state.copyWith(
        results: results,
        selectedPaths: results.map((r) => r.fullPath).toSet(),
        isScanning: false,
      );
    } catch (e) {
      state = state.copyWith(isScanning: false);
    }
  }

  Future<void> importSelectedGames() async {
    final toImport = state.results
        .where((r) => state.selectedPaths.contains(r.fullPath))
        .toList();

    if (toImport.isEmpty) return;

    state = state.copyWith(isSaving: true);
    try {
      final saveUseCase = ref.read(saveGameUseCaseProvider);
      for (final item in toImport) {
        final gameModel = GameWithDetailsModel.fromDiscovery(item);
        await saveUseCase.execute(gameModel);
      }
      reset();
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  void reset() {
    _editingPath = null;
    state = ImportAllState();
  }
}
