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
  });

  /// Factory pour transformer le JSON d'IGDB
  factory IgdbSearchResultModel.fromJson(Map<String, dynamic> json) {
    // Extraction de l'URL de la cover (IGDB renvoie un objet)
    final coverData = json['cover'] as Map<String, dynamic>?;
    final coverUrl = coverData != null
        ? _parseImageUrl(coverData['url'] as String)
        : null;

    // Extraction des screenshots
    final screenshots = <String>[];
    if (json['screenshots'] != null) {
      for (var shot in (json['screenshots'] as List)) {
        screenshots.add(_parseImageUrl(shot['url'] as String));
      }
    }

    // Extraction de la vidéo YouTube (IGDB renvoie une liste de vidéos)
    final videos = json['videos'] as List?;
    final videoId = (videos != null && videos.isNotEmpty)
        ? videos.first['video_id'] as String?
        : null;

    return IgdbSearchResultModel(
      igdbId: json['id'] as int,
      name: json['name'] as String,
      coverUrl: coverUrl,
      summary: json['summary'] as String?,
      screenshots: screenshots,
      youtubeVideoId: videoId,
    );
  }

  /// Helper privé pour s'assurer que les URLs d'images sont en haute résolution (720p ou 1080p)
  /// IGDB renvoie souvent du "//images..." par défaut.
  static String _parseImageUrl(String url) {
    if (url.startsWith('//')) {
      url = 'https:$url';
    }
    // On remplace 't_thumb' par 't_720p' pour avoir une belle image
    return url.replaceAll('t_thumb', 't_720p');
  }
}
