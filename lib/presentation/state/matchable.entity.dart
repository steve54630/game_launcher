import 'package:game_launcher/domain/entities/search_result.entity.dart';

abstract class IgdbMatchable {
  void setIgdbMatch(IgdbSearchResult game);
  void applyMatch(IgdbSearchResult game, {String? path});
  void updateSearchName(String name);
}
