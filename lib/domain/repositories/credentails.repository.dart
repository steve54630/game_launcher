import '../entities/credentials.entity.dart';

abstract interface class CredentialsRepository {
  /// Récupère les clés IGDB (déchiffrement géré par l'implémentation)
  Future<IgdbCredentials?> getIgdbCredentials();

  /// Enregistre les clés IGDB (chiffrement géré par l'implémentation)
  Future<void> saveIgdbCredentials(IgdbCredentials credentials);

  /// Supprime les clés du stockage
  Future<void> clearCredentials();
}
