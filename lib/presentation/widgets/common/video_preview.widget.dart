import 'package:flutter/material.dart';
import 'package:game_launcher/presentation/widgets/common/smart_image.widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:game_launcher/core/utils/logger.dart';

class GameVideoPreview extends StatelessWidget {
  final String youtubeVideoId;

  const GameVideoPreview({super.key, required this.youtubeVideoId});

  @override
  Widget build(BuildContext context) {
    // Utilisation de hqdefault si maxresdefault n'est pas disponible pour certains jeux
    final thumbnailUrl =
        'https://img.youtube.com/vi/$youtubeVideoId/mqdefault.jpg';
    final videoUrl = 'https://www.youtube.com/watch?v=$youtubeVideoId';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AspectRatio 16/9 évite que la vidéo ne paraisse "serrée" ou déformée
        AspectRatio(
          aspectRatio: 16 / 9,
          child: GestureDetector(
            onTap: () async {
              AppLogger.info(
                "GameVideoPreview: Ouverture du trailer YouTube ($youtubeVideoId)",
              );
              final uri = Uri.parse(videoUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                AppLogger.error(
                  "GameVideoPreview: Impossible de lancer l'URL $videoUrl",
                );
              }
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Image de fond
                    SmartImage(
                      path: thumbnailUrl,
                      height: double.infinity,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(16),
                      fit: BoxFit.cover, // Remplit bien l'espace 16/9
                    ),

                    // Overlay dégradé plus subtil pour laisser respirer l'image
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                              Colors.black.withValues(alpha: .6),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                    // Bouton Play
                    _buildPlayButton(),

                    // Badge "Trailer" optionnel pour donner du contexte
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "YOUTUBE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(
          alpha: 0.9,
        ), // Couleur YouTube pour plus de clarté
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: 40,
      ),
    );
  }
}
