import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/domain/repositories/credentails.repository.dart';
import '../../domain/entities/credentials.entity.dart';

class CredentialsRepositoryImpl implements CredentialsRepository {
  // Configuration spécifique pour Windows
  final FlutterSecureStorage _storage;

  CredentialsRepositoryImpl({required FlutterSecureStorage? storage})
    : _storage =
          storage ?? const FlutterSecureStorage(wOptions: WindowsOptions());

  // Clés utilisées pour le stockage sécurisé
  static const _keyClientId = 'igdb_client_id';
  static const _keyClientSecret = 'igdb_client_secret';

  @override
  Future<IgdbCredentials?> getIgdbCredentials() async {
    try {
      final clientId = await _storage.read(key: _keyClientId);
      final clientSecret = await _storage.read(key: _keyClientSecret);

      if (clientId == null || clientSecret == null) {
        return null;
      }

      return IgdbCredentials(clientId: clientId, clientSecret: clientSecret);
    } catch (e, stack) {
      AppLogger.error("Erreur de lecture Secure Storage", e, stack);
      return null;
    }
  }

  @override
  Future<void> saveIgdbCredentials(IgdbCredentials credentials) async {
    try {
      await _storage.write(key: _keyClientId, value: credentials.clientId);
      await _storage.write(
        key: _keyClientSecret,
        value: credentials.clientSecret,
      );

      AppLogger.info("Credentials IGDB sauvegardés via Windows DPAPI.");
    } catch (e, stack) {
      AppLogger.error("Erreur d'écriture Secure Storage", e, stack);
      rethrow;
    }
  }

  @override
  Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: _keyClientId);
      await _storage.delete(key: _keyClientSecret);
      AppLogger.info("Credentials IGDB supprimés.");
    } catch (e, stack) {
      AppLogger.error("Erreur de suppression Secure Storage", e, stack);
      rethrow;
    }
  }
}
