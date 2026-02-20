import 'package:flutter_test/flutter_test.dart';
import 'package:game_launcher/data/repositories/igbd.repository.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:game_launcher/domain/entities/credentials.entity.dart';

// Avec Mocktail, on crée simplement une classe qui hérite de Mock
class MockHttpClient extends Mock implements http.Client {}

// On crée un substitut pour Uri car Mocktail en a besoin pour le matching d'arguments complexes
class FakeUri extends Fake implements Uri {}

void main() {
  late IgdbSearchRepositoryImpl repository;
  late MockHttpClient mockClient;

  setUpAll(() {
    // Enregistrement des types personnalisés pour Mocktail
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockClient = MockHttpClient();
    repository = IgdbSearchRepositoryImpl(client: mockClient);
  });

  final tCredentials = IgdbCredentials(
    clientId: 'test_id',
    clientSecret: 'test_secret',
  );

  const tJsonResponse = '''
  [
    {
      "id": 2155,
      "name": "Dark Souls",
      "cover": {"url": "//images.igdb.com/igdb/image/upload/t_thumb/co1vcp.jpg"},
      "summary": "Prepare to die",
      "first_release_date": 1316649600,
      "genres": [{"id": 12, "name": "RPG"}]
    }
  ]
  ''';

  group('IgdbSearchRepository - Mocktail Edition', () {
    test('doit retourner une liste mappée en cas de succès 200', () async {
      // Mock de l'auth
      when(
        () => mockClient.post(
          any(
            that: predicate<Uri>(
              (uri) => uri.toString().contains('id.twitch.tv'),
            ),
          ),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response('{"access_token": "token"}', 200),
      );

      // Mock de la recherche
      when(
        () => mockClient.post(
          any(
            that: predicate<Uri>(
              (uri) => uri.toString().contains('api.igdb.com'),
            ),
          ),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response(tJsonResponse, 200));

      final results = await repository.search("Dark Souls", tCredentials);

      expect(results.first.name, "Dark Souls");
      expect(results.first.igdbId, 2155);
      // Vérification du mapping d'URL que tu as codé
      expect(results.first.coverUrl, contains("t_cover_big"));
    });

    test('doit throw une Exception si le status code n\'est pas 200', () async {
      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('Error', 404));

      expect(
        () => repository.search("Dark Souls", tCredentials),
        throwsException,
      );
    });
  });
}
