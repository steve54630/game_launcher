class AppSettings {
  final bool minimizeOnLaunch;
  final bool closeOnExit;
  final String themeMode; // 'light', 'dark', 'system'

  AppSettings({
    this.minimizeOnLaunch = true,
    this.closeOnExit = false,
    this.themeMode = 'system',
  });
}
