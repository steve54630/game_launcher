import 'package:game_launcher/domain/entities/discovery_result.entity.dart';

class ImportAllState {
  final List<DiscoveryResult> items; // La source de vérité unique
  final bool isScanning;
  final bool isSaving;
  final String? error;
  final String currentScanningPath; // Juste pour le feedback visuel du scan

  ImportAllState({
    this.items = const [],
    this.isScanning = false,
    this.isSaving = false,
    this.error,
    this.currentScanningPath = "",
  });

  // Getters calculés pour éviter de stocker des variables redondantes
  List<DiscoveryResult> get selectedItems =>
      items.where((e) => e.isSelected).toList();
  List<DiscoveryResult> get readyToImport =>
      items.where((e) => e.isReady).toList();
  double get progress => items.isEmpty
      ? 0
      : items.where((e) => e.status != DiscoveryStatus.pending).length /
            items.length;

  ImportAllState copyWith({
    List<DiscoveryResult>? items,
    bool? isScanning,
    bool? isSaving,
    String? error,
    String? currentScanningPath,
  }) {
    return ImportAllState(
      items: items ?? this.items,
      isScanning: isScanning ?? this.isScanning,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      currentScanningPath: currentScanningPath ?? this.currentScanningPath,
    );
  }
}
