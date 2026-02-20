import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_launcher/data/repositories/igbd.repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:game_launcher/domain/entities/credentials.entity.dart';

// On mocke l'instance Dio
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

  // Dio attend déjà un objet (Map ou List), plus besoin de la String brute JSON
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
      "videos": [
        {"video_id": "93LFz_j5f8U"},
      ],
    },
  ];

  group('IgdbSearchRepository - Dio Edition', () {
    test('doit retourner une liste mappée en cas de succès 200', () async {
      // 1. Mock de l'authentification (Twitch)
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

      // 2. Mock de la recherche (IGDB)
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

      // Act
      final results = await repository.search("Dark Souls", tCredentials);

      // Assert
      expect(results.first.name, "Dark Souls");
      expect(results.first.youtubeVideoId, "93LFz_j5f8U");
      expect(results.first.coverUrl, contains("t_cover_big"));
    });

    test('doit throw une Exception si Dio renvoie une erreur', () async {
      when(
        () => mockDio.post(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: 'Error',
          statusCode: 404,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => repository.search("Dark Souls", tCredentials),
        throwsA(isA<Exception>()),
      );
    });
  });
}
