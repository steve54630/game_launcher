import 'package:game_launcher/domain/entities/igbd_genre.entity.dart';

class IgdbSearchResult {
  final int igdbId;
  final String name;
  final String? coverUrl; // Image verticale (Grille)
  final String? backgroundUrl; // Image de fond (Détails)
  final String? summary; // Pitch du jeu
  final List<String> screenshots;
  final String? youtubeVideoId; // L'ID pour le trailer (ex: 'dQw4w9WgXcQ')
  final DateTime? releaseDate;
  final IgdbGenre? genre;

  IgdbSearchResult({
    required this.igdbId,
    required this.name,
    this.coverUrl,
    this.backgroundUrl,
    this.summary,
    this.screenshots = const [],
    this.youtubeVideoId,
    this.releaseDate,
    this.genre,
  });

  @override
  String toString() {
    return 'IgdbSearchResult('
        'id: $igdbId, '
        'name: "$name", '
        'genre: ${genre?.name ?? "N/A"}, '
        'hasTrailer: ${youtubeVideoId != null}, '
        'screenshots: ${screenshots.length}'
        ')';
  }
}
