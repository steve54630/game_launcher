class Game {
  final int? id;
  final int? igdbId;
  final String executablePath;
  final int playtimeSeconds;
  final DateTime? lastPlayedAt;
  final bool isFavorite;

  Game({
    this.id,
    this.igdbId,
    required this.executablePath,
    this.playtimeSeconds = 0,
    this.lastPlayedAt,
    this.isFavorite = false,
  });

  Game copyWith({
    int? id,
    int? igdbId,
    String? gameGenre,
    String? executablePath,
    int? playtimeSeconds,
    DateTime? lastPlayedAt,
    bool? isFavorite,
  }) {
    return Game(
      id: id ?? this.id,
      igdbId: igdbId ?? this.igdbId,
      executablePath: executablePath ?? this.executablePath,
      playtimeSeconds: playtimeSeconds ?? this.playtimeSeconds,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
