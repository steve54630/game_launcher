import 'package:flutter/material.dart';
import '../../../../../core/theme/app.colors.dart';
import '../../../../../core/theme/app.spacing.dart';

class FilePickerZone extends StatelessWidget {
  final String? selectedPath;
  final VoidCallback onTap;

  const FilePickerZone({super.key, this.selectedPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedPath != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white10,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          color: AppColors.surface.withValues(alpha: 0.3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.task_alt : Icons.file_present_rounded,
              size: 48,
              color: isSelected ? AppColors.primary : Colors.white24,
            ),
            const SizedBox(height: AppSpacing.m),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Text(
                selectedPath ?? "Sélectionner l'exécutable",
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
