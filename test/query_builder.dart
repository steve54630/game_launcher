import 'package:flutter_test/flutter_test.dart';
import 'package:game_launcher/data/utils/igbd_query_builder.dart';

void main() {
  group('IgdbQueryBuilder', () {
    test(
      'Should build a default query with all fields when none specified',
      () {
        final query = IgdbQueryBuilder().build();
        expect(query, equals('fields *;'));
      },
    );

    test('Should build a search query correctly', () {
      final query = IgdbQueryBuilder().search('Cyberpunk').fields([
        'name',
        'cover.url',
      ]).build();

      expect(query, equals('search "Cyberpunk"; fields name, cover.url;'));
    });

    test('Should handle where clause and limits', () {
      final query = IgdbQueryBuilder()
          .fields(['name'])
          .where('id = 123')
          .limit(5)
          .build();

      expect(query, equals('fields name; where id = 123; limit 5;'));
    });

    test('Should maintain correct order of clauses (Apicalypse syntax)', () {
      // L'ordre est important pour la lisibilité et parfois l'analyseur IGDB
      final query = IgdbQueryBuilder().limit(1).search('Witcher').fields([
        'id',
      ]).build();

      // Ordre attendu : search -> fields -> where -> limit
      expect(query, equals('search "Witcher"; fields id; limit 1;'));
    });

    test('Should handle complex where conditions', () {
      const condition = 'platforms = (48, 49) & rating > 80';
      final query = IgdbQueryBuilder()
          .fields(['name'])
          .where(condition)
          .build();

      expect(query, contains('where $condition;'));
    });

    test('Should not add extra spaces or semicolons if fields are empty', () {
      final query = IgdbQueryBuilder().limit(10).build();
      expect(query, equals('fields *; limit 10;'));
    });
  });
}
