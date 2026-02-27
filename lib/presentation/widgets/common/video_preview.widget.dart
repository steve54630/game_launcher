import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide Video;
import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/presentation/widgets/common/smart_image.widget.dart';

class GameVideoPreview extends StatefulWidget {
  final String youtubeVideoId;

  const GameVideoPreview({super.key, required this.youtubeVideoId});

  @override
  State<GameVideoPreview> createState() => _GameVideoPreviewState();
}

class _GameVideoPreviewState extends State<GameVideoPreview> {
  Player? _player;
  VideoController? _controller;
  bool _isLoading = false;

  @override
  void dispose() {
    // Libération immédiate des ressources natives lors du changement de jeu
    _player?.dispose();
    super.dispose();
  }

  Future<void> _startStreaming() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    final yt = YoutubeExplode();

    try {
      // 1. Extraction du flux direct (bypass l'erreur 153)
      final manifest = await yt.videos.streamsClient.getManifest(
        widget.youtubeVideoId,
      );

      if (!mounted) return;

      // On récupère le flux vidéo+audio le plus adapté
      final streamInfo = manifest.muxed.withHighestBitrate();

      // 2. Initialisation du player "On-Demand"
      final player = Player();
      final controller = VideoController(player);

      // 3. Lecture du flux
      await player.open(Media(streamInfo.url.toString()), play: true);

      if (mounted) {
        setState(() {
          _player = player;
          _controller = controller;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      AppLogger.error("GameVideoPreview: Stream failed", e, stack);
      if (mounted) setState(() => _isLoading = false);
    } finally {
      yt.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: Colors.black26,
          child: (_player != null && _controller != null)
              ? Video(controller: _controller!)
              : _buildThumbnail(),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final thumbnailUrl =
        'https://img.youtube.com/vi/${widget.youtubeVideoId}/maxresdefault.jpg';

    return Stack(
      alignment: Alignment.center,
      children: [
        SmartImage(
          path: thumbnailUrl,
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        // Overlay sombre
        Container(color: Colors.black.withAlpha(50)),
        if (_isLoading)
          const CircularProgressIndicator(color: Colors.red)
        else
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _startStreaming,
              borderRadius: BorderRadius.circular(50),
              child: _buildPlayButton(),
            ),
          ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(230),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: 40,
      ),
    );
  }
}
