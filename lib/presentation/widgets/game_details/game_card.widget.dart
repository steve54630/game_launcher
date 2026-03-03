import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final title = details?.name ?? game.executablePath;
    final fileName = game.executablePath.split(RegExp(r'[/\\]')).last;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      // On s'assure que la carte a une élévation ou une bordure visible en light
      elevation: isDark ? 2 : 1,
      child: InkWell(
        onTap: onShowDetails,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          // Utilisation de onSurface pour s'adapter au thème
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Tooltip(
                        message: game.executablePath,
                        child: Text(
                          fileName,
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            // opacity adaptée au thème
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.s,
                        runSpacing: AppSpacing.xs,
                        children: [
                          GameGenreBadge(genreName: details?.genre?.name),
                          GameReleaseDate(date: details?.releaseDate),
                        ],
                      ),
                      const Spacer(),
                      _buildActionButtons(ref, game, theme),
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

  Widget _buildActionButtons(WidgetRef ref, dynamic game, ThemeData theme) {
    final secondaryButtonStyle = OutlinedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 8),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => ref.read(launchGameSessionProvider).execute(game),
            icon: const Icon(Icons.play_arrow, size: 20),
            label: const Text("JOUER"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.green,
              foregroundColor:
                  Colors.white, // Texte toujours blanc sur bouton vert
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onShowDetails,
                style: secondaryButtonStyle.copyWith(
                  foregroundColor: WidgetStateProperty.all(Colors.blueAccent),
                  side: WidgetStateProperty.all(
                    const BorderSide(color: Colors.blueAccent, width: 1.0),
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
                    const BorderSide(color: Colors.redAccent, width: 1.0),
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
