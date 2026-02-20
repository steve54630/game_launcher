import 'dart:convert';
import 'package:game_launcher/core/utils/database_helper.dart';
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
    final db = await _dbHelper.database;

    List<String> localPaths = [];
    try {
      // On tente le téléchargement mais on ne bloque pas si ça échoue (cas des tests)
      for (var url in metadata.screenshots) {
        final path = await ImageDownloaderService.downloadAndSaveImage(
          url,
          'game_${metadata.igdbId}',
        );
        if (path != null) localPaths.add(path);
      }
    } catch (_) {}

    // Si on n'a pas pu télécharger (ex: environnement de test), on garde les URLs originales
    final finalScreenshots = localPaths.isNotEmpty
        ? localPaths
        : metadata.screenshots;

    await db.insert('igdb_cache', {
      'igdb_id': metadata.igdbId,
      'name': metadata.name,
      'cover_url': metadata.coverUrl,
      'summary': metadata.summary,
      'screenshot_urls': jsonEncode(finalScreenshots),
      'genre_id': metadata.genre?.id, // Utilisation de l'ID pour la jointure
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<IgdbSearchResult?> getCachedMetadata(int igdbId) async {
    final db = await _dbHelper.database;

    // Jointure avec les genres pour récupérer le nom
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
  }

  @override
  Future<void> deleteFromCache(int igdbId) async {
    final db = await _dbHelper.database;
    await db.delete('igdb_cache', where: 'igdb_id = ?', whereArgs: [igdbId]);
  }
}
