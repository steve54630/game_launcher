import 'dart:convert';
import 'dart:io';

import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/data/utils/igbd_query_builder.dart';
import 'package:game_launcher/domain/entities/credentials.entity.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/domain/entities/igbd_genre.entity.dart';
import 'package:game_launcher/domain/repositories/search_result.repository.dart';
import 'package:http/http.dart' as http;

class IgdbRepositoryImpl implements IgdbRepository {
  final http.Client _client;
  final String _baseUrl = "https://api.igdb.com/v4";
  final String _authUrl = "https://id.twitch.tv/oauth2/token";
  String? _accessToken;

  IgdbRepositoryImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<List<IgdbSearchResult>> searchGames(
    String query,
    IgdbCredentials credentials,
  ) async {
    final token = await _getToken(credentials);

    final queryString = IgdbQueryBuilder()
        .search(query)
        .fields([
          'name',
          'cover.url',
          'summary',
          'genres.id',
          'genres.name',
          'first_release_date',
        ])
        .limit(10)
        .build();

    final response = await _client.post(
      Uri.parse('$_baseUrl/games'),
      headers: _getHeaders(credentials.clientId, token),
      body: queryString,
    );

    if (response.statusCode != 200) {
      _logError("Search", response);
      throw HttpException("IGDB Search Failed: ${response.statusCode}");
    }

    try {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => _mapToSearchResult(item)).toList();
    } catch (e, stack) {
      AppLogger.error("Erreur de parsing JSON IGDB", e, stack);
      throw const FormatException("Invalid JSON response from IGDB");
    }
  }

  @override
  Future<IgdbSearchResult> getGameDetails(
    int igdbId,
    IgdbCredentials credentials,
  ) async {
    final token = await _getToken(credentials);

    final queryString = IgdbQueryBuilder()
        .fields([
          'name',
          'cover.url',
          'summary',
          'screenshots.url',
          'videos.video_id',
          'genres.id',
          'genres.name',
          'first_release_date',
        ])
        .where('id = $igdbId')
        .build();

    final response = await _client.post(
      Uri.parse('$_baseUrl/games'),
      headers: _getHeaders(credentials.clientId, token),
      body: queryString,
    );

    if (response.statusCode != 200) {
      _logError("Details", response);
      throw HttpException("IGDB Details Failed: ${response.statusCode}");
    }

    final List<dynamic> data = json.decode(response.body);
    if (data.isEmpty) throw Exception("Jeu non trouvé sur IGDB (ID: $igdbId)");

    return _mapToSearchResult(data.first);
  }

  // --- Helpers Privés ---

  Map<String, String> _getHeaders(String clientId, String token) => {
    'Client-ID': clientId,
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  };

  Future<String> _getToken(IgdbCredentials credentials) async {
    if (_accessToken != null) return _accessToken!;

    final response = await _client.post(
      Uri.parse(
        '$_authUrl?client_id=${credentials.clientId}&client_secret=${credentials.clientSecret}&grant_type=client_credentials',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      return _accessToken!;
    } else {
      throw Exception("Twitch Auth Failure: ${response.statusCode}");
    }
  }

  IgdbSearchResult _mapToSearchResult(Map<String, dynamic> map) {
    // Mapping des images
    final coverUrl = map['cover'] != null
        ? (map['cover']['url'] as String).replaceFirst('t_thumb', 't_cover_big')
        : null;

    final screenshots =
        (map['screenshots'] as List?)
            ?.map(
              (s) =>
                  "https:${(s['url'] as String).replaceFirst('t_thumb', 't_720p')}",
            )
            .toList() ??
        [];

    // Nouveau : Mapping du genre principal
    IgdbGenre? mainGenre;
    final genresList = map['genres'] as List?;
    if (genresList != null && genresList.isNotEmpty) {
      final firstGenre = genresList.first;
      mainGenre = IgdbGenre(
        id: firstGenre['id'] as int,
        name: firstGenre['name'] as String,
      );
    }

    // Nouveau : Mapping de la date de sortie (Timestamp secondes -> DateTime)
    final releaseTimestamp = map['first_release_date'] as int?;
    final releaseDate = releaseTimestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(releaseTimestamp * 1000)
        : null;

    // Récupération de la vidéo YouTube (premier trailer trouvé)
    final videoId =
        (map['videos'] as List?)?.firstOrNull?['video_id'] as String?;

    return IgdbSearchResult(
      igdbId: map['id'] as int,
      name: map['name'] as String,
      coverUrl: coverUrl != null ? "https:$coverUrl" : null,
      summary: map['summary'] as String?,
      screenshots: screenshots,
      genre: mainGenre,
      releaseDate: releaseDate,
      youtubeVideoId: videoId,
    );
  }

  void _logError(String context, http.Response response) {
    AppLogger.error("IGDB API Error ($context): ${response.statusCode}");
  }
}
