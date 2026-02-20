import 'package:flutter/material.dart';
import 'package:game_launcher/core/theme/app.colors.dart';

class GameGenreBadge extends StatelessWidget {
  final String? genreName;

  const GameGenreBadge({super.key, this.genreName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        genreName?.toUpperCase() ?? "INCONNU",
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
