import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provider pour le stockage sécurisé (Keychain/Keystore)
/// Idéal pour les clés API IGDB et les secrets utilisateur.
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});
