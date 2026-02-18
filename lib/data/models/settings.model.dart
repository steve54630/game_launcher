import 'package:game_launcher/domain/entities/settings.entity.dart';

class SettingsModel extends AppSettings {
  SettingsModel({super.minimizeOnLaunch, super.closeOnExit, super.themeMode});

  /// Transforme une liste de lignes SQLite [ {key: '...', value: '...'}, ... ]
  /// en un objet AppSettings structuré.
  factory SettingsModel.fromDbRows(List<Map<String, dynamic>> rows) {
    final settingsMap = {for (var row in rows) row['key']: row['value']};

    return SettingsModel(
      minimizeOnLaunch: settingsMap['minimize_on_launch'] == 'true',
      closeOnExit: settingsMap['close_on_exit'] == 'true',
      themeMode: settingsMap['theme_mode'] ?? 'system',
    );
  }

  /// Prépare une liste de Maps pour insertion/mise à jour individuelle
  List<Map<String, dynamic>> toDbRows() {
    return [
      {'key': 'minimize_on_launch', 'value': minimizeOnLaunch.toString()},
      {'key': 'close_on_exit', 'value': closeOnExit.toString()},
      {'key': 'theme_mode', 'value': themeMode},
    ];
  }
}
