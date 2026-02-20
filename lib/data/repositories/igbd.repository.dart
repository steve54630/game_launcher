import 'dart:convert';
import 'dart:io';
import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/domain/repositories/igbd.repository.dart';
import 'package:http/http.dart' as http;
import 'package:game_launcher/domain/entities/credentials.entity.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/domain/entities/igbd_genre.entity.dart';

class IgdbSearchRepositoryImpl implements IgdbSearchRepository {
  final http.Client _client;
  final String _baseUrl = "https://api.igdb.com/v4";
  final String _authUrl = "https://id.twitch.tv/oauth2/token";
  String? _accessToken;

  IgdbSearchRepositoryImpl({http.Client? client})
    : _client = client ?? http.Client();

  @override
  Future<List<IgdbSearchResult>> search(
    String query,
    IgdbCredentials creds,
  ) async {
    final token = await _getToken(creds);
    // On utilise ta logique de QueryBuilder ici
    final response = await _client.post(
      Uri.parse('$_baseUrl/games'),
      headers: {'Client-ID': creds.clientId, 'Authorization': 'Bearer $token'},
      body:
          'search "$query"; fields name, cover.url, summary, genres.id, genres.name, first_release_date, screenshots.url, videos.video_id; limit 10;',
    );

    if (response.statusCode != 200) throw HttpException("Search Failed");
    final List<dynamic> data = json.decode(response.body);
    AppLogger.info("$data");
    return data.map((item) => _mapToSearchResult(item)).toList();
  }

  @override
  Future<IgdbSearchResult> getDetails(int igdbId, IgdbCredentials creds) async {
    final token = await _getToken(creds);
    final response = await _client.post(
      Uri.parse('$_baseUrl/games'),
      headers: {'Client-ID': creds.clientId, 'Authorization': 'Bearer $token'},
      body:
          'where id = $igdbId; fields name, cover.url, summary, genres.id, genres.name, first_release_date, screenshots.url, videos.video_id;',
    );

    final List<dynamic> data = json.decode(response.body);
    if (data.isEmpty) throw Exception("Jeu non trouvé");
    return _mapToSearchResult(data.first);
  }

  Future<String> _getToken(IgdbCredentials credentials) async {
    if (_accessToken != null) return _accessToken!;
    final response = await _client.post(
      Uri.parse(
        '$_authUrl?client_id=${credentials.clientId}&client_secret=${credentials.clientSecret}&grant_type=client_credentials',
      ),
    );
    if (response.statusCode == 200) {
      _accessToken = json.decode(response.body)['access_token'];
      return _accessToken!;
    }
    AppLogger.error("Erreur lors de l'authentification");
    throw Exception("Auth Failure");
  }

  IgdbSearchResult _mapToSearchResult(Map<String, dynamic> map) {
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

    IgdbGenre? mainGenre;
    if (map['genres'] != null && (map['genres'] as List).isNotEmpty) {
      mainGenre = IgdbGenre(
        id: map['genres'][0]['id'],
        name: map['genres'][0]['name'],
      );
    }

    final releaseTimestamp = map['first_release_date'] as int?;
    return IgdbSearchResult(
      igdbId: map['id'],
      name: map['name'],
      coverUrl: coverUrl != null ? "https:$coverUrl" : null,
      summary: map['summary'],
      screenshots: screenshots,
      genre: mainGenre,
      releaseDate: releaseTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(releaseTimestamp * 1000)
          : null,
      youtubeVideoId: (map['videos'] as List?)?.firstOrNull?['video_id'],
    );
  }
}
