class DiscoveryResult {
  final String rawName; // Nom du dossier ou du .exe
  final String fullPath; // Chemin absolu vers l'exécutable
  final double
  confidenceScore; // Score de certitude de ton heuristique (0.0 à 1.0)

  DiscoveryResult({
    required this.rawName,
    required this.fullPath,
    required this.confidenceScore,
  });
}
