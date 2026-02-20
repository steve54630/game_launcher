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
    AppLogger.info("SettingsRepo: Lecture des paramètres de l'application...");
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'app_settings',
        where: 'key IN (?, ?, ?)',
        whereArgs: _settingsKeys,
      );

      if (maps.isEmpty) {
        AppLogger.info(
          "SettingsRepo: Aucun paramètre trouvé en base, chargement des valeurs par défaut.",
        );
        return AppSettings.defaultSettings();
      }

      AppLogger.info(
        "SettingsRepo: ${maps.length} clés de configuration récupérées.",
      );
      return SettingsModel.fromDbRows(maps);
    } catch (e, stack) {
      AppLogger.error(
        "SettingsRepo: Échec de lecture des paramètres, repli sur les valeurs par défaut",
        e,
        stack,
      );
      return AppSettings.defaultSettings();
    }
  }

  @override
  Future<void> updateSettings(AppSettings settings) async {
    AppLogger.info(
      "SettingsRepo: Mise à jour des paramètres (Theme: ${settings.themeMode})...",
    );
    try {
      final db = await dbHelper.database;

      final model = SettingsModel(
        minimizeOnLaunch: settings.minimizeOnLaunch,
        closeOnExit: settings.closeOnExit,
        themeMode: settings.themeMode,
      );

      final rows = model.toDbRows();
      final batch = db.batch();

      for (var row in rows) {
        AppLogger.debug(
          "SettingsRepo: Batch préparé pour la clé: ${row['key']} = ${row['value']}",
        );
        batch.insert(
          'app_settings',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
      AppLogger.info(
        "SettingsRepo: Batch des paramètres appliqué avec succès.",
      );
    } catch (e, stack) {
      AppLogger.error(
        "SettingsRepo: Échec lors de la mise à jour des paramètres",
        e,
        stack,
      );
      rethrow;
    }
  }

  @override
  Future<void> resetToDefault() async {
    AppLogger.warning(
      "SettingsRepo: Demande de réinitialisation complète des paramètres.",
    );
    try {
      final db = await dbHelper.database;

      final count = await db.delete(
        'app_settings',
        where: 'key IN (?, ?, ?)',
        whereArgs: _settingsKeys,
      );

      AppLogger.info(
        "SettingsRepo: $count lignes supprimées. L'application utilisera les valeurs par défaut au prochain chargement.",
      );
    } catch (e, stack) {
      AppLogger.error(
        "SettingsRepo: Erreur lors de la réinitialisation des paramètres",
        e,
        stack,
      );
      rethrow;
    }
  }
}
