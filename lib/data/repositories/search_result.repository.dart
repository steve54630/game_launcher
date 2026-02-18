import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/domain/repositories/search_result.repository.dart';
import '../../domain/entities/credentials.entity.dart';
import '../../domain/entities/search_result.entity.dart';

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

    final response = await _client.post(
      Uri.parse('$_baseUrl/games'),
      headers: {
        'Client-ID': credentials.clientId,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: 'search "$query"; fields name, cover.url, summary; limit 10;',
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

    final response = await _client.post(
      Uri.parse('$_baseUrl/games'),
      headers: {
        'Client-ID': credentials.clientId,
        'Authorization': 'Bearer $token',
      },
      body:
          'fields name, cover.url, summary, screenshots.url, videos.video_id; where id = $igdbId;',
    );

    if (response.statusCode != 200) {
      _logError("Details", response);
      throw HttpException("IGDB Details Failed: ${response.statusCode}");
    }

    final List<dynamic> data = json.decode(response.body);
    if (data.isEmpty) throw Exception("Jeu non trouvé sur IGDB (ID: $igdbId)");

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
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      return _accessToken!;
    } else {
      throw Exception(
        "Twitch Auth Failure: ${response.statusCode} - ${response.body}",
      );
    }
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

    return IgdbSearchResult(
      igdbId: map['id'] as int,
      name: map['name'] as String,
      coverUrl: coverUrl != null ? "https:$coverUrl" : null,
      summary: map['summary'] as String?,
      screenshots: screenshots,
    );
  }

  void _logError(String context, http.Response response) {
    AppLogger.error(
      "IGDB API Error ($context): ${response.statusCode} - ${response.body}",
    );
  }
}
