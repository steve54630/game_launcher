import 'package:game_launcher/domain/entities/credentials.entity.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';

abstract interface class IgdbRepository {
  // Recherche un jeu sur l'API par son nom
  Future<List<IgdbSearchResult>> searchGames(
    String query,
    IgdbCredentials credentials,
  );

  // Récupère les détails complets (vidéos, screenshots)
  Future<IgdbSearchResult> getGameDetails(
    int igdbId,
    IgdbCredentials credentials,
  );
}
