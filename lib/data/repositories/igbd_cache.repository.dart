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
          "IgdbCache: Téléchargement parallèle de ${metadata.screenshots.length} screenshots...",
        );

        final downloadTasks = metadata.screenshots.map((url) async {
          try {
            return await ImageDownloaderService.downloadAndSaveImage(
              url,
              'game_${metadata.igdbId}',
            );
          } catch (e) {
            AppLogger.warning(
              "IgdbCache: Échec téléchargement image ($url): $e",
            );
            return null; // On retourne null pour filtrer après
          }
        });

        final results = await Future.wait(downloadTasks);
        localPaths = results.whereType<String>().toList();
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
    try {
      final db = await _dbHelper.database;

      // 1. Suppression physique des fichiers
      await ImageDownloaderService.deleteFolder('game_$igdbId');

      // 2. Suppression SQL
      await db.delete('igdb_cache', where: 'igdb_id = ?', whereArgs: [igdbId]);

      AppLogger.info("IgdbCache: Nettoyage complet réussi pour ID: $igdbId");
    } catch (e, stack) {
      AppLogger.error("IgdbCache: Erreur lors de la suppression", e, stack);
      rethrow;
    }
  }
}
