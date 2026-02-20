import 'package:game_launcher/domain/entities/discovery_result.entity.dart';
import 'package:game_launcher/domain/repositories/process.repository.dart';
import 'package:game_launcher/core/utils/logger.dart';

class ScanLibrarySource {
  final ProcessRepository repository;

  ScanLibrarySource(this.repository);

  Future<List<DiscoveryResult>> execute(String path) async {
    AppLogger.info(
      "ScanLibrarySource: Démarrage du scan dans le répertoire: $path",
    );

    if (path.isEmpty) {
      AppLogger.warning(
        "ScanLibrarySource: Le chemin fourni est vide. Abandon du scan.",
      );
      return [];
    }

    try {
      // Mesure du temps pour évaluer les performances de l'I/O
      final stopWatch = Stopwatch()..start();

      final results = await repository.scanForExecutables(path);

      stopWatch.stop();

      AppLogger.info(
        "ScanLibrarySource: Scan terminé en ${stopWatch.elapsedMilliseconds}ms. "
        "${results.length} exécutable(s) potentiel(s) trouvé(s).",
      );

      // Log détaillé des résultats pour faciliter le debug de l'algo de détection
      if (results.isNotEmpty) {
        for (var i = 0; i < results.length; i++) {
          AppLogger.info(
            "ScanLibrarySource: [#$i] Trouvé: ${results.elementAt(i).fullPath}",
          );
        }
      } else {
        AppLogger.warning(
          "ScanLibrarySource: Aucun exécutable trouvé dans le répertoire spécifié.",
        );
      }

      return results.toList();
    } catch (e) {
      AppLogger.error(
        "ScanLibrarySource: Erreur lors du scan du répertoire '$path'",
        e,
      );
      // En tant que dev, on rethrow pour que l'UI puisse réagir (ex: dialogue d'erreur de droits)
      rethrow;
    }
  }
}
