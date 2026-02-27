import 'package:game_launcher/domain/entities/settings.entity.dart';

class SettingsModel extends AppSettings {
  SettingsModel({
    required super.minimizeOnLaunch,
    required super.closeOnExit,
    required super.themeMode,
    required super.libraryDisplayMode,
  });

  factory SettingsModel.fromDbRows(List<Map<String, dynamic>> rows) {
    final settingsMap = {for (var row in rows) row['key']: row['value']};

    // Helper pour parser robustement (gère 'true', 1, ou "1")
    bool parseBool(dynamic value) {
      if (value == null) return false;
      return value == 'true' || value == 1 || value == '1';
    }

    return SettingsModel(
      minimizeOnLaunch: parseBool(settingsMap['minimize_on_launch']),
      closeOnExit: parseBool(settingsMap['close_on_exit']),
      themeMode: settingsMap['theme_mode']?.toString() ?? 'system',
      libraryDisplayMode:
          settingsMap['library_display_mode']?.toString() ?? 'card',
    );
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

  List<Map<String, dynamic>> toDbRows() {
    return [
      {'key': 'minimize_on_launch', 'value': minimizeOnLaunch ? 1 : 0},
      {'key': 'close_on_exit', 'value': closeOnExit ? 1 : 0},
      {'key': 'theme_mode', 'value': themeMode},
      {'key': 'library_display_mode', 'value': libraryDisplayMode},
    ];
  }
}
