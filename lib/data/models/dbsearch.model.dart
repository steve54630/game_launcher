import 'dart:convert';
import 'dart:developer' as dev;
import 'package:game_launcher/core/utils/logger.dart';
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
    // Debug: Affiche le JSON formaté dans la console
    final prettyJson = const JsonEncoder.withIndent('  ').convert(json);
    dev.log('---------- IGDB DEBUG ----------');
    AppLogger.info(prettyJson);
    dev.log('--------------------------------');

    final coverData = json['cover'] as Map<String, dynamic>?;
    final coverUrl = coverData != null && coverData.containsKey('url')
        ? _parseImageUrl(coverData['url'] as String)
        : null;

    final screenshots = <String>[];
    if (json['screenshots'] != null && json['screenshots'] is List) {
      for (var shot in (json['screenshots'] as List)) {
        if (shot is Map && shot.containsKey('url')) {
          final url = shot['url'] as String?;
          if (url != null && url.isNotEmpty) {
            screenshots.add(_parseImageUrl(url));
          }
        }
      }
    }

    final videos = json['videos'] as List?;
    final videoId = (videos != null && videos.isNotEmpty)
        ? videos.first['video_id'] as String?
        : null;

    DateTime? releaseDateTime;
    if (json['first_release_date'] != null) {
      releaseDateTime = DateTime.fromMillisecondsSinceEpoch(
        (json['first_release_date'] as int) * 1000,
      );
    }

    final genresList = json['genres'] as List?;
    dynamic genreResult;

    if (genresList != null && genresList.isNotEmpty) {
      final firstGenre = genresList.first as Map<String, dynamic>;
      genreResult = {
        'id': firstGenre['id'] as int,
        'name': firstGenre['name'] as String,
      };
    }

    return IgdbSearchResultModel(
      igdbId: json['id'] as int,
      name: json['name'] as String,
      coverUrl: coverUrl,
      summary: json['summary'] as String?,
      screenshots: screenshots,
      youtubeVideoId: videoId,
      releaseDate: releaseDateTime,
      genre: genreResult,
    );
  }

  static String _parseImageUrl(String url) {
    if (url.startsWith('//')) {
      url = 'https:$url';
    }
    // Note: t_720p fonctionne bien pour les covers et screenshots
    return url.replaceAll('t_thumb', 't_720p');
  }
}
