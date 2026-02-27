import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:game_launcher/domain/entities/igbd_genre.entity.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/domain/entities/game_details.entity.dart';

class GameModel extends Game {
  GameModel({
    super.id,
    super.igdbId,
    required super.executablePath,
    super.playtimeSeconds = 0,
    super.lastPlayedAt,
    super.isFavorite = false, // Optionnel, vient du cache
  });

  // Conversion SQL -> Dart
  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'] as int?,
      igdbId: map['igdb_id'] as int?,
      executablePath: map['executable_path'] as String,
      playtimeSeconds: map['playtime_seconds'] as int? ?? 0,
      lastPlayedAt: map['last_played_at'] != null
          ? DateTime.parse(map['last_played_at'] as String)
          : null,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
    );
  }

  // Conversion Dart -> SQL
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'igdb_id': igdbId,
      'executable_path': executablePath,
      'playtime_seconds': playtimeSeconds,
      'last_played_at': lastPlayedAt?.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  static GameModel fromEntity(Game game) {
    return GameModel(
      id: game.id,
      igdbId: game.igdbId,
      executablePath: game.executablePath,
      playtimeSeconds: game.playtimeSeconds,
      lastPlayedAt: game.lastPlayedAt,
      isFavorite: game.isFavorite,
    );
  }

  static GameWithDetails toGameWithDetails(Map<String, dynamic> map) {
    // 1. Extraction du jeu (Données App)
    final game = GameModel.fromMap(map);

    // 2. Extraction des métadonnées (Données IGDB)
    // On vérifie la présence de igdb_id dans la map résultant de la jointure
    if (map['igdb_id'] == null) {
      return GameWithDetails(game: game, details: null);
    }

    final metadata = IgdbSearchResult(
      igdbId: map['igdb_id'] as int,
      name: map['name'] as String,
      coverUrl: map['cover_url'] as String?,
      summary: map['summary'] as String?,
      youtubeVideoId: map['video_id'] as String?,
      releaseDate: map['release_date'] != null
          ? DateTime.tryParse(map['release_date'] as String)
          : null,
      genre: map['genre_id'] != null
          ? IgdbGenre(
              id: map['genre_id'] as int,
              name: map['genre_name'] as String,
            )
          : null,
      // Note: screenshots peut être parsé ici si stocké en JSON/CSV dans SQLite
      screenshots: map['screenshot_urls'] != null
          ? (map['screenshot_urls'] as String).split(',')
          : const [],
    );

    return GameWithDetails(game: game, details: metadata);
  }
}
