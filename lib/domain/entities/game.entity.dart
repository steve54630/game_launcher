class Game {
  final int? id;
  final int? igdbId;
  final String displayName;
  final String executablePath;
  final int playtimeSeconds;
  final DateTime? lastPlayedAt;
  final bool isFavorite;

  Game({
    this.id,
    this.igdbId,
    required this.displayName,
    required this.executablePath,
    this.playtimeSeconds = 0,
    this.lastPlayedAt,
    this.isFavorite = false,
  });

  Game copyWith({
    int? id,
    int? igdbId,
    String? displayName,
    String? executablePath,
    int? playtimeSeconds,
    DateTime? lastPlayedAt,
    bool? isFavorite,
  }) {
    return Game(
      id: id ?? this.id,
      igdbId: igdbId ?? this.igdbId,
      displayName: displayName ?? this.displayName,
      executablePath: executablePath ?? this.executablePath,
      playtimeSeconds: playtimeSeconds ?? this.playtimeSeconds,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
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
}
