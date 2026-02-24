import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';

class ImportActionButton extends ConsumerWidget {
  const ImportActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importProvider);
    final notifier = ref.read(importProvider.notifier);

    return Column(
      children: [
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: _ErrorMessage(message: state.errorMessage!),
          ),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: state.canImport
                  ? null
                  : Colors.grey.withAlpha(25),
            ),
            onPressed: state.canImport && !state.isSaving
                ? () async {
                    // On appelle executeImport sans argument car le notifier
                    // possède déjà le selectedIgdbGame dans son state.
                    final success = await notifier.executeImport();

                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Jeu ajouté avec succès !"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      notifier.reset();
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

class _ErrorMessage extends StatelessWidget {
  final String message;
  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
