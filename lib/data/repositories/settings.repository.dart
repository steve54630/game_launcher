import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/domain/repositories/settings.repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/utils/database_helper.dart';
import '../../domain/entities/settings.entity.dart';
import '../models/settings.model.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  final DatabaseHelper dbHelper;

  AppSettingsRepositoryImpl(this.dbHelper);

  @override
  Future<AppSettings> getSettings() async {
    try {
      final db = await dbHelper.database;

      // On récupère uniquement les clés qui concernent AppSettings
      // Cela évite de mélanger avec les clés IGDB (BYOK) lors du mapping
      final List<Map<String, dynamic>> maps = await db.query(
        'app_settings',
        where: 'key IN (?, ?, ?)',
        whereArgs: ['minimize_on_launch', 'close_on_exit', 'theme_mode'],
      );

      if (maps.isEmpty) {
        AppLogger.info(
          "Aucun paramètre trouvé en BDD, retour des valeurs par défaut.",
        );
        return AppSettings();
      }

      return SettingsModel.fromDbRows(maps);
    } catch (e, stack) {
      AppLogger.error("Erreur lors de la lecture des settings", e, stack);
      return AppSettings(); // Fail-safe
    }
  }

  @override
  Future<void> updateSettings(AppSettings settings) async {
    try {
      final db = await dbHelper.database;

      // On utilise notre model pour obtenir la liste des lignes à insérer
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
      AppLogger.info("Paramètres utilisateur mis à jour avec succès.");
    } catch (e, stack) {
      AppLogger.error("Erreur lors de l'update des settings", e, stack);
      rethrow;
    }
  }

  @override
  Future<void> resetToDefault() async {
    try {
      final db = await dbHelper.database;

      // On supprime uniquement les clés liées à l'UI
      await db.delete(
        'app_settings',
        where: 'key IN (?, ?, ?)',
        whereArgs: ['minimize_on_launch', 'close_on_exit', 'theme_mode'],
      );

      AppLogger.info("Paramètres réinitialisés par défaut.");
    } catch (e, stack) {
      AppLogger.error("Erreur lors du reset des settings", e, stack);
      rethrow;
    }
  }
}
