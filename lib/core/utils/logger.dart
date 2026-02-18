import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AppLogger {
  static Logger? _logger;

  // On initialise le logger de manière asynchrone car on doit attendre le chemin du fichier
  static Future<void> init() async {
    final directory = await getApplicationSupportDirectory();
    final logFile = File(join(directory.path, 'logs.txt'));

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: MultiOutput([ConsoleOutput(), FileOutput(file: logFile)]),
    );
  }

  static void info(String message) => _logger?.i(message);
  static void warning(String message) => _logger?.w(message);
  static void debug(String message) => _logger?.d(message);
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.e(message, error: error, stackTrace: stackTrace);
  }
}
