import 'package:game_launcher/domain/entities/settings.entity.dart';

class SettingsModel {
  final bool minimizeOnLaunch;
  final bool closeOnExit;
  final String themeMode;
  final String libraryDisplayMode;

  SettingsModel({
    required this.minimizeOnLaunch,
    required this.closeOnExit,
    required this.themeMode,
    required this.libraryDisplayMode,
  });

  // Transforme les lignes SQL en entité AppSettings
  factory SettingsModel.fromDbRows(List<Map<String, dynamic>> rows) {
    final Map<String, dynamic> data = {
      for (var row in rows) row['key'] as String: row['value'],
    };

    final defaultSettings = AppSettings.defaultSettings();

    return SettingsModel(
      minimizeOnLaunch: data['minimize_on_launch'] != null
          ? data['minimize_on_launch'] == 'true'
          : defaultSettings.minimizeOnLaunch,
      closeOnExit: data['close_on_exit'] != null
          ? data['close_on_exit'] == 'true'
          : defaultSettings.closeOnExit,
      themeMode: data['theme_mode'] ?? defaultSettings.themeMode,
      libraryDisplayMode:
          data['library_display_mode'] ?? defaultSettings.libraryDisplayMode,
    );
  }

  factory SettingsModel.fromEntity(AppSettings entity) {
    return SettingsModel(
      minimizeOnLaunch: entity.minimizeOnLaunch,
      closeOnExit: entity.closeOnExit,
      themeMode: entity.themeMode,
      libraryDisplayMode: entity.libraryDisplayMode,
    );
  }

  AppSettings toEntity() {
    return AppSettings(
      minimizeOnLaunch: minimizeOnLaunch,
      closeOnExit: closeOnExit,
      themeMode: themeMode,
      libraryDisplayMode: libraryDisplayMode,
    );
  }

  // Transforme l'objet actuel en liste de maps pour le Batch SQL
  List<Map<String, dynamic>> toDbRows() {
    return [
      {'key': 'minimize_on_launch', 'value': minimizeOnLaunch.toString()},
      {'key': 'close_on_exit', 'value': closeOnExit.toString()},
      {'key': 'theme_mode', 'value': themeMode},
      {'key': 'library_display_mode', 'value': libraryDisplayMode},
    ];
  }

  SettingsModel copyWith({
    bool? minimizeOnLaunch,
    bool? closeOnExit,
    String? themeMode,
    String? libraryDisplayMode,
  }) {
    return SettingsModel(
      minimizeOnLaunch: minimizeOnLaunch ?? this.minimizeOnLaunch,
      closeOnExit: closeOnExit ?? this.closeOnExit,
      themeMode: themeMode ?? this.themeMode,
      libraryDisplayMode: libraryDisplayMode ?? this.libraryDisplayMode,
    );
  }
}
