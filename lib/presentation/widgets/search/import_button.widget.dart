import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';
import 'package:game_launcher/presentation/widgets/search/right/error.widget.dart';

class ImportActionButton extends ConsumerWidget {
  const ImportActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importProvider);
    final notifier = ref.read(importProvider.notifier);

    // Le getter isReady centralise maintenant toute la logique métier
    // (isSelected && selectedMatch != null)
    final canImport = state.result?.isReady ?? false;

    return Column(
      children: [
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: ErrorMessage(message: state.error!),
          ),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canImport ? null : Colors.grey.withAlpha(25),
            ),
            onPressed: canImport && !state.isSaving
                ? () async {
                    final success = await notifier.executeImport();

                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Jeu ajouté avec succès !"),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // On reset les providers avant de rediriger (SPA)
                      notifier.reset();
                      ref.read(gameSearchTermProvider.notifier).updateTerm("");

                      // Redirection vers la bibliothèque (Index 0)
                      ref.read(navigationIndexProvider.notifier).state = 0;
                    }
                  }
                : null,
            child: state.isSaving
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "IMPORTER DANS LA BIBLIOTHÈQUE",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }
}
