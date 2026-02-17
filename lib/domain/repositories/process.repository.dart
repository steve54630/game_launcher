import 'package:game_launcher/domain/entities/discovery_result.entity.dart';

abstract interface class ProcessRepository {
  /// Ouvre un processus système à partir d'un chemin
  Future<void> openExecutable(String path);

  /// Optionnel : Vérifie si un processus est toujours en cours
  Future<bool> isProcessRunning(String path);

  // Recherche des exécutables dans un dossier (logique de scan)
  // On renvoie une liste de chemins vers des .exe trouvés
  Future<List<DiscoveryResult>> scanForExecutables(String directoryPath);
}
