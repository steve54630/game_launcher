import 'package:flutter_test/flutter_test.dart';
import 'package:game_launcher/data/models/game.model.dart';
import 'package:game_launcher/data/models/game_with_details.dart';
import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:game_launcher/domain/entities/discovery_result.entity.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';

void main() {
  group('GameModel - Unit Tests', () {
    final tDateTime = DateTime(2026, 1, 1, 12, 0, 0);
    final tMap = {
      'id': 1,
      'igdb_id': 123,
      'executable_path': 'C:/Games/Hades2.exe',
      'playtime_seconds': 3600,
      'last_played_at': '2026-01-01T12:00:00.000',
      'is_favorite': 1,
    };

    test('fromMap should return a valid GameModel', () {
      final result = GameModel.fromMap(tMap);

      expect(result.id, 1);
      expect(result.lastPlayedAt, tDateTime);
      expect(result.isFavorite, isTrue);
    });

    test('toMap should return a valid Map representation', () {
      final model = GameModel(
        id: 1,
        igdbId: 123,
        executablePath:
            'C:/Games/Hades2.exe', // Utilisation du param nommé correct
        playtimeSeconds: 3600,
        lastPlayedAt: tDateTime,
        isFavorite: true,
      );

      final result = model.toMap();

      expect(result['is_favorite'], 1);
      expect(result['last_played_at'], tDateTime.toIso8601String());
    });

    test('fromEntity should create model from base entity', () {
      final entity = Game(executablePath: '/path', isFavorite: true);

      final result = GameModel.fromEntity(entity);
      expect(result.isFavorite, isTrue);
    });
  });

  group('GameModel - Complex Mapping (toGameWithDetails)', () {
    test(
      'Should return GameWithDetails with null details if igdb_id is missing',
      () {
        final map = {'executable_path': '/path', 'igdb_id': null};

        final result = GameModel.toGameWithDetails(map);
        expect(result.details, isNull);
      },
    );

    test('Should parse full metadata including genres and screenshots', () {
      final fullMap = {
        'id': 1,
        'igdb_id': 100,
        'executable_path': '/path',
        'name': 'Cyberpunk 2077', // Nom IGDB different du display name
        'cover_url': 'http://cover.jpg',
        'genre_id': 5,
        'genre_name': 'RPG',
        'screenshot_urls': 's1.jpg,s2.jpg',
      };

      final result = GameModel.toGameWithDetails(fullMap);

      expect(result.details?.igdbId, 100);
      expect(result.details?.genre?.name, 'RPG');
      expect(result.details?.screenshots, containsAll(['s1.jpg', 's2.jpg']));
    });
  });

  group('GameWithDetailsModel - Factory', () {
    test('fromDiscovery should map discovery result correctly', () {
      final mockMatch = IgdbSearchResult(igdbId: 99, name: 'Matched Name');
      final discovery = DiscoveryResult(
        rawName: 'Game.exe',
        fullPath: 'C:/Game.exe',
        pathSegments: ['Games'],
        fileSize: 1024,
        igdbMatch: mockMatch,
      );

      final result = GameWithDetailsModel.fromDiscovery(discovery);

      expect(result.game.igdbId, 99);
      expect(result.details?.name, 'Matched Name');
    });
  });
}
