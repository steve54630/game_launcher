import 'package:flutter/material.dart';
import 'package:game_launcher/domain/model/game.model.dart';
import 'package:game_launcher/presentation/widgets/game_details/gallery.widget.dart';
import 'package:game_launcher/presentation/widgets/game_details/header.widget.dart';
import '../../../core/theme/app.colors.dart';
import '../../../core/theme/app.spacing.dart';

class GameDetailsPage extends StatelessWidget {
  final GameWithDetails item;

  const GameDetailsPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final meta = item.details;
    final game = item.game;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: GameDetailsHeader(
              title: meta?.name ?? game.displayName,
              coverUrl: meta?.screenshots.firstOrNull,
              expandedHeight: 400,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActionButtons(context),
                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    "À PROPOS",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    meta?.summary ?? "Aucune description disponible.",
                    style: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),

                  if (meta?.screenshots.isNotEmpty ?? false) ...[
                    const SizedBox(height: AppSpacing.xl),
                    GameScreenshotGallery(screenshots: meta!.screenshots),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.play_arrow, size: 28),
            label: const Text("JOUER MAINTENANT"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        IconButton.filledTonal(
          onPressed: () {},
          icon: Icon(
            item.game.isFavorite ? Icons.favorite : Icons.favorite_border,
          ),
          padding: const EdgeInsets.all(16),
        ),
      ],
    );
  }
}
