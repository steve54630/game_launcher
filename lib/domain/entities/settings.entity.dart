class AppSettings {
  final bool minimizeOnLaunch;
  final bool closeOnExit;
  final String themeMode;
  final String libraryDisplayMode;

  AppSettings({
    required this.minimizeOnLaunch,
    required this.closeOnExit,
    required this.themeMode,
    required this.libraryDisplayMode,
  });

  // Centralise tes valeurs par défaut ici, une seule fois !
  factory AppSettings.defaultSettings() {
    return AppSettings(
      minimizeOnLaunch: true,
      closeOnExit: false,
      themeMode: 'system',
      libraryDisplayMode: 'card',
    );
  }
}
