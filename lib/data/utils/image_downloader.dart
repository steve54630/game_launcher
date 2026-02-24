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

      // Nettoyage de l'URL IGDB (forcer le HTTPS si nécessaire et haute résolution)
      final cleanUrl = url.startsWith('//') ? 'https:$url' : url;

      final appDir = await getApplicationSupportDirectory();
      final saveDir = Directory(p.join(appDir.path, 'media', folderName));

      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      final fileName = p.basename(Uri.parse(cleanUrl).path);
      final savePath = p.join(saveDir.path, fileName);

      final response = await _dio.download(cleanUrl, savePath);

      if (response.statusCode == 200) {
        return savePath;
      }
      return null;
    } catch (e) {
      AppLogger.error("ImageDownloader: Échec du téléchargement: $url", e);
      return null;
    }
  }

  static Future<void> deleteFolder(String folderName) async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final dir = Directory(p.join(appDir.path, 'media', folderName));

      if (await dir.exists()) {
        AppLogger.warning(
          "ImageDownloader: Suppression physique du dossier media/$folderName",
        );
        await dir.delete(recursive: true);
      }
    } catch (e) {
      AppLogger.error(
        "ImageDownloader: Erreur lors de la suppression du dossier $folderName",
        e,
      );
    }
  }
}
