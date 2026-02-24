import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/data/models/settings.model.dart';
import 'package:game_launcher/domain/repositories/settings.repository.dart';

class SettingsNotifier extends AsyncNotifier<SettingsModel> {
  AppSettingsRepository repository;

  SettingsNotifier({required this.repository});

  @override
  Future<SettingsModel> build() async {
    final settings = await repository.getSettings();
    return settings as SettingsModel;
  }

  Future<void> updateDisplayMode(SettingsModel settings) async {
    final current = state.value;
    if (current == null) return;

    // 1. On met à jour l'état local (UI réactive)
    state = AsyncData(
      current.copyWith(libraryDisplayMode: settings.libraryDisplayMode),
    );

    // 2. On ne persiste QUE la clé concernée
    try {
      await repository.updateSettings(settings);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}
