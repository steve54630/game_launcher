import 'dart:convert';
import 'package:game_launcher/core/utils/database_helper.dart';
import 'package:game_launcher/core/utils/logger.dart';
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
    AppLogger.info(
      "IgdbCache: Début de la mise en cache pour '${metadata.name}' (ID: ${metadata.igdbId})",
    );

    try {
      final db = await _dbHelper.database;

      // 1. Gérer les screenshots (Téléchargement local)
      List<String> localPaths = [];
      if (metadata.screenshots.isNotEmpty) {
        AppLogger.info(
          "IgdbCache: Tentative de téléchargement de ${metadata.screenshots.length} screenshots...",
        );
        try {
          for (var url in metadata.screenshots) {
            final path = await ImageDownloaderService.downloadAndSaveImage(
              url,
              'game_${metadata.igdbId}',
            );
            if (path != null) {
              localPaths.add(path);
            }
          }
          AppLogger.info(
            "IgdbCache: ${localPaths.length} images sauvegardées localement.",
          );
        } catch (e) {
          AppLogger.warning(
            "IgdbCache: Échec partiel du téléchargement images (ID: ${metadata.igdbId}): $e",
          );
        }
      }

      final finalScreenshots = localPaths.isNotEmpty
          ? localPaths
          : metadata.screenshots;

      // 2. S'assurer que le genre existe
      if (metadata.genre != null) {
        AppLogger.debug(
          "IgdbCache: Synchronisation du genre '${metadata.genre!.name}'",
        );
        await db.insert('genres', {
          'id': metadata.genre!.id,
          'name': metadata.genre!.name,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      // 3. Insertion/Update du cache principal
      AppLogger.info(
        "IgdbCache: Écriture des métadonnées enrichies en base (Video: ${metadata.youtubeVideoId != null}, Date: ${metadata.releaseDate != null})",
      );

      await db.insert('igdb_cache', {
        'igdb_id': metadata.igdbId,
        'name': metadata.name,
        'cover_url': metadata.coverUrl ?? '',
        'summary': metadata.summary ?? 'Pas de description disponible.',
        'screenshot_urls': jsonEncode(finalScreenshots),
        'video_id': metadata.youtubeVideoId ?? '',
        'release_date': metadata.releaseDate?.toIso8601String() ?? '',
        'genre_id': metadata.genre?.id,
        'updated_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      AppLogger.info(
        "IgdbCache: Succès de la mise en cache pour '${metadata.name}'",
      );
    } catch (e, stack) {
      AppLogger.error(
        "IgdbCache: Erreur fatale lors de saveToCache (ID: ${metadata.igdbId})",
        e,
        stack,
      );
      rethrow;
    }
  }

  @override
  Future<IgdbSearchResult?> getCachedMetadata(int igdbId) async {
    AppLogger.debug("IgdbCache: Lecture du cache pour ID: $igdbId");
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

      if (results.isEmpty) {
        AppLogger.info(
          "IgdbCache: Aucun résultat trouvé en cache pour ID: $igdbId",
        );
        return null;
      }

      final map = results.first;
      AppLogger.info(
        "IgdbCache: Données récupérées du cache pour '${map['name']}'",
      );

      return IgdbSearchResult(
        igdbId: map['igdb_id'] as int,
        name: map['name'] as String,
        coverUrl: map['cover_url'] as String?,
        summary: map['summary'] as String?,
        screenshots: List<String>.from(
          jsonDecode(map['screenshot_urls'] as String),
        ),
        // On récupère les nouveaux champs ici
        youtubeVideoId: (map['video_id'] as String?)?.isEmpty ?? true
            ? null
            : map['video_id'] as String,
        releaseDate: (map['release_date'] as String?)?.isEmpty ?? true
            ? null
            : DateTime.tryParse(map['release_date'] as String),
        genre: map['genre_name'] != null
            ? IgdbGenre(
                id: map['genre_id'] as int,
                name: map['genre_name'] as String,
              )
            : null,
      );
    } catch (e, stack) {
      AppLogger.error(
        "IgdbCache: Erreur lors de la lecture du cache (ID: $igdbId)",
        e,
        stack,
      );
      return null;
    }
  }

  @override
  Future<void> deleteFromCache(int igdbId) async {
    AppLogger.warning("IgdbCache: Suppression du cache pour ID: $igdbId");
    try {
      final db = await _dbHelper.database;
      final count = await db.delete(
        'igdb_cache',
        where: 'igdb_id = ?',
        whereArgs: [igdbId],
      );

      if (count > 0) {
        AppLogger.info("IgdbCache: Cache supprimé avec succès.");
      } else {
        AppLogger.debug(
          "IgdbCache: Rien à supprimer, le cache était déjà vide.",
        );
      }
    } catch (e, stack) {
      AppLogger.error(
        "IgdbCache: Erreur lors de la suppression (ID: $igdbId)",
        e,
        stack,
      );
      rethrow;
    }
  }
}
