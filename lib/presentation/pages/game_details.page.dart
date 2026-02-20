import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
import 'package:game_launcher/domain/model/game.model.dart';
import 'package:game_launcher/presentation/widgets/common/gallery.widget.dart';
import 'package:game_launcher/presentation/widgets/game_details/header.widget.dart';
import 'package:game_launcher/presentation/widgets/common/video_preview.widget.dart';
import '../../../core/theme/app.colors.dart';
import '../../../core/theme/app.spacing.dart';

class GameDetailsPage extends ConsumerWidget {
  final GameWithDetails item;

  const GameDetailsPage({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = item.details;
    final game = item.game;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // HEADER : Gère l'image de fond (Background)
          SliverPersistentHeader(
            pinned: true,
            delegate: GameDetailsHeader(
              title: meta?.name ?? game.displayName,
              // On passe le chemin brut, le Header utilisera SmartImage en interne
              coverUrl: meta?.screenshots.firstOrNull ?? '',
              expandedHeight: 400,
            ),
          ),

          // CONTENU : Description, Actions et Galerie
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActionButtons(context, ref),
                  const SizedBox(height: AppSpacing.xl),

                  _buildSectionHeader(context, "À PROPOS"),
                  const SizedBox(height: AppSpacing.s),
                  _buildSummary(meta?.summary),

                  if (meta?.screenshots != null &&
                      meta!.screenshots.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _buildSectionHeader(context, "GALERIE"),
                    const SizedBox(height: AppSpacing.s),
                    // La Galerie utilisera aussi SmartImage pour chaque miniature
                    GameScreenshotGallery(screenshots: meta.screenshots),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  if (meta?.youtubeVideoId != null) ...[
                    _buildSectionHeader(context, "TRAILER"),
                    GameVideoPreview(youtubeVideoId: meta!.youtubeVideoId!),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets pour la clarté du code ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildSummary(String? summary) {
    return Text(
      summary ?? "Aucune description disponible pour ce titre.",
      style: TextStyle(
        color: AppColors.textPrimary.withValues(alpha: 0.7),
        height: 1.6,
        fontSize: 15,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final launchSession = ref.read(launchGameSessionProvider);

              // 2. Exécution
              await launchSession.execute(item.game);
            },
            icon: const Icon(Icons.play_arrow, size: 28),
            label: const Text("JOUER MAINTENANT"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        IconButton.filledTonal(
          onPressed: () {
            // Logique favoris
          },
          icon: Icon(
            item.game.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: item.game.isFavorite ? Colors.redAccent : null,
          ),
          padding: const EdgeInsets.all(16),
        ),
      ],
    );
  }
}
