import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';

class HeaderInfo extends ConsumerWidget {
  const HeaderInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importAllProvider);
    final notifier = ref.read(importAllProvider.notifier);

    final isAllSelected =
        state.results.isNotEmpty &&
        state.selectedPaths.length == state.results.length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 1. Contrôle de sélection globale
              Checkbox(
                value: isAllSelected,
                tristate: state.selectedPaths.isNotEmpty && !isAllSelected,
                onChanged: (value) => notifier.toggleAll(value ?? false),
              ),
              const SizedBox(width: AppSpacing.s),
              const Text(
                "TOUT SÉLECTIONNER",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const Spacer(),

              // 2. Info sur le chemin scanné + Bouton de changement
              if (state.currentPath.isNotEmpty)
                Row(
                  children: [
                    Chip(
                      label: Text(
                        state.currentPath,
                        style: const TextStyle(fontSize: 11),
                      ),
                      avatar: const Icon(Icons.folder_open, size: 16),
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                    const SizedBox(width: AppSpacing.s),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_location_alt_outlined,
                        size: 20,
                      ),
                      tooltip: "Changer de dossier",
                      onPressed: () => _pickDirectory(ref),
                    ),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: () => _pickDirectory(ref),
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text("SCANNER UN DOSSIER"),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDirectory(WidgetRef ref) async {
    final String? directoryPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Sélectionner le répertoire de vos jeux",
    );

    if (directoryPath != null) {
      ref.read(importAllProvider.notifier).scanDirectory(directoryPath);
    }
  }
}
