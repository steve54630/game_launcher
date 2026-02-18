import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/domain/repositories/search_result.repository.dart';
import '../../domain/entities/credentials.entity.dart';
import '../../domain/entities/search_result.entity.dart';

class IgdbRepositoryImpl implements IgdbRepository {
  final String _baseUrl = "https://api.igdb.com/v4";
  final String _authUrl = "https://id.twitch.tv/oauth2/token";

  // Cache temporaire du token pour éviter de le redemander à chaque clic
  String? _accessToken;

  @override
  Future<List<IgdbSearchResult>> searchGames(
    String query,
    IgdbCredentials credentials,
  ) async {
    try {
      final token = await _getToken(credentials);

      final response = await http.post(
        Uri.parse('$_baseUrl/games'),
        headers: {
          'Client-ID': credentials.clientId,
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body:
            'search "$query"; fields name, cover.url, summary, first_release_date; limit 10;',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => _mapToSearchResult(item)).toList();
      } else {
        _logError("Search", response);
        return [];
      }
    } catch (e, stack) {
      AppLogger.error("Erreur lors de la recherche IGDB", e, stack);
      return [];
    }
  }

  @override
  Future<IgdbSearchResult> getGameDetails(
    int igdbId,
    IgdbCredentials credentials,
  ) async {
    try {
      final token = await _getToken(credentials);

      final response = await http.post(
        Uri.parse('$_baseUrl/games'),
        headers: {
          'Client-ID': credentials.clientId,
          'Authorization': 'Bearer $token',
        },
        body:
            'fields name, cover.url, summary, screenshots.url, videos.video_id; where id = $igdbId;',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) throw Exception("Jeu non trouvé sur IGDB");
        return _mapToSearchResult(data.first);
      } else {
        _logError("Details", response);
        throw Exception("Erreur API IGDB");
      }
    } catch (e, stack) {
      AppLogger.error("Erreur détails IGDB (ID: $igdbId)", e, stack);
      rethrow;
    }
  }

  /// Gestion de l'authentification OAuth2 Twitch
  Future<String> _getToken(IgdbCredentials credentials) async {
    if (_accessToken != null) return _accessToken!;

    final response = await http.post(
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
        "Échec de l'authentification Twitch IGDB : ${response.body}",
      );
    }
  }

  IgdbSearchResult _mapToSearchResult(Map<String, dynamic> map) {
    // Note : On transforme l'URL thumb en cover_big pour une meilleure qualité
    final coverUrl = map['cover'] != null
        ? (map['cover']['url'] as String).replaceFirst('t_thumb', 't_cover_big')
        : null;

    return IgdbSearchResult(
      igdbId: map['id'] as int,
      name: map['name'] as String,
      coverUrl: coverUrl != null ? "https:$coverUrl" : null,
      summary: map['summary'] as String?,
    );
  }

  void _logError(String context, http.Response response) {
    AppLogger.error(
      "IGDB API Error ($context): ${response.statusCode} - ${response.body}",
    );
  }
}
