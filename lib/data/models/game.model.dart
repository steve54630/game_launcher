import 'package:game_launcher/domain/entities/game.entity.dart';

class GameModel extends Game {
  GameModel({
    super.id,
    super.igdbId,
    required super.displayName,
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
      displayName: map['display_name'] as String,
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
      'display_name': displayName,
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
      displayName: game.displayName,
      executablePath: game.executablePath,
      playtimeSeconds: game.playtimeSeconds,
      lastPlayedAt: game.lastPlayedAt,
      isFavorite: game.isFavorite,
    );
  }
}
