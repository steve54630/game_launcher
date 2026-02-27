import 'package:game_launcher/domain/entities/discovery_result.entity.dart';
import 'package:game_launcher/domain/entities/game.entity.dart';
import 'package:game_launcher/domain/entities/game_details.entity.dart';

class GameWithDetailsModel extends GameWithDetails {
  GameWithDetailsModel({required super.game, super.details});

  factory GameWithDetailsModel.fromDiscovery(DiscoveryResult result) {
    return GameWithDetailsModel(
      game: Game(
        displayName: result.rawName,
        executablePath: result.fullPath,
        igdbId: result.igdbMatch?.igdbId,
      ),
      details: result.igdbMatch,
    );
  }
}
