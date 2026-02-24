import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
import 'package:game_launcher/core/theme/app.colors.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';
import 'package:game_launcher/domain/entities/game_details.entity.dart';
import 'package:game_launcher/presentation/widgets/game_details/card/cover.widget.dart';
import 'package:game_launcher/presentation/widgets/game_details/card/genre.widget.dart';
import 'package:game_launcher/presentation/widgets/game_details/card/release.widget.dart';

class GameCard extends ConsumerWidget {
  final GameWithDetails gameDetails;
  final VoidCallback onShowDetails;
  final VoidCallback onDelete;

  const GameCard({
    super.key,
    required this.gameDetails,
    required this.onShowDetails,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = gameDetails.game;
    final details = gameDetails.details;
    final title = details?.name ?? game.displayName;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: InkWell(
        onTap: onShowDetails,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Jaquette
              Hero(
                tag: 'game-cover-${game.id}',
                child: GameCover(
                  url: details?.coverUrl,
                  title: title,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.cardRadius),
                    bottomLeft: Radius.circular(AppSpacing.cardRadius),
                  ),
                ),
              ),

              // 2. Contenu
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // Rangée Infos (Badge + Date)
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.s,
                        children: [
                          GameGenreBadge(genreName: details?.genre?.name),
                          GameReleaseDate(date: details?.releaseDate),
                        ],
                      ),

                      const Spacer(),

                      // 3. Actions
                      _buildActionButtons(ref, game),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(WidgetRef ref, dynamic game) {
    final secondaryButtonStyle = OutlinedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 8),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ligne 1 : Action principale (Pleine largeur)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => ref.read(launchGameSessionProvider).execute(game),
            icon: const Icon(Icons.play_arrow, size: 20),
            label: const Text("JOUER"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shadowColor: Colors.lightGreen,
              backgroundColor: Colors.green,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s),

        // Ligne 2 : Actions secondaires (Partage de ligne)
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onShowDetails,
                style: secondaryButtonStyle.copyWith(
                  foregroundColor: WidgetStateProperty.all(Colors.blueAccent),
                  side: WidgetStateProperty.all(
                    const BorderSide(color: Colors.blueAccent, width: 0.5),
                  ),
                ),
                child: const Text("DÉTAILS"),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: OutlinedButton(
                onPressed: onDelete,
                style: secondaryButtonStyle.copyWith(
                  foregroundColor: WidgetStateProperty.all(Colors.redAccent),
                  side: WidgetStateProperty.all(
                    const BorderSide(color: Colors.redAccent, width: 0.5),
                  ),
                ),
                child: const Text("SUPPRIMER"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
