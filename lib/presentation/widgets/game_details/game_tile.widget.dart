import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
import 'package:game_launcher/core/theme/app.colors.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';
import 'package:game_launcher/domain/entities/game_details.entity.dart';
import 'package:game_launcher/presentation/pages/game_details.page.dart';
import 'package:game_launcher/presentation/widgets/game_details/card/cover.widget.dart';
import 'package:game_launcher/presentation/widgets/game_details/delete_game.widget.dart';

class GameListTile extends ConsumerWidget {
  final GameWithDetails gameDetails;

  const GameListTile({super.key, required this.gameDetails});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = gameDetails.game;
    final details = gameDetails.details;
    final title = details?.name ?? game.executablePath;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: InkWell(
        onTap: () => openDetails(context),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Row(
            children: [
              // 1. Mini Jaquette (Carrée et petite)
              Hero(
                tag: 'game-cover-${game.id}',
                child: SizedBox(
                  width: 45,
                  height: 45,
                  child: GameCover(
                    url: details?.coverUrl,
                    title: title,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),

              // 2. Infos principales (Titre et sous-titre)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      game.executablePath.split(RegExp(r'[/\\]')).last,
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: AppColors.textSecondary.withValues(alpha: .5),
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),

              // 3. Actions rapides
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bouton JOUER compact
                  IconButton(
                    onPressed: () =>
                        ref.read(launchGameSessionProvider).execute(game),
                    icon: const Icon(Icons.play_arrow),
                    color: Colors.green,
                    tooltip: "Lancer le jeu",
                  ),
                  // Menu d'options (Détails / Supprimer)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'details') {
                        openDetails(context);
                      }
                      if (value == 'delete') {
                        DeleteGameDialog.show(context, game);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'details',
                        child: ListTile(
                          leading: Icon(Icons.info_outline, size: 18),
                          title: Text("Détails"),
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          title: Text(
                            "Supprimer",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                          dense: true,
                        ),
                      ),
                    ],
                    icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameDetailsPage(item: gameDetails),
      ),
    );
  }
}
