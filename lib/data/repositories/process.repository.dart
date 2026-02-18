import 'dart:io';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/domain/repositories/process.repository.dart';
import '../../domain/entities/discovery_result.entity.dart';

class ProcessRepositoryImpl implements ProcessRepository {
  final FileSystem _fileSystem;

  // Par défaut, utilise le vrai système de fichiers (prod)
  // En test, on injectera un MemoryFileSystem
  ProcessRepositoryImpl({FileSystem? fileSystem})
    : _fileSystem = fileSystem ?? const LocalFileSystem();

  @override
  Future<void> openExecutable(String path) async {
    try {
      final file = _fileSystem.directory(path);
      if (!await file.exists()) {
        throw Exception("Le fichier est introuvable : $path");
      }

      await Process.start(
        path,
        [],
        mode: ProcessStartMode.detached,
        workingDirectory: file.parent.path,
      );

      AppLogger.info("Exécutable lancé : $path");
    } catch (e, stack) {
      AppLogger.error("Erreur lors du lancement de l'exécutable", e, stack);
      rethrow;
    }
  }

  @override
  Future<bool> isProcessRunning(String exeName) async {
    if (exeName.isEmpty) return false; // Sécurité immédiate

    try {
      final result = await Process.run('tasklist', [
        '/FI',
        'IMAGENAME eq $exeName',
        '/NH',
      ]);

      if (result.stdout == null) return false;

      // On vérifie que le nom exact est dans la sortie et non une simple portion
      return result.stdout.toString().contains(exeName);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<DiscoveryResult>> scanForExecutables(String rootPath) async {
    final directory = _fileSystem.directory(rootPath);
    if (!await directory.exists()) return [];

    final List<DiscoveryResult> results = [];

    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File) {
        final path = entity.path;

        if (!path.toLowerCase().endsWith('.exe')) continue;

        final segments = _fileSystem.path.split(path);

        // FILTRE : On ignore si un des dossiers parents commence par '.'
        if (segments.any((s) => s.startsWith('.') && s != '.' && s != '..')) {
          continue;
        }

        final fileName = _fileSystem.path.basename(path);
        if (_isFiltered(fileName)) continue;

        final relativeSegments = segments
            .where((s) => !s.contains(':') && s.isNotEmpty)
            .toList();

        results.add(
          DiscoveryResult(
            rawName: fileName,
            fullPath: path,
            pathSegments: relativeSegments,
          ),
        );
      }
    }
    return results;
  }

  bool _isFiltered(String name) {
    final lowerName = name.toLowerCase();
    const filters = ['unins', 'crashpad', 'helper', 'setup'];
    return filters.any((f) => lowerName.contains(f));
  }
}
