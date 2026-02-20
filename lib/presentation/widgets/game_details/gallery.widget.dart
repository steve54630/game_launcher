import 'package:flutter/material.dart';
import 'package:game_launcher/presentation/widgets/common/smart_image.widget.dart';
import '../../../../core/theme/app.spacing.dart';

class GameScreenshotGallery extends StatelessWidget {
  final List<String> screenshots;

  const GameScreenshotGallery({super.key, required this.screenshots});

  @override
  Widget build(BuildContext context) {
    // Si la liste est vide, on n'affiche rien du tout
    if (screenshots.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // On rajoute un petit padding horizontal pour que le premier/dernier item
        // ne colle pas aux bords de l'écran lors du scroll
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: screenshots.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.m),
        itemBuilder: (context, index) {
          return SmartImage(
            path: screenshots[index],
            width: 320,
            fit: BoxFit.cover,
            // On utilise le paramètre de bordure de notre nouveau widget
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          );
        },
      ),
    );
  }
}
