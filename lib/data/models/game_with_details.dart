import 'package:game_launcher/domain/entities/discovery_result.entity.dart';
import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:game_launcher/domain/entities/game_details.entity.dart';

class GameWithDetailsModel extends GameWithDetails {
  GameWithDetailsModel({required super.game, super.details});

  factory GameWithDetailsModel.fromDiscovery(DiscoveryResult result) {
    // On part du principe que la validation isReady est faite en amont
    return GameWithDetailsModel(
      game: Game(
        executablePath: result.fullPath,
        igdbId: result.selectedMatch?.igdbId,
      ),
      details: result.selectedMatch,
    );
  }
}