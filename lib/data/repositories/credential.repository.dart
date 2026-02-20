import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/domain/repositories/credentails.repository.dart';
import '../../domain/entities/credentials.entity.dart';

class CredentialsRepositoryImpl implements CredentialsRepository {
  final FlutterSecureStorage _storage;

  CredentialsRepositoryImpl({FlutterSecureStorage? storage})
    : _storage =
          storage ?? const FlutterSecureStorage(wOptions: WindowsOptions());

  static const _keyClientId = 'igdb_client_id';
  static const _keyClientSecret = 'igdb_client_secret';

  @override
  Future<IgdbCredentials?> getIgdbCredentials() async {
    AppLogger.info(
      "CredentialsRepository: Tentative de lecture des secrets...",
    );
    try {
      final clientId = await _storage.read(key: _keyClientId);
      final clientSecret = await _storage.read(key: _keyClientSecret);

      if (clientId == null || clientSecret == null) {
        AppLogger.warning(
          "CredentialsRepository: Aucun secret trouvé (Client ID ou Secret manquant).",
        );
        return null;
      }

      AppLogger.info(
        "CredentialsRepository: Secrets récupérés et décryptés avec succès.",
      );
      return IgdbCredentials(clientId: clientId, clientSecret: clientSecret);
    } catch (e, stack) {
      AppLogger.error(
        "CredentialsRepository: Échec de lecture via Secure Storage (DPAPI)",
        e,
        stack,
      );
      return null;
    }
  }

  @override
  Future<void> saveIgdbCredentials(IgdbCredentials credentials) async {
    AppLogger.info(
      "CredentialsRepository: Début de la procédure d'écriture sécurisée...",
    );
    try {
      // On logue la présence des données, mais JAMAIS les valeurs en clair
      AppLogger.info(
        "CredentialsRepository: Chiffrement du Client ID (${credentials.clientId.length} chars) et du Secret...",
      );

      await _storage.write(key: _keyClientId, value: credentials.clientId);
      await _storage.write(
        key: _keyClientSecret,
        value: credentials.clientSecret,
      );

      AppLogger.info(
        "CredentialsRepository: Sauvegarde réussie via Windows DPAPI.",
      );
    } catch (e, stack) {
      AppLogger.error(
        "CredentialsRepository: Erreur critique lors de l'écriture sécurisée",
        e,
        stack,
      );
      rethrow;
    }
  }

  @override
  Future<void> clearCredentials() async {
    AppLogger.warning(
      "CredentialsRepository: Suppression définitive des secrets demandée.",
    );
    try {
      await _storage.delete(key: _keyClientId);
      await _storage.delete(key: _keyClientSecret);
      AppLogger.info(
        "CredentialsRepository: Secrets supprimés du stockage sécurisé.",
      );
    } catch (e, stack) {
      AppLogger.error(
        "CredentialsRepository: Échec de la suppression des secrets",
        e,
        stack,
      );
      rethrow;
    }
  }
}
