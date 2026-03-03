import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            _SectionHeader(title: 'Comportement'),
            SwitchListTile(
              title: const Text('Réduire au lancement'),
              subtitle: const Text('Cache le launcher quand un jeu démarre'),
              value: settings.minimizeOnLaunch,
              onChanged: (val) => ref
                  .read(settingsProvider.notifier)
                  .updateSettings(settings.copyWith(minimizeOnLaunch: val)),
            ),
            SwitchListTile(
              title: const Text('Fermer à la sortie'),
              subtitle: const Text(
                'Quitte l\'application au lieu de réduire en arrière-plan',
              ),
              value: settings.closeOnExit,
              onChanged: (val) => ref
                  .read(settingsProvider.notifier)
                  .updateSettings(settings.copyWith(closeOnExit: val)),
            ),
            const Divider(),
            _SectionHeader(title: 'Interface'),
            ListTile(
              title: const Text('Thème de l\'application'),
              trailing: DropdownButton<String>(
                value: settings.themeMode,
                items: const [
                  DropdownMenuItem(value: 'system', child: Text('Système')),
                  DropdownMenuItem(value: 'light', child: Text('Clair')),
                  DropdownMenuItem(value: 'dark', child: Text('Sombre')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    ref.read(settingsProvider.notifier).setThemeMode(val);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Affichage de la bibliothèque'),
              trailing: ToggleButtons(
                isSelected: [
                  settings.libraryDisplayMode == 'grid',
                  settings.libraryDisplayMode == 'list',
                ],
                onPressed: (index) {
                  final mode = index == 0 ? 'grid' : 'list';
                  ref.read(settingsProvider.notifier).toggleDisplayMode(mode);
                },
                children: const [Icon(Icons.grid_view), Icon(Icons.list)],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
