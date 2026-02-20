import 'package:flutter/material.dart';
import 'package:game_launcher/presentation/widgets/common/smart_image.widget.dart';
import '../../../../core/theme/app.colors.dart';

class GameDetailsHeader extends SliverPersistentHeaderDelegate {
  final String title;
  final String? coverUrl;
  final double expandedHeight;

  GameDetailsHeader({
    required this.title,
    this.coverUrl,
    required this.expandedHeight,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Calcul de la progression du scroll (0.0 = étendu, 1.0 = réduit)
    final double progress = shrinkOffset / (maxExtent - minExtent);
    final double currentOpacity = progress.clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Image de fond (SmartImage gère le switch Local/Réseau)
        SmartImage(path: coverUrl, fit: BoxFit.cover),

        // 2. Filtre d'assombrissement fixe + Gradient dynamique
        // On sépare le filtre de l'image pour garder le contrôle sur SmartImage
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(
              alpha: 0.3,
            ), // Assombrit l'image de base
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.4 * (1 - currentOpacity)),
                Colors.transparent,
                AppColors.background.withValues(alpha: currentOpacity),
                AppColors.background,
              ],
              stops: const [0.0, 0.4, 0.9, 1.0],
            ),
          ),
        ),

        // 3. Titre animé (Taille et position)
        Align(
          alignment: Alignment.lerp(
            Alignment.bottomLeft,
            Alignment.center,
            currentOpacity,
          )!,
          child: Padding(
            padding: EdgeInsets.only(
              left: 60, // Laisse la place au bouton retour
              bottom: 20 * (1 - currentOpacity) + (currentOpacity * 5),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 32 - (currentOpacity * 12),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        // 4. Bouton retour (toujours visible)
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: const BackButton(color: Colors.white),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + 40; // Légèrement augmenté pour l'esthétique

  @override
  bool shouldRebuild(covariant GameDetailsHeader oldDelegate) {
    return oldDelegate.title != title ||
        oldDelegate.coverUrl != coverUrl ||
        oldDelegate.expandedHeight != expandedHeight;
  }
}
