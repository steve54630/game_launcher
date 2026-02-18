import 'dart:io';
import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/domain/repositories/process.repository.dart';
import '../../domain/entities/discovery_result.entity.dart';

class ProcessRepositoryImpl implements ProcessRepository {
  @override
  Future<void> openExecutable(String path) async {
    try {
      final file = File(path);
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
  Future<bool> isProcessRunning(String path) async {
    try {
      final fileName = File(path).uri.pathSegments.last;
      final result = await Process.run('tasklist', [
        '/FI',
        'IMAGENAME eq $fileName',
      ]);

      return result.stdout.toString().contains(fileName);
    } catch (e) {
      AppLogger.error("Erreur lors de la vérification du processus", e);
      return false;
    }
  }

  @override
  Future<List<DiscoveryResult>> scanForExecutables(String directoryPath) async {
    final List<DiscoveryResult> discovered = [];
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) return [];

      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File && entity.path.toLowerCase().endsWith('.exe')) {
          final fileName = entity.uri.pathSegments.last;
          final nameLower = fileName.toLowerCase();

          // Filtres d'exclusion de base
          if (nameLower.contains('unins') ||
              nameLower.contains('helper') ||
              nameLower.contains('crashpad') ||
              nameLower.contains('setup')) {
            continue;
          }

          // Découpage du chemin pour les segments (ComboBox de l'UI)
          // On transforme "C:\Games\Doom\bin\game.exe" en ["Games", "Doom", "bin"]
          final segments = entity.parent.path
              .split(Platform.pathSeparator)
              .where(
                (s) => s.isNotEmpty && !s.contains(':'),
              ) // On ignore le disque (C:)
              .toList();

          discovered.add(
            DiscoveryResult(
              rawName: fileName,
              fullPath: entity.path,
              pathSegments: segments,
            ),
          );
        }
      }
      return discovered;
    } catch (e, stack) {
      AppLogger.error(
        "Erreur lors du scan du dossier : $directoryPath",
        e,
        stack,
      );
      return [];
    }
  }
}
