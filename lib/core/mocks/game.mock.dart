import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:game_launcher/domain/entities/igbd_genre.entity.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/domain/model/game.model.dart';

class GameMocks {
  static List<GameWithDetails> get games => [
    GameWithDetails(
      game: Game(
        id: 1,
        displayName: "Hades",
        executablePath: "/path",
        isFavorite: true,
      ),
      details: IgdbSearchResult(
        igdbId: 101,
        name: "Hades",
        coverUrl:
            "https://images.igdb.com/igdb/image/upload/t_cover_big/co1vcf.jpg",
        summary: "Hades is a rogue-like dungeon crawler...",
        genre: IgdbGenre(id: 1, name: "Action"),
        screenshots: [],
      ),
    ),
    GameWithDetails(
      game: Game(
        id: 2,
        displayName: "Cyberpunk 2077",
        executablePath: "/path",
        isFavorite: false,
      ),
      details: IgdbSearchResult(
        igdbId: 102,
        name: "Cyberpunk 2077",
        coverUrl:
            "https://images.igdb.com/igdb/image/upload/t_cover_big/co2lbd.jpg",
        summary: "An open-world, action-adventure story set in Night City...",
        genre: IgdbGenre(id: 1, name: "Action"),
        screenshots: [],
      ),
    ),
    // Ajoute d'autres mocks ici
  ];
}
