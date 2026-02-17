import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/domain/repositories/credentails.repository.dart';
import 'package:game_launcher/domain/repositories/search_result.repository.dart';

class SearchGameMetadata {
  final IgdbRepository repository;
  final CredentialsRepository credentialsRepository;

  SearchGameMetadata(this.repository, this.credentialsRepository);

  Future<List<IgdbSearchResult>> execute(String query) async {
    final credentials = await credentialsRepository.getIgdbCredentials();
    if (credentials == null) throw Exception("Clés API manquantes");

    return await repository.searchGames(query, credentials);
  }
}
