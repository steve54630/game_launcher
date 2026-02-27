import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';
import 'package:game_launcher/domain/entities/discovery_result.entity.dart';
import 'package:game_launcher/presentation/widgets/search/game_search.widget.dart';
import 'package:game_launcher/presentation/widgets/search_all/igdb_preview.widget.dart';

class ImportItemTile extends ConsumerWidget {
  final DiscoveryResult result;
  const ImportItemTile({super.key, required this.result});

  Future<void> _openFileLocation(String path) async {
    // Commande Windows pour ouvrir le dossier et sélectionner le fichier
    await Process.run('explorer.exe', ['/select,', path]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(
      importAllProvider.select(
        (s) => s.selectedPaths.contains(result.fullPath),
      ),
    );

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.xs,
      ),
      child: ListTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (_) => ref
              .read(importAllProvider.notifier)
              .toggleSelection(result.fullPath),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom du fichier (rawName) uniquement
            Text(
              result.rawName,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Chemin cliquable
            const SizedBox(height: 2),
            InkWell(
              onTap: () => _openFileLocation(result.fullPath),
              borderRadius: BorderRadius.circular(4),
              child: Text(
                result.fullPath,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.lightBlue.shade500,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: MetadataPreview(result: result),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize
              .min, // Important pour ne pas prendre toute la largeur
          children: [
            // Bouton Supprimer de la liste
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
              ),
              tooltip: "Retirer de la liste",
              onPressed: () {
                // On appelle le notifier pour supprimer ce chemin
                ref
                    .read(importAllProvider.notifier)
                    .removeResult(result.fullPath);
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit_note_rounded),
              tooltip: "Modifier la correspondance IGDB",
              onPressed: () => _showEditModal(context, ref, result),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditModal(
    BuildContext context,
    WidgetRef ref,
    DiscoveryResult item,
  ) {
    final notifier = ref.read(importAllProvider.notifier);
    ref.read(activeImportTargetProvider.notifier).state = notifier;
    notifier.prepareEditing(item.fullPath);
    ref.read(gameSearchTermProvider.notifier).updateTerm(item.rawName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SearchGameModal(),
    );
  }
}
