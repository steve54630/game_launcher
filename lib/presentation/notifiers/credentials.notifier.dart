import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/repository.providers.dart';
import 'package:game_launcher/domain/entities/credentials.entity.dart';

class SettingsNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> saveCredentials(String clientId, String clientSecret) async {
    final credentials = IgdbCredentials(
      clientId: clientId,
      clientSecret: clientSecret,
    );

    // 1. Sauvegarde en base de données via ton repository
    await ref.read(credentialsProvider).saveIgdbCredentials(credentials);
  }
}
