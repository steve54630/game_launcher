import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
import 'package:game_launcher/domain/entities/game.entity.dart';

class DeleteGameDialog extends ConsumerWidget {
  final Game game;

  const DeleteGameDialog({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.read(deleteGameUseCaseProvider);

    return AlertDialog(
      title: const Text("Confirmation"),
      content: Text("Voulez-vous vraiment supprimer ${game.executablePath} ?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Annuler"),
        ),
        TextButton(
          onPressed: () async {
            try {
              // On attend que le UseCase finisse proprement
              await state.execute(game);

              // On ne pop que si ça a réussi
              if (context.mounted) Navigator.of(context).pop(true);
            } catch (e) {
              // Optionnel : Afficher une erreur locale ou laisser le Logger faire
              // Mais on ne ferme pas forcément la modale pour que l'user sache que ça a échoué
            }
          },
          child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  // Helper statique pour l'appel
  static Future<bool> show(BuildContext context, Game game) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => DeleteGameDialog(game: game),
        ) ??
        false;
  }
}
