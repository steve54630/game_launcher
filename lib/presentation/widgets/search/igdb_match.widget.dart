import 'package:flutter/material.dart';
import '../../../../../core/theme/app.colors.dart';
import '../../../../../core/theme/app.spacing.dart';

class IgdbMatchCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback onEdit;

  const IgdbMatchCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          _CoverPreview(imageUrl: imageUrl),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            tooltip: "Changer de correspondance",
          ),
        ],
      ),
    );
  }
}

// Sous-composant privé car intrinsèque à IgdbMatchCard
class _CoverPreview extends StatelessWidget {
  final String? imageUrl;
  const _CoverPreview({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(4),
      ),
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(imageUrl!, fit: BoxFit.cover),
            )
          : const Icon(Icons.image_not_supported, color: Colors.white10),
    );
  }
}
