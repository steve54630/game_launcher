import 'dart:io';
import 'package:dio/dio.dart';
import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/domain/repositories/igbd.repository.dart';
import 'package:game_launcher/domain/entities/credentials.entity.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/domain/entities/igbd_genre.entity.dart';

class IgdbSearchRepositoryImpl implements IgdbRepository {
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
    AppLogger.info("IgdbRepository: Lancement recherche API pour '$query'");
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

      if (response.statusCode != 200) {
        AppLogger.error(
          "IgdbRepository: Erreur HTTP ${response.statusCode}",
          response.data,
        );
        throw const HttpException("Search Failed");
      }

      final List<dynamic> data = response.data;
      AppLogger.info(
        "IgdbRepository: ${data.length} résultats bruts reçus de l'API.",
      );

      return data.map((item) => _mapToSearchResult(item)).toList();
    } catch (e, stack) {
      AppLogger.error(
        "IgdbRepository: Erreur lors de search('$query')",
        e,
        stack,
      );
      rethrow;
    }
  }

  @override
  Future<IgdbSearchResult> getDetails(int igdbId, IgdbCredentials creds) async {
    AppLogger.info(
      "IgdbRepository: Récupération détails pour l'ID IGDB: $igdbId",
    );
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
            'where id = $igdbId; fields name, cover.url, summary, genres.id, genres.name, first_release_date, screenshots.url, videos.video_id;',
      );

      final List<dynamic> data = response.data;
      if (data.isEmpty) {
        AppLogger.warning("IgdbRepository: Aucun jeu trouvé pour l'ID $igdbId");
        throw Exception("Jeu non trouvé");
      }

      AppLogger.info(
        "IgdbRepository: Détails récupérés pour '${data.first['name']}'",
      );
      return _mapToSearchResult(data.first);
    } catch (e, stack) {
      AppLogger.error(
        "IgdbRepository: Erreur lors de getDetails($igdbId)",
        e,
        stack,
      );
      rethrow;
    }
  }

  Future<String> _getToken(IgdbCredentials credentials) async {
    if (_accessToken != null) {
      AppLogger.debug("IgdbRepository: Utilisation du token Twitch en cache.");
      return _accessToken!;
    }

    AppLogger.info("IgdbRepository: Demande d'un nouveau token à Twitch...");
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
      AppLogger.info(
        "IgdbRepository: Nouveau token Twitch récupéré avec succès.",
      );
      return _accessToken!;
    } catch (e, stack) {
      AppLogger.error(
        "IgdbRepository: Échec de l'authentification Twitch (Vérifie tes credentials)",
        e,
        stack,
      );
      throw Exception("Impossible de récupérer le token Twitch");
    }
  }

  IgdbSearchResult _mapToSearchResult(Map<String, dynamic> map) {
    try {
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

      // 4. Video ID
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
    } catch (e) {
      AppLogger.error(
        "IgdbRepository: Erreur lors du mapping d'un jeu (ID: ${map['id']})",
        e,
      );
      rethrow;
    }
  }
}
