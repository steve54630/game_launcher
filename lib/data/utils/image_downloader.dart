import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:game_launcher/core/utils/logger.dart';

class ImageDownloaderService {
  static Future<String?> downloadAndSaveImage(String url, String folderName) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      // Dossier : AppData/Roaming/game_launcher/media/folderName/
      final appDir = await getApplicationSupportDirectory();
      final saveDir = Directory(p.join(appDir.path, 'media', folderName));
      
      if (!await saveDir.exists()) await saveDir.create(recursive: true);

      // Nom de fichier unique basé sur l'URL IGDB
      final fileName = p.basename(Uri.parse(url).path);
      final file = File(p.join(saveDir.path, fileName));
      
      await file.writeAsBytes(response.bodyBytes);
      return file.path; // On renvoie le chemin local
    } catch (e) {
      AppLogger.error("Échec du téléchargement image: $url", e);
      return null;
    }
  }
}