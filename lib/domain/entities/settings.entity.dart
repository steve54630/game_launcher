class AppSettings {
  final bool minimizeOnLaunch;
  final bool closeOnExit;
  final String themeMode;

  AppSettings({
    required this.minimizeOnLaunch,
    required this.closeOnExit,
    required this.themeMode,
  });

  // Centralise tes valeurs par défaut ici, une seule fois !
  factory AppSettings.defaultSettings() {
    return AppSettings(
      minimizeOnLaunch: true,
      closeOnExit: false,
      themeMode: 'system',
    );
  }
}
