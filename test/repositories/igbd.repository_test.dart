import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_launcher/data/repositories/igbd.repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:game_launcher/domain/entities/credentials.entity.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late IgdbSearchRepositoryImpl repository;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    repository = IgdbSearchRepositoryImpl(dio: mockDio);
  });

  final tCredentials = IgdbCredentials(
    clientId: 'test_id',
    clientSecret: 'test_secret',
  );

  final tRawResponse = [
    {
      "id": 2155,
      "name": "Dark Souls",
      "cover": {
        "url": "//images.igdb.com/igdb/image/upload/t_thumb/co1vcp.jpg",
      },
      "summary": "Prepare to die",
      "first_release_date": 1316649600,
      "genres": [
        {"id": 12, "name": "RPG"},
      ],
      "screenshots": [
        {"url": "//images.igdb.com/igdb/image/upload/t_thumb/sc1.jpg"},
      ],
      "videos": [
        {"video_id": "93LFz_j5f8U"},
      ],
    },
  ];

  void mockTwitchAuth() {
    when(
      () => mockDio.post(
        any(that: contains('id.twitch.tv')),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response(
        data: {'access_token': 'token_123'},
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ),
    );
  }

  group('IgdbSearchRepository - Extended Coverage', () {
    test('search - doit utiliser le token en cache au second appel', () async {
      mockTwitchAuth();
      when(
        () => mockDio.post(
          any(that: contains('api.igdb.com')),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: tRawResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Premier appel (trigger l'auth)
      await repository.search("Dark Souls", tCredentials);
      // Deuxième appel (doit utiliser _accessToken)
      await repository.search("Dark Souls", tCredentials);

      // On vérifie que le post Twitch n'a été appelé qu'une seule fois
      verify(
        () => mockDio.post(
          any(that: contains('id.twitch.tv')),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });

    test('getDetails - doit retourner un jeu spécifique', () async {
      mockTwitchAuth();
      when(
        () => mockDio.post(
          any(that: contains('api.igdb.com')),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: tRawResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repository.getDetails(2155, tCredentials);

      expect(result.name, "Dark Souls");
      expect(result.igdbId, 2155);
      expect(result.screenshots, isNotEmpty);
      expect(
        result.screenshots.first,
        contains("t_720p"),
      ); // Vérifie le replaceFirst
    });

    test('getDetails - doit throw si la liste est vide', () async {
      mockTwitchAuth();
      when(
        () => mockDio.post(
          any(that: contains('api.igdb.com')),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: [],
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(() => repository.getDetails(0, tCredentials), throwsException);
    });

    test(
      'mapping - doit gérer les données manquantes (cover, genres, videos, screenshots)',
      () async {
        mockTwitchAuth();
        final minimalResponse = [
          {"id": 1, "name": "Empty Game"},
        ]; // Pas de cover, pas de genre, etc.

        when(
          () => mockDio.post(
            any(that: contains('api.igdb.com')),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: minimalResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await repository.search("Empty", tCredentials);
        final game = result.first;

        expect(game.coverUrl, isNull);
        expect(game.genre, isNull);
        expect(game.screenshots, isEmpty);
        expect(game.youtubeVideoId, isNull);
        expect(game.releaseDate, isNull);
      },
    );

    test(
      'mapping - doit rethrow et logger en cas d erreur de structure',
      () async {
        mockTwitchAuth();
        // On envoie un truc qui va faire planter le cast 'as Map' ou 'as List'
        final badResponse = [
          {"id": 1, "cover": "pas_une_map"},
        ];

        when(
          () => mockDio.post(
            any(that: contains('api.igdb.com')),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: badResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        expect(
          () => repository.search("Error", tCredentials),
          throwsA(anything),
        );
      },
    );

    test('_getToken - doit throw si Twitch répond une erreur', () async {
      when(
        () => mockDio.post(
          any(that: contains('id.twitch.tv')),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(() => repository.search("fail", tCredentials), throwsException);
    });
  });
}
