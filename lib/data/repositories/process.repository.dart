import 'dart:io';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/data/utils/scan_helper.dart';
import 'package:game_launcher/domain/entities/discovery_result.entity.dart';
import 'package:game_launcher/domain/repositories/process.repository.dart';

class ProcessRepositoryImpl implements ProcessRepository {
  final FileSystem _fileSystem;

  ProcessRepositoryImpl({FileSystem? fileSystem})
    : _fileSystem = fileSystem ?? const LocalFileSystem();

  @override
  Future<void> openExecutable(String path) async {
    AppLogger.info(
      "ProcessRepo: Tentative d'ouverture de l'exécutable à: $path",
    );

    final file = _fileSystem.file(path);
    if (!await file.exists()) {
      AppLogger.error(
        "ProcessRepo: Échec du lancement - Fichier introuvable sur le disque: $path",
      );
      throw Exception("Le fichier est introuvable : $path");
    }

    try {
      final workingDir = file.parent.path;
      AppLogger.debug(
        "ProcessRepo: Définition du répertoire de travail (CWD): $workingDir",
      );

      // Mode detached pour que le launcher puisse se fermer sans tuer le jeu
      await Process.start(
        path,
        [],
        mode: ProcessStartMode.detached,
        workingDirectory: workingDir,
      );

      AppLogger.info(
        "ProcessRepo: Processus lancé avec succès en mode détaché.",
      );
    } catch (e, stack) {
      AppLogger.error(
        "ProcessRepo: Erreur système lors du lancement de l'exécutable",
        e,
        stack,
      );
      rethrow;
    }
  }

  @override
  Future<bool> isProcessRunning(String exeName) async {
    if (exeName.isEmpty) return false;

    try {
      AppLogger.debug(
        "ProcessRepo: Vérification si le processus '$exeName' est actif via tasklist...",
      );

      final result = await Process.run('tasklist', [
        '/FI',
        'IMAGENAME eq $exeName',
        '/NH',
      ]);

      final isRunning = result.stdout?.toString().contains(exeName) ?? false;

      if (isRunning) {
        AppLogger.debug(
          "ProcessRepo: Processus '$exeName' trouvé dans la liste des tâches.",
        );
      }

      return isRunning;
    } catch (e) {
      AppLogger.warning(
        "ProcessRepo: Impossible d'interroger la liste des processus: $e",
      );
      return false;
    }
  }

  @override
  Future<List<DiscoveryResult>> scanForExecutables(String rootPath) async {
    AppLogger.info("ProcessRepo: Démarrage du scan récursif sur: $rootPath");

    final directory = _fileSystem.directory(rootPath);
    if (!await directory.exists()) {
      AppLogger.warning(
        "ProcessRepo: Le répertoire racine de scan n'existe pas: $rootPath",
      );
      return [];
    }

    final results = <DiscoveryResult>[];
    int scannedCount = 0;

    try {
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        scannedCount++;

        // Log de progression tous les 100 fichiers pour ne pas inonder la console
        if (scannedCount % 100 == 0) {
          AppLogger.debug(
            "ProcessRepo: Scan en cours... $scannedCount fichiers analysés.",
          );
        }

        if (entity is! File) continue;

        final path = entity.path;
        final segments = _fileSystem.path.split(path);

        if (ExecutableFilter.isGameExecutable(path, segments)) {
          AppLogger.info(
            "ProcessRepo: Exécutable de jeu potentiel trouvé: ${_fileSystem.path.basename(path)}",
          );
          results.add(_mapToDiscoveryResult(path, segments));
        }
      }

      AppLogger.info(
        "ProcessRepo: Scan terminé. $scannedCount fichiers parcourus, ${results.length} jeux détectés.",
      );
    } catch (e, stack) {
      AppLogger.error(
        "ProcessRepo: Erreur pendant le parcours du système de fichiers",
        e,
        stack,
      );
    }

    return results;
  }

  DiscoveryResult _mapToDiscoveryResult(String path, List<String> segments) {
    return DiscoveryResult(
      rawName: _fileSystem.path.basename(path),
      fullPath: path,
      pathSegments: segments
          .where((s) => !s.contains(':') && s.isNotEmpty)
          .toList(),
    );
  }
}
