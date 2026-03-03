import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/presentation/state/import_all.state.dart';
import 'package:game_launcher/presentation/widgets/search_all/header.widget.dart';
import 'package:game_launcher/presentation/widgets/search_all/import_item.widget.dart';
import 'package:game_launcher/presentation/widgets/search_all/validation.widget.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';

class MultiGameImportPage extends ConsumerWidget {
  const MultiGameImportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On précise le type ImportAllState pour bénéficier de l'autocomplétion
    final state = ref.watch(importAllProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Ajout de jeu par dossier")),
      body: Column(
        children: [
          const HeaderInfo(),

          Expanded(child: _buildBody(context, state)),

          // Utilisation du getter readyToImport pour afficher le compteur réel
          if (!state.isScanning && state.items.isNotEmpty)
            BottomValidationBar(selectedCount: state.readyToImport.length),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ImportAllState state) {
    if (state.isScanning) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.m),
            Text("Analyse des fichiers et matching IGDB..."),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: AppSpacing.m),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    // Changement : results devient items
    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.drive_folder_upload_outlined,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: AppSpacing.m),
            const Text("Aucun exécutable trouvé."),
            Text(
              "Sélectionnez un dossier contenant vos jeux pour commencer.",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      // Changement : results devient items
      itemCount: state.items.length,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      itemBuilder: (context, index) {
        // On passe l'item spécifique à la tuile
        return ImportItemTile(
          key: ValueKey(state.items[index].fullPath),
          result: state.items[index],
        );
      },
    );
  }
}
