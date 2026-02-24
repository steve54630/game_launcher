import 'package:flutter/material.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool isLoading;
  const SectionHeader({super.key, required this.title, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (isLoading) ...[
          const SizedBox(width: AppSpacing.m),
          const SizedBox(
            height: 14,
            width: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ],
    );
  }
}
