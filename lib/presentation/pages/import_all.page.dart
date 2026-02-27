import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
import 'package:game_launcher/presentation/widgets/search_all/header.widget.dart';
import 'package:game_launcher/presentation/widgets/search_all/import_item.widget.dart';
import 'package:game_launcher/presentation/widgets/search_all/validation.widget.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';

class MultiGameImportPage extends ConsumerWidget {
  const MultiGameImportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importAllProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("IMPORTATION MASSIVE")),
      body: Column(
        children: [
          const HeaderInfo(),

          Expanded(child: _buildBody(context, state)),

          // On n'affiche la barre que s'il y a des résultats et qu'on ne scanne pas
          if (!state.isScanning && state.results.isNotEmpty)
            BottomValidationBar(selectedCount: state.selectedPaths.length),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, dynamic state) {
    if (state.isScanning) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.m),
            Text("Analyse des fichiers en cours..."),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Text(
            state.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (state.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_zip_outlined,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: AppSpacing.m),
            const Text("Aucun exécutable trouvé."),
            const Text(
              "Lancez un scan depuis le header.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // On utilise directement la liste complète sans filtrage
    return ListView.builder(
      itemCount: state.results.length,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      itemBuilder: (context, index) {
        return ImportItemTile(result: state.results[index]);
      },
    );
  }
}
