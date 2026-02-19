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
    final file = _fileSystem.file(path);
    if (!await file.exists()) {
      throw Exception("Le fichier est introuvable : $path");
    }

    try {
      await Process.start(
        path,
        [],
        mode: ProcessStartMode.detached,
        workingDirectory: file.parent.path,
      );
      AppLogger.info("Exécutable lancé : $path");
    } catch (e, stack) {
      AppLogger.error("Erreur lors du lancement", e, stack);
      rethrow;
    }
  }

  @override
  Future<bool> isProcessRunning(String exeName) async {
    if (exeName.isEmpty) return false;

    try {
      final result = await Process.run('tasklist', [
        '/FI',
        'IMAGENAME eq $exeName',
        '/NH',
      ]);
      return result.stdout?.toString().contains(exeName) ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<DiscoveryResult>> scanForExecutables(String rootPath) async {
    final directory = _fileSystem.directory(rootPath);
    if (!await directory.exists()) return [];

    final results = <DiscoveryResult>[];

    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;

      final path = entity.path;
      final segments = _fileSystem.path.split(path);

      if (ExecutableFilter.isGameExecutable(path, segments)) {
        results.add(_mapToDiscoveryResult(path, segments));
      }
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
