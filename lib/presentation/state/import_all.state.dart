import 'package:game_launcher/domain/entities/discovery_result.entity.dart';

class ImportAllState {
  final List<DiscoveryResult> results;
  final Set<String>
  selectedPaths; // Utiliser un Set pour la performance des lookups
  final bool isScanning;
  final bool isSaving;
  final String? error;
  final String currentPath;

  ImportAllState({
    this.results = const [],
    this.selectedPaths = const {},
    this.isScanning = false,
    this.error,
    this.currentPath = "",
    this.isSaving = false,
  });

  ImportAllState copyWith({
    List<DiscoveryResult>? results,
    Set<String>? selectedPaths,
    bool? isScanning,
    String? error,
    String currentPath = "",
    bool? isSaving,
  }) {
    return ImportAllState(
      results: results ?? this.results,
      selectedPaths: selectedPaths ?? this.selectedPaths,
      isScanning: isScanning ?? this.isScanning,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      currentPath: currentPath,
    );
  }
}
