import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:game_launcher/core/utils/logger.dart';

class ImageDownloaderService {
  static final Dio _dio = Dio();

  static Future<String?> downloadAndSaveImage(
    String url,
    String folderName,
  ) async {
    try {
      if (url.isEmpty) return null;

      final appDir = await getApplicationSupportDirectory();
      // On crée le dossier s'il n'existe pas
      final saveDir = Directory(p.join(appDir.path, 'media', folderName));
      if (!await saveDir.exists()) await saveDir.create(recursive: true);

      final fileName = p.basename(Uri.parse(url).path);
      final savePath = p.join(saveDir.path, fileName);

      // Téléchargement direct vers le fichier
      final response = await _dio.download(url, savePath);

      if (response.statusCode == 200) {
        return savePath;
      }
      return null;
    } catch (e) {
      AppLogger.error("Échec du téléchargement Dio: $url", e);
      return null;
    }
  }
}
