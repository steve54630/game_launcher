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

    return SettingsModel(
      minimizeOnLaunch: settingsMap['minimize_on_launch'] == 'true',
      closeOnExit: settingsMap['close_on_exit'] == 'true',
      themeMode: settingsMap['theme_mode'] ?? 'system',
      libraryDisplayMode: settingsMap['library_display_mode'] ?? 'card',
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
      {'key': 'minimize_on_launch', 'value': minimizeOnLaunch.toString()},
      {'key': 'close_on_exit', 'value': closeOnExit.toString()},
      {'key': 'theme_mode', 'value': themeMode},
      {'key': 'library_display_mode', 'value': libraryDisplayMode},
    ];
  }
}
