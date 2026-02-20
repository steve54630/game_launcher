import 'package:flutter/material.dart';
import 'package:game_launcher/presentation/widgets/common/smart_image.widget.dart';
import 'package:url_launcher/url_launcher.dart';

class GameVideoPreview extends StatelessWidget {
  final String youtubeVideoId;

  const GameVideoPreview({super.key, required this.youtubeVideoId});

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl =
        'https://img.youtube.com/vi/$youtubeVideoId/maxresdefault.jpg';
    final videoUrl = 'https://www.youtube.com/watch?v=$youtubeVideoId';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final uri = Uri.parse(videoUrl);
            if (await canLaunchUrl(uri)) await launchUrl(uri);
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Image de fond (Miniature YT)
                SmartImage(
                  path: thumbnailUrl,
                  height: 220,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(16),
                  fit: BoxFit.cover,
                ),

                // Overlay d'assombrissement
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black54,
                        Colors.transparent,
                        Colors.black54,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                // Bouton Play stylisé
                _buildPlayButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: 50,
      ),
    );
  }
}
