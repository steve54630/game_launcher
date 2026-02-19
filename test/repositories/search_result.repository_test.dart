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
    // 1. TEST SUCCÈS RECHERCHE (Avec nouveaux champs)
    test(
      'Should return a list of games with genre and release date on success',
      () async {
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
                'genres': [
                  {'id': 4, 'name': 'Fighting'},
                ],
                'first_release_date': 755136000, // 1993-12-10
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
        // Nouveau : Validation Genre et Date
        expect(results.first.genre?.name, 'Fighting');
        expect(results.first.releaseDate?.year, 1993);
      },
    );

    // 2. TEST DÉTAILS COMPLETS (Screenshots + Vidéo YouTube)
    test(
      'Should return full game details including screenshots and video ID',
      () async {
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
                'videos': [
                  {'video_id': 'dQw4w9WgXcQ'},
                ],
                'genres': [
                  {'id': 5, 'name': 'Shooter'},
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
        // Nouveau : Validation Vidéo et Genre
        expect(game.youtubeVideoId, 'dQw4w9WgXcQ');
        expect(game.genre?.id, 5);
      },
    );

    // 3. TEST CHAMPS OPTIONNELS MANQUANTS
    test(
      'Should handle games with missing optional fields (genres, date, video)',
      () async {
        final mockClient = MockClient((request) async {
          if (request.url.host == 'id.twitch.tv') {
            return http.Response(
              json.encode({'access_token': 'fake_token'}),
              200,
            );
          }
          return http.Response(
            json.encode([
              {'id': 2, 'name': 'Empty Game'},
            ]),
            200,
          );
        });

        final repo = IgdbRepositoryImpl(client: mockClient);
        final game = await repo.getGameDetails(2, credentials);

        expect(game.genre, isNull);
        expect(game.releaseDate, isNull);
        expect(game.youtubeVideoId, isNull);
        expect(game.screenshots, isEmpty);
      },
    );

    // 4. TEST ERREUR PARSING JSON
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

    // 5. TEST ÉCHEC AUTH TWITCH
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

    // 6. TEST ERREUR SERVEUR HTTP 500
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

    // 7. TEST JEU VIDE (GetDetails)
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
