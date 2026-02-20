import 'package:game_launcher/domain/entities/search_result.entity.dart';

abstract class IgdbCacheRepository {
  Future<void> saveToCache(IgdbSearchResult metadata);

  Future<IgdbSearchResult?> getCachedMetadata(int igdbId);

  Future<void> deleteFromCache(int igdbId);
}
