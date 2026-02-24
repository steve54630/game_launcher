import 'package:game_launcher/domain/entities/credentials.entity.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';

abstract class IgdbRepository {
  Future<List<IgdbSearchResult>> search(String query, IgdbCredentials creds);

  Future<IgdbSearchResult> getDetails(int igdbId, IgdbCredentials creds);
}
