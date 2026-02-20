import 'dart:convert';
import 'package:game_launcher/domain/entities/igbd_genre.entity.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';

class IgdbSearchResultModel extends IgdbSearchResult {
  IgdbSearchResultModel({
    required super.igdbId,
    required super.name,
    super.coverUrl,
    super.backgroundUrl,
    super.summary,
    super.screenshots,
    super.youtubeVideoId,
    super.releaseDate,
    super.genre,
  });

  factory IgdbSearchResultModel.fromJson(Map<String, dynamic> json) {
    // 1. Extraction sécurisée de la vidéo (évite RangeError)
    final videosList = json['videos'] as List?;
    // On vérifie la structure interne pour être sûr
    final videoId = (videosList != null && videosList.isNotEmpty)
        ? (videosList.first as Map<String, dynamic>)['video_id'] as String?
        : null;

    // 2. Extraction sécurisée du genre
    final genresList = json['genres'] as List?;
    IgdbGenre? genreResult;

    if (genresList != null && genresList.isNotEmpty) {
      final firstGenre = genresList.first as Map<String, dynamic>;
      // IMPORTANT : On instancie l'entité, on ne passe pas la Map brute
      genreResult = IgdbGenre(
        id: firstGenre['id'] as int,
        name: firstGenre['name'] as String,
      );
    }

    // 3. Extraction des images (Screenshots & Cover)
    final coverData = json['cover'] as Map<String, dynamic>?;
    final coverUrl = (coverData != null && coverData['url'] != null)
        ? _parseImageUrl(coverData['url'] as String)
        : null;

    final screenshots = <String>[];
    if (json['screenshots'] is List) {
      for (var shot in (json['screenshots'] as List)) {
        if (shot is Map && shot['url'] != null) {
          screenshots.add(_parseImageUrl(shot['url'] as String));
        }
      }
    }

    return IgdbSearchResultModel(
      igdbId: json['id'] as int,
      name: json['name'] as String,
      coverUrl: coverUrl,
      summary: json['summary'] as String?,
      screenshots: screenshots,
      youtubeVideoId: videoId,
      releaseDate: json['first_release_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['first_release_date'] as int) * 1000,
            )
          : null,
      genre: genreResult,
    );
  }

  // Dans IgdbSearchResultModel
  Map<String, dynamic> toCacheMap() {
    return {
      'igdb_id': igdbId,
      'name': name,
      'cover_url': coverUrl,
      'summary': summary,
      // SQLite ne stocke pas de listes, on sérialise en JSON String
      'screenshot_urls': jsonEncode(screenshots),
      'video_id': youtubeVideoId,
      // Stockage au format ISO8601 pour faciliter les tris SQL
      'release_date': releaseDate?.toIso8601String(),
      'genre_id': genre?.id, // On enregistre l'ID pour la FK
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  static String _parseImageUrl(String url) {
    if (url.startsWith('//')) {
      url = 'https:$url';
    }
    // Note: t_720p fonctionne bien pour les covers et screenshots
    return url.replaceAll('t_thumb', 't_720p');
  }
}
