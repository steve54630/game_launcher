import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/core/utils/scanner_heuristic.dart';
import 'package:game_launcher/domain/entities/discovery_result.entity.dart';
import 'package:game_launcher/domain/repositories/process.repository.dart';

class ScanLibrarySource {
  final ProcessRepository repository;

  ScanLibrarySource(this.repository);

  Future<List<DiscoveryResult>> execute(String path) async {
    AppLogger.info("ScanLibrarySource: Démarrage du scan dans: $path");

    if (path.isEmpty) return [];

    try {
      final stopWatch = Stopwatch()..start();

      // 1. Récupération brute de tous les .exe (via ton Repo existant)
      final rawFiles = await repository.scanForExecutables(path);

      // 2. Filtrage intelligent : Un seul gagnant par dossier
      final Map<String, (DiscoveryResult result, double score)> bestMatches =
          {};

      for (var item in rawFiles) {
        // On récupère le dossier parent pour grouper
        final fileUri = Uri.file(item.fullPath);
        final folderName =
            fileUri.pathSegments[fileUri.pathSegments.length - 2];
        final folderPath = fileUri.resolve('.').toFilePath();

        final score = ScannerHeuristics.calculateScore(
          fileName: item.rawName,
          folderName: folderName,
          fileSizeInBytes: item.fileSize,
        );

        // On ne garde que si le score est décent (> 0.15)
        if (score > 0.15) {
          if (!bestMatches.containsKey(folderPath) ||
              score > bestMatches[folderPath]!.$2) {
            bestMatches[folderPath] = (item, score);
          }
        }
      }

      final filteredResults = bestMatches.values.map((e) => e.$1).toList();

      stopWatch.stop();
      AppLogger.info(
        "ScanLibrarySource: Scan terminé en ${stopWatch.elapsedMilliseconds}ms. "
        "Post-filtrage : ${filteredResults.length} exécutables retenus (sur ${rawFiles.length}).",
      );

      return filteredResults;
    } catch (e) {
      AppLogger.error("ScanLibrarySource: Erreur lors du scan", e);
      rethrow;
    }
  }
}
