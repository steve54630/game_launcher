import 'package:flutter/material.dart';
import '../../../../core/theme/app.spacing.dart';

class GameScreenshotGallery extends StatelessWidget {
  final List<String> screenshots;

  const GameScreenshotGallery({super.key, required this.screenshots});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("GALERIE", style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.s),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: screenshots.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                child: Image.network(
                  screenshots[index],
                  width: 320,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
