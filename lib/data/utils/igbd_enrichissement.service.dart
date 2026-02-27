import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/domain/usecases/search_game.usecase.dart';

class IgdbEnrichmentService {
  final SearchGameUseCase _searchUseCase;

  IgdbEnrichmentService(this._searchUseCase);

  String cleanFileName(String fileName) {
    return fileName.replaceAll(
      RegExp(r'\.(exe|lnk|bat|msi)$', caseSensitive: false),
      '',
    );
  }

  Future<List<IgdbSearchResult>> search(String term) async {
    try {
      return await _searchUseCase.execute(term);
    } catch (e) {
      AppLogger.warning("IgdbService: Erreur recherche pour $term");
      rethrow;
    }
  }
}
