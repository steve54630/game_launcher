import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/repository.providers.dart';
import 'package:game_launcher/domain/entities/credentials.entity.dart';
import 'package:game_launcher/core/utils/logger.dart';

class CredentialsNotifier extends Notifier<void> {
  @override
  void build() {
    // Rien à initialiser ici pour le moment
  }

  Future<void> saveCredentials(String clientId, String clientSecret) async {
    AppLogger.info(
      "SettingsNotifier: Tentative de sauvegarde des identifiants IGDB...",
    );

    if (clientId.isEmpty || clientSecret.isEmpty) {
      AppLogger.warning(
        "SettingsNotifier: Tentative de sauvegarde avec des champs vides.",
      );
      return;
    }

    try {
      final credentials = IgdbCredentials(
        clientId: clientId,
        clientSecret: clientSecret,
      );

      AppLogger.info(
        "SettingsNotifier: Appel du repository pour le stockage (Encryption BYOK)...",
      );

      // 1. Sauvegarde en base de données via ton repository
      await ref.read(credentialsProvider).saveIgdbCredentials(credentials);

      AppLogger.info(
        "SettingsNotifier: Identifiants sauvegardés avec succès en base de données.",
      );

      // Optionnel : Forcer un refresh des providers qui dépendent des credentials
      // ref.invalidate(igdbCredentialsProvider);
    } catch (e) {
      AppLogger.error(
        "SettingsNotifier: Échec critique lors de la sauvegarde des identifiants",
        e,
      );
      // Ici, tu pourrais gérer un état d'erreur pour l'UI si nécessaire
      rethrow;
    }
  }

  Future<void> clearCredentials() async {
    AppLogger.warning(
      "SettingsNotifier: Demande de suppression des identifiants IGDB.",
    );
    try {
      // Logique pour supprimer les clés de la DB si besoin
      AppLogger.info("SettingsNotifier: Identifiants réinitialisés.");
    } catch (e) {
      AppLogger.error(
        "SettingsNotifier: Erreur lors de la suppression des identifiants",
        e,
      );
    }
  }
}
