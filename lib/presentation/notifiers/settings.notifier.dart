import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/repository.providers.dart';
import 'package:game_launcher/data/models/settings.model.dart';

class SettingsNotifier extends AsyncNotifier<SettingsModel> {
  @override
  FutureOr<SettingsModel> build() async {
    final repository = ref.watch(appSettingsProvider);
    final entity = await repository.getSettings();
    return SettingsModel.fromEntity(entity);
  }

  Future<void> updateSettings(SettingsModel newSettings) async {
    final previousState = state.value;
    if (previousState == null) return;

    state = AsyncData(newSettings);

    try {
      final repository = ref.read(appSettingsProvider);
      await repository.updateSettings(newSettings.toEntity());
    } catch (e, stack) {
      state = AsyncData(previousState);
      state = AsyncError(e, stack);
    }
  }

  Future<void> toggleDisplayMode(String mode) async {
    final current = state.value;
    if (current == null) return;
    await updateSettings(current.copyWith(libraryDisplayMode: mode));
  }

  Future<void> setThemeMode(String theme) async {
    final current = state.value;
    if (current == null) return;
    await updateSettings(current.copyWith(themeMode: theme));
  }

  Future<void> setMinimizeOnLaunch(bool value) async {
    final current = state.value;
    if (current == null) return;
    await updateSettings(current.copyWith(minimizeOnLaunch: value));
  }

  Future<void> setCloseOnExit(bool value) async {
    final current = state.value;
    if (current == null) return;
    await updateSettings(current.copyWith(closeOnExit: value));
  }

  Future<void> resetSettings() async {
    try {
      final repository = ref.read(appSettingsProvider);
      await repository.resetToDefault();
      ref.invalidateSelf();
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}
