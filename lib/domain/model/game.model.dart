import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';

class GameWithDetails {
  final Game game;
  final IgdbSearchResult? details;

  GameWithDetails({required this.game, this.details});
}
