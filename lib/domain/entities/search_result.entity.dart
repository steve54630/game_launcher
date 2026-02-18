class IgdbSearchResult {
  final int igdbId;
  final String name;
  final String? coverUrl; // Image verticale (Grille)
  final String? backgroundUrl; // Image de fond (Détails)
  final String? summary; // Pitch du jeu
  final List<String> screenshots;
  final String? youtubeVideoId; // L'ID pour le trailer (ex: 'dQw4w9WgXcQ')
  final DateTime? releaseDate;

  IgdbSearchResult({
    required this.igdbId,
    required this.name,
    this.coverUrl,
    this.backgroundUrl,
    this.summary,
    this.screenshots = const [],
    this.youtubeVideoId,
    this.releaseDate,
  });
}
