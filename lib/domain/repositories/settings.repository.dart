import '../entities/settings.entity.dart';

abstract interface class AppSettingsRepository {
  /// Récupère la configuration globale
  Future<AppSettings> getSettings();

  /// Met à jour les préférences de l'utilisateur
  Future<void> updateSettings(AppSettings settings);

  /// Réinitialise les paramètres par défaut
  Future<void> resetToDefault();
}
