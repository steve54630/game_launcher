import 'dart:io';
import 'package:dio/dio.dart';
import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/domain/repositories/igbd.repository.dart';
import 'package:game_launcher/domain/entities/credentials.entity.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/domain/entities/igbd_genre.entity.dart';

class IgdbSearchRepositoryImpl implements IgdbSearchRepository {
  final Dio _dio;
  final String _baseUrl = "https://api.igdb.com/v4";
  final String _authUrl = "https://id.twitch.tv/oauth2/token";
  String? _accessToken;

  // Injection de Dio (facilite le testing avec MockDio)
  IgdbSearchRepositoryImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<List<IgdbSearchResult>> search(
    String query,
    IgdbCredentials creds,
  ) async {
    try {
      final token = await _getToken(creds);

      final response = await _dio.post(
        '$_baseUrl/games',
        options: Options(
          headers: {
            'Client-ID': creds.clientId,
            'Authorization': 'Bearer $token',
          },
        ),
        data:
            'search "$query"; fields name, cover.url, summary, genres.id, genres.name, first_release_date, screenshots.url, videos.video_id; limit 10;',
      );

      if (response.statusCode != 200)
        throw const HttpException("Search Failed");

      final List<dynamic> data = response.data; // Décodage automatique par Dio
      return data.map((item) => _mapToSearchResult(item)).toList();
    } catch (e) {
      AppLogger.error("Erreur Search IGDB", e);
      rethrow;
    }
  }

  @override
  Future<IgdbSearchResult> getDetails(int igdbId, IgdbCredentials creds) async {
    final token = await _getToken(creds);
    final response = await _dio.post(
      '$_baseUrl/games',
      options: Options(
        headers: {
          'Client-ID': creds.clientId,
          'Authorization': 'Bearer $token',
        },
      ),
      data:
          'where id = $igdbId; fields name, cover.url, summary, genres.id, genres.name, first_release_date, screenshots.url, videos.video_id;',
    );

    final List<dynamic> data = response.data;
    if (data.isEmpty) throw Exception("Jeu non trouvé");
    return _mapToSearchResult(data.first);
  }

  Future<String> _getToken(IgdbCredentials credentials) async {
    if (_accessToken != null) return _accessToken!;

    try {
      final response = await _dio.post(
        _authUrl,
        queryParameters: {
          'client_id': credentials.clientId,
          'client_secret': credentials.clientSecret,
          'grant_type': 'client_credentials',
        },
      );

      _accessToken = response.data['access_token'];
      return _accessToken!;
    } catch (e) {
      AppLogger.error("Auth Failure", e);
      throw Exception("Impossible de récupérer le token Twitch");
    }
  }

  IgdbSearchResult _mapToSearchResult(Map<String, dynamic> map) {
    // 1. Gestion Image (Clean URL)
    final coverMap = map['cover'] as Map<String, dynamic>?;
    final coverUrl = coverMap != null && coverMap['url'] != null
        ? "https:${(coverMap['url'] as String).replaceFirst('t_thumb', 't_cover_big')}"
        : null;

    // 2. Screenshots (Mapping safe)
    final screenshots =
        (map['screenshots'] as List?)
            ?.map(
              (s) =>
                  "https:${(s['url'] as String).replaceFirst('t_thumb', 't_720p')}",
            )
            .toList() ??
        [];

    // 3. Genre (Objet typé)
    IgdbGenre? mainGenre;
    if (map['genres'] != null && (map['genres'] as List).isNotEmpty) {
      final g = map['genres'][0];
      mainGenre = IgdbGenre(id: g['id'], name: g['name']);
    }

    // 4. Video ID (Sécurisation contre le crash RangeError)
    final videos = map['videos'] as List?;
    final videoId = (videos != null && videos.isNotEmpty)
        ? videos.first['video_id'] as String?
        : null;

    final releaseTimestamp = map['first_release_date'] as int?;

    return IgdbSearchResult(
      igdbId: map['id'],
      name: map['name'],
      coverUrl: coverUrl,
      summary: map['summary'],
      screenshots: screenshots,
      genre: mainGenre,
      releaseDate: releaseTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(releaseTimestamp * 1000)
          : null,
      youtubeVideoId: videoId,
    );
  }
}
