import 'package:flutter_test/flutter_test.dart';
import 'package:game_launcher/core/utils/database_helper.dart';
import 'package:game_launcher/data/repositories/settings.repository.dart';
import 'package:game_launcher/domain/entities/settings.entity.dart';
import '../test.utilities.dart';

void main() {
  late DatabaseHelper dbHelper;
  late AppSettingsRepositoryImpl repository;

  setUp(() async {
    dbHelper = await createTestDatabase();
    repository = AppSettingsRepositoryImpl(dbHelper);
  });

  tearDown(() async {
    final db = await dbHelper.database;
    await db.close();
  });

  group('AppSettingsRepositoryImpl - Integration Tests', () {
    test('Should return default settings when DB is empty', () async {
      final settings = await repository.getSettings();

      expect(settings.minimizeOnLaunch, true);
      expect(settings.closeOnExit, false);
      expect(settings.themeMode, 'system');
      expect(settings.libraryDisplayMode, 'card');
    });

    test('Should save and retrieve settings correctly', () async {
      final newSettings = AppSettings(
        minimizeOnLaunch: false,
        closeOnExit: true,
        themeMode: 'dark',
        libraryDisplayMode: 'cover',
      );

      await repository.updateSettings(newSettings);
      final retrieved = await repository.getSettings();

      expect(retrieved.minimizeOnLaunch, false);
      expect(retrieved.closeOnExit, true);
      expect(retrieved.themeMode, 'dark');
      expect(retrieved.libraryDisplayMode, 'cover');
    });

    test('Should reset only UI settings and keep others (simulated)', () async {
      final db = await dbHelper.database;

      await db.insert('app_settings', {
        'key': 'other_key',
        'value': 'stay_here',
      });

      final customSettings = AppSettings(
        minimizeOnLaunch: false,
        closeOnExit: true,
        themeMode: 'dark',
        libraryDisplayMode: 'grid',
      );
      await repository.updateSettings(customSettings);

      await repository.resetToDefault();

      final retrieved = await repository.getSettings();
      expect(retrieved.minimizeOnLaunch, true);
      expect(retrieved.closeOnExit, false);

      final otherKey = await db.query(
        'app_settings',
        where: 'key = ?',
        whereArgs: ['other_key'],
      );
      expect(otherKey.isNotEmpty, true);
      expect(otherKey.first['value'], 'stay_here');
    });
  });
}
