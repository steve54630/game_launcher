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

    // Calcul précis de l'état de la sélection
    final hasItems = state.items.isNotEmpty;
    final selectedCount = state.selectedItems.length;
    final isAllSelected = hasItems && selectedCount == state.items.length;
    final isPartiallySelected = hasItems && selectedCount > 0 && !isAllSelected;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          // 1. Contrôle de sélection globale
          Checkbox(
            value: isAllSelected,
            tristate:
                isPartiallySelected, // Affiche un tiret si sélection partielle
            onChanged: hasItems
                ? (value) => notifier.toggleAll(value ?? false)
                : null,
          ),
          const SizedBox(width: AppSpacing.s),
          Text(
            isPartiallySelected
                ? "$selectedCount SÉLECTIONNÉS"
                : "TOUT SÉLECTIONNER",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const Spacer(),

          // 2. Info sur le chemin scanné + Bouton de changement
          if (state.currentScanningPath.isNotEmpty || state.items.isNotEmpty)
            Row(
              children: [
                if (state.currentScanningPath.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s),
                    child: Chip(
                      label: Text(
                        state.currentScanningPath,
                        style: const TextStyle(fontSize: 11),
                      ),
                      avatar: const Icon(Icons.folder_open, size: 16),
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: "Relancer le scan",
                  onPressed: state.isScanning
                      ? null
                      : () => notifier.scanDirectory(state.currentScanningPath),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_location_alt_outlined, size: 20),
                  tooltip: "Changer de dossier",
                  onPressed: () => _pickDirectory(ref),
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: state.isScanning ? null : () => _pickDirectory(ref),
              icon: const Icon(Icons.search, size: 18),
              label: const Text("SCANNER UN DOSSIER"),
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
