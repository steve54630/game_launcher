import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
import 'package:game_launcher/core/theme/app.colors.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';
import 'package:game_launcher/domain/model/game.model.dart';

class GameCard extends ConsumerWidget {
  final GameWithDetails gameDetails;
  final VoidCallback onShowDetails;

  const GameCard({
    super.key,
    required this.gameDetails,
    required this.onShowDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = gameDetails.game;
    final details = gameDetails.details;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: InkWell(
        onTap: onShowDetails,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: IntrinsicHeight(
          // Force la colonne à prendre la hauteur de l'image
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Jaquette à GAUCHE
              Hero(
                tag: 'game-cover-${game.id}',
                child: SizedBox(
                  width: 130,
                  height: 180,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSpacing.cardRadius),
                      bottomLeft: Radius.circular(AppSpacing.cardRadius),
                    ),
                    child: _buildCover(
                      details?.coverUrl,
                      details?.name ?? game.displayName,
                    ),
                  ),
                ),
              ),

              // 2. Détails à DROITE
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        details?.name ?? game.displayName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // Badge Genre
                      _buildGenreBadge(details?.genre?.name),

                      const Spacer(),

                      // 3. Boutons d'actions
                      Row(
                        children: [
                          Expanded(
                            // On force le bouton à se réduire si besoin
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final launchSession = ref.read(
                                  launchGameSessionProvider,
                                );

                                // 2. Exécution
                                await launchSession.execute(game);
                              },
                              icon: const Icon(Icons.play_arrow, size: 18),
                              label: const Text(
                                "JOUER",
                                overflow: TextOverflow.ellipsis,
                              ), // On tronque le texte
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onShowDetails,
                              child: const Text(
                                "DÉTAILS",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildCover(String? url, String title) {
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, _, _) => _buildPlaceholder(title),
      );
    }
    return _buildPlaceholder(title);
  }

  Widget _buildPlaceholder(String title) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.surface.withValues(alpha: 0.5)],
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videogame_asset,
            color: AppColors.primary.withValues(alpha: 0.5),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.white54),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGenreBadge(String? genreName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        genreName?.toUpperCase() ?? "INCONNU",
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
