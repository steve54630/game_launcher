import 'package:game_launcher/domain/entities/game_details.entity.dart';

enum LibrarySortType { name, releaseDate, genre }

// Si tu veux aussi un filtre par texte plus tard

extension GameListFiltering on List<GameWithDetails> {
  // Logique de filtrage par texte
  List<GameWithDetails> filteredBySearch(String query) {
    if (query.isEmpty) return this;
    final lowercaseQuery = query.toLowerCase();
    return where((g) {
      final title = g.details?.name ?? g.game.executablePath;
      return title.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Logique de tri
  List<GameWithDetails> sortedBy(LibrarySortType type) {
    final list = List<GameWithDetails>.from(this);
    switch (type) {
      case LibrarySortType.name:
        return list..sort((a, b) => a.effectiveName.compareTo(b.effectiveName));
      case LibrarySortType.releaseDate:
        return list..sort((a, b) => b.effectiveDate.compareTo(a.effectiveDate));
      case LibrarySortType.genre:
        return list
          ..sort((a, b) => a.effectiveGenre.compareTo(b.effectiveGenre));
    }
  }
}

// Petits helpers sur le modèle pour éviter les null-checks répétitifs
extension GameDetailsHelper on GameWithDetails {
  String get effectiveName => details?.name ?? game.executablePath;
  DateTime get effectiveDate => details?.releaseDate ?? DateTime(0);
  String get effectiveGenre => details?.genre?.name ?? "";
}
