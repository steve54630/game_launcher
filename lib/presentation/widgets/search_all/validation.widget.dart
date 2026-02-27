import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';

class BottomValidationBar extends ConsumerWidget {
  final int selectedCount;

  const BottomValidationBar({super.key, required this.selectedCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On désactive le bouton si rien n'est sélectionné
    final bool canImport = selectedCount > 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Icon(
              Icons.library_add_check,
              color: canImport ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: AppSpacing.s),
            Text(
              "$selectedCount jeu(x) prêt(s) à l'importation",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: canImport ? null : Colors.grey,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: canImport
                  ? () => _handleFinalImport(ref, context)
                  : null,
              icon: const Icon(Icons.download_done_rounded),
              label: const Text("VALIDER L'IMPORT"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.l,
                  vertical: AppSpacing.m,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFinalImport(WidgetRef ref, BuildContext context) async {
    await ref.read(importAllProvider.notifier).importSelectedGames();

    ref.read(navigationIndexProvider.notifier).state = 0;
  }
}
