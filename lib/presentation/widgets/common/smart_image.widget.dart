import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app.colors.dart';

class SmartImage extends StatelessWidget {
  final String? path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SmartImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Cas : Chemin null ou vide
    if (path == null || path!.isEmpty) {
      return _buildPlaceholder();
    }

    // 2. Déterminer si c'est un fichier local (Windows/macOS/Linux)
    // On vérifie si ça commence par une lettre de lecteur (C:) ou un slash
    final isLocal =
        path!.startsWith('C:') || path!.startsWith('/') || path!.contains('\\');

    Widget image;

    if (isLocal) {
      image = Image.file(
        File(path!),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stack) => _buildErrorWidget(),
      );
    } else {
      // 3. Cas : URL distante (IGDB)
      final url = path!.startsWith('//') ? 'https:$path' : path!;
      image = Image.network(
        url,
        fit: fit,
        width: width,
        height: height,
        // On utilise un loadingBuilder pour un rendu plus pro sur le réseau
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder();
        },
        errorBuilder: (context, error, stack) => _buildErrorWidget(),
      );
    }

    // Appliquer le borderRadius si spécifié
    return borderRadius != null
        ? ClipRRect(borderRadius: borderRadius!, child: image)
        : image;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surface,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surface,
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}
