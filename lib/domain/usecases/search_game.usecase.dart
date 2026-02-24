import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/domain/repositories/credentails.repository.dart';
import 'package:game_launcher/domain/repositories/igbd.repository.dart';
import 'package:game_launcher/core/utils/logger.dart';

class SearchGameUseCase {
  final IgdbRepository repository;
  final CredentialsRepository credentialsRepository;

  SearchGameUseCase(this.repository, this.credentialsRepository);

  Future<List<IgdbSearchResult>> execute(String query) async {
    AppLogger.info(
      "SearchGameMetadata: Début de recherche pour le terme: '$query'",
    );

    try {
      // 1. Récupération des clés API (BYOK)
      AppLogger.info(
        "SearchGameMetadata: Récupération des identifiants IGDB depuis le stockage sécurisé...",
      );
      final credentials = await credentialsRepository.getIgdbCredentials();

      if (credentials == null) {
        AppLogger.warning(
          "SearchGameMetadata: Échec - Les identifiants IGDB n'ont pas été trouvés.",
        );
        throw Exception(
          "Clés API manquantes. Veuillez les configurer dans les paramètres.",
        );
      }

      // 2. Appel au Repository de recherche
      AppLogger.info("SearchGameMetadata: Envoi de la requête API à IGDB...");
      final results = await repository.search(query, credentials);

      AppLogger.info(
        "SearchGameMetadata: Recherche terminée. ${results.length} résultats récupérés.",
      );

      return results;
    } catch (e) {
      AppLogger.error(
        "SearchGameMetadata: Erreur lors de l'exécution de la recherche pour '$query'",
        e,
      );
      // On propage l'erreur pour que le Notifier puisse mettre à jour le state 'errorMessage'
      rethrow;
    }
  }
}
