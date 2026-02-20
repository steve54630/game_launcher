import 'dart:convert';
import 'package:game_launcher/core/utils/database_helper.dart';
import 'package:game_launcher/core/utils/logger.dart'; // Import nécessaire
import 'package:game_launcher/data/utils/image_downloader.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/domain/entities/igbd_genre.entity.dart';
import 'package:game_launcher/domain/repositories/igbd_cache.repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class IgdbCacheRepositoryImpl implements IgdbCacheRepository {
  final DatabaseHelper _dbHelper;
  IgdbCacheRepositoryImpl(this._dbHelper);

  @override
  Future<void> saveToCache(IgdbSearchResult metadata) async {
    try {
      final db = await _dbHelper.database;

      // 1. Gérer les screenshots
      List<String> localPaths = [];
      try {
        if (metadata.screenshots.isNotEmpty) {
          for (var url in metadata.screenshots) {
            final path = await ImageDownloaderService.downloadAndSaveImage(
              url,
              'game_${metadata.igdbId}',
            );
            if (path != null) localPaths.add(path);
          }
        }
      } catch (e) {
        AppLogger.warning(
          "Échec téléchargement images (ID: ${metadata.igdbId}): $e",
        );
      }

      final finalScreenshots = localPaths.isNotEmpty
          ? localPaths
          : metadata.screenshots;

      // 2. S'assurer que le genre existe avant d'insérer le cache
      if (metadata.genre != null) {
        await db.insert(
          'genres',
          {'id': metadata.genre!.id, 'name': metadata.genre!.name},
          conflictAlgorithm:
              ConflictAlgorithm.ignore, // On ne l'écrase pas s'il existe
        );
      }

      // 3. Insertion avec vérification des données critiques
      await db.insert('igdb_cache', {
        'igdb_id': metadata.igdbId,
        'name': metadata.name,
        'cover_url': metadata.coverUrl ?? '', // Évite le NULL si possible
        'summary': metadata.summary ?? 'Pas de description disponible.',
        'screenshot_urls': jsonEncode(finalScreenshots),
        'video_id': metadata.youtubeVideoId ?? '',
        'release_date': metadata.releaseDate?.toIso8601String() ?? '',
        'genre_id': metadata
            .genre
            ?.id, // Sera NULL si pas de genre, ce qui est géré par ton LEFT JOIN
        'updated_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      AppLogger.debug("Cache IGDB validé pour: ${metadata.name}");
    } catch (e, stack) {
      AppLogger.error(
        "Erreur fatale cache IGDB (ID: ${metadata.igdbId})",
        e,
        stack,
      );
      // Ici, on pourrait rethrow car si le cache échoue, l'import est "sale"
      rethrow;
    }
  }

  @override
  Future<IgdbSearchResult?> getCachedMetadata(int igdbId) async {
    try {
      final db = await _dbHelper.database;

      final results = await db.rawQuery(
        '''
        SELECT c.*, g.name as genre_name 
        FROM igdb_cache c 
        LEFT JOIN genres g ON c.genre_id = g.id 
        WHERE c.igdb_id = ?
      ''',
        [igdbId],
      );

      if (results.isEmpty) return null;
      final map = results.first;

      return IgdbSearchResult(
        igdbId: map['igdb_id'] as int,
        name: map['name'] as String,
        coverUrl: map['cover_url'] as String?,
        summary: map['summary'] as String?,
        screenshots: List<String>.from(
          jsonDecode(map['screenshot_urls'] as String),
        ),
        genre: map['genre_name'] != null
            ? IgdbGenre(
                id: map['genre_id'] as int,
                name: map['genre_name'] as String,
              )
            : null,
      );
    } catch (e, stack) {
      AppLogger.error(
        "Erreur lors de la lecture du cache IGDB (ID: $igdbId)",
        e,
        stack,
      );
      return null; // En cas d'erreur DB, on fait comme si le cache était vide
    }
  }

  @override
  Future<void> deleteFromCache(int igdbId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('igdb_cache', where: 'igdb_id = ?', whereArgs: [igdbId]);
    } catch (e, stack) {
      AppLogger.error(
        "Erreur lors de la suppression du cache IGDB (ID: $igdbId)",
        e,
        stack,
      );
      rethrow; // Ici on rethrow car une suppression qui échoue est anormal
    }
  }
}
