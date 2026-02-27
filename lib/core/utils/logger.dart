import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AppLogger {
  static Logger? _logger;
  static const int maxLogFiles = 5; // On garde les 5 dernières sessions

  static Future<void> init() async {
    final baseDir = await getApplicationSupportDirectory();
    final logsDir = Directory(join(baseDir.path, 'logs'));

    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }

    // 1. Nettoyage des vieux logs (on ne garde que les plus récents)
    await _cleanupOldLogs(logsDir);

    // 2. Création d'un nom de fichier unique pour cette session
    // Format: logs_2026-02-24_16-30.txt
    final timestamp = DateTime.now()
        .toString()
        .replaceAll(RegExp(r'[: ]'), '-')
        .split('.')
        .first;

    final logFile = File(join(logsDir.path, 'log_$timestamp.txt'));

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        FileOutput(file: logFile, overrideExisting: true),
      ]),
    );

    info("Démarrage d'une nouvelle session de logs : ${logFile.path}");
  }

  /// Garde uniquement les [maxLogFiles] fichiers les plus récents
  static Future<void> _cleanupOldLogs(Directory logsDir) async {
    try {
      final files = await logsDir
          .list()
          .where((entity) => entity is File)
          .toList();

      if (files.length >= maxLogFiles) {
        // Tri par date de modification (du plus vieux au plus récent)
        files.sort(
          (a, b) => (a as File).lastModifiedSync().compareTo(
            (b as File).lastModifiedSync(),
          ),
        );

        // Supprime les fichiers les plus anciens pour respecter le quota
        final filesToDelete = files.take(files.length - maxLogFiles + 1);
        for (var file in filesToDelete) {
          await file.delete();
        }
      }
    } catch (e) {
      // On ne peut pas loguer l'erreur ici car le logger n'est pas prêt,
      // donc on utilise print en dernier recours
      debugPrint("Erreur lors du nettoyage des logs: $e");
    }
  }

  // Wrappers standards
  static void info(String message) => _logger?.i(message);
  static void warning(String message) => _logger?.w(message);
  static void debug(String message) => _logger?.d(message);
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.e(message, error: error, stackTrace: stackTrace);
  }
}
