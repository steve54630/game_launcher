import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_launcher/data/repositories/search_result.repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:game_launcher/domain/entities/credentials.entity.dart';

void main() {
  final credentials = IgdbCredentials(clientId: 'abc', clientSecret: '123');

  group('IgdbRepositoryImpl - API Tests', () {
    // Test Succès Recherche
    test('Should return a list of games on success', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host == 'id.twitch.tv') {
          return http.Response(
            json.encode({'access_token': 'fake_token'}),
            200,
          );
        }
        return http.Response(
          json.encode([
            {
              'id': 1,
              'name': 'Doom',
              'cover': {'url': '//image.com/t_thumb/1.jpg'},
              'summary': 'Great game',
            },
          ]),
          200,
        );
      });

      final repo = IgdbRepositoryImpl(client: mockClient);
      final results = await repo.searchGames('Doom', credentials);

      expect(results.length, 1);
      expect(results.first.name, 'Doom');
      expect(results.first.coverUrl, contains('t_cover_big'));
    });

    // Test getGameDetails (Couvre la logique des screenshots et mapping complexe)
    test('Should return full game details including screenshots', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host == 'id.twitch.tv') {
          return http.Response(
            json.encode({'access_token': 'fake_token'}),
            200,
          );
        }
        return http.Response(
          json.encode([
            {
              'id': 1,
              'name': 'Doom',
              'screenshots': [
                {'url': '//images.com/t_thumb/sc1.jpg'},
                {'url': '//images.com/t_thumb/sc2.jpg'},
              ],
            },
          ]),
          200,
        );
      });

      final repo = IgdbRepositoryImpl(client: mockClient);
      final game = await repo.getGameDetails(1, credentials);

      expect(game.name, 'Doom');
      expect(game.screenshots.length, 2);
      expect(game.screenshots.first, contains('t_720p'));
      expect(game.screenshots.first, startsWith('https:'));
    });

    // Test Erreur de Parsing (Couvre le bloc catch et FormatException)
    test('Should throw FormatException on malformed JSON', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host == 'id.twitch.tv') {
          return http.Response(
            json.encode({'access_token': 'fake_token'}),
            200,
          );
        }
        return http.Response('not a json', 200);
      });

      final repo = IgdbRepositoryImpl(client: mockClient);

      expect(
        () => repo.searchGames('Doom', credentials),
        throwsA(isA<FormatException>()),
      );
    });

    // Test Auth Failure (Déjà présent, indispensable)
    test('Should throw exception on Auth failure', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final repo = IgdbRepositoryImpl(client: mockClient);

      expect(
        () => repo.searchGames('Doom', credentials),
        throwsA(isA<Exception>()),
      );
    });

    // Test Erreur HTTP 500 (Couvre HttpException et _logError)
    test('Should throw HttpException on server error (500)', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host == 'id.twitch.tv') {
          return http.Response(
            json.encode({'access_token': 'fake_token'}),
            200,
          );
        }
        return http.Response('Server Error', 500);
      });

      final repo = IgdbRepositoryImpl(client: mockClient);

      expect(
        () => repo.searchGames('Doom', credentials),
        throwsA(isA<HttpException>()),
      );
    });

    // Test Jeu non trouvé (Pour getGameDetails)
    test('Should throw Exception when game details array is empty', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host == 'id.twitch.tv') {
          return http.Response(
            json.encode({'access_token': 'fake_token'}),
            200,
          );
        }
        return http.Response(json.encode([]), 200);
      });

      final repo = IgdbRepositoryImpl(client: mockClient);

      expect(
        () => repo.getGameDetails(999, credentials),
        throwsA(isA<Exception>()),
      );
    });
  });
}
