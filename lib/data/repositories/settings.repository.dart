import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/domain/repositories/settings.repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/utils/database_helper.dart';
import '../../domain/entities/settings.entity.dart';
import '../models/settings.model.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  final DatabaseHelper dbHelper;

  static const _settingsKeys = [
    'minimize_on_launch',
    'close_on_exit',
    'theme_mode',
  ];

  AppSettingsRepositoryImpl(this.dbHelper);

  @override
  Future<AppSettings> getSettings() async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'app_settings',
        where: 'key IN (?, ?, ?)',
        whereArgs: _settingsKeys,
      );

      if (maps.isEmpty) {
        return AppSettings.defaultSettings();
      }

      return SettingsModel.fromDbRows(maps);
    } catch (e, stack) {
      AppLogger.error("Erreur lors de la lecture des settings", e, stack);
      return AppSettings.defaultSettings();
    }
  }

  @override
  Future<void> updateSettings(AppSettings settings) async {
    try {
      final db = await dbHelper.database;

      final model = SettingsModel(
        minimizeOnLaunch: settings.minimizeOnLaunch,
        closeOnExit: settings.closeOnExit,
        themeMode: settings.themeMode,
      );

      final batch = db.batch();
      for (var row in model.toDbRows()) {
        batch.insert(
          'app_settings',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e, stack) {
      AppLogger.error("Erreur lors de l'update des settings", e, stack);
      rethrow;
    }
  }

  @override
  Future<void> resetToDefault() async {
    try {
      final db = await dbHelper.database;

      await db.delete(
        'app_settings',
        where: 'key IN (?, ?, ?)',
        whereArgs: _settingsKeys,
      );

      AppLogger.info("Paramètres réinitialisés.");
    } catch (e, stack) {
      AppLogger.error("Erreur lors du reset des settings", e, stack);
      rethrow;
    }
  }
}
