import 'dart:io';
import 'package:flutter/material.dart';

class ImageSourceHelper {
  static ImageProvider getProvider(String? path) {
    if (path == null || path.isEmpty) {
      return const AssetImage('assets/images/placeholder.png'); // Ton fallback
    }

    // Gestion des URLs IGDB (souvent commencent par //)
    if (path.startsWith('http') || path.startsWith('//')) {
      final url = path.startsWith('//') ? 'https:$path' : path;
      return NetworkImage(url);
    }

    // Sinon, c'est un fichier local (Chemin absolu SQLite)
    return FileImage(File(path));
  }
}
