import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/presentation/state/matchable.entity.dart';

mixin IgdbMatchableNotifier<S> on Notifier<S> implements IgdbMatchable {
  // Cette méthode sera implémentée par les notifiers pour mettre à jour leur état spécifique
  @override
  void applyMatch(IgdbSearchResult game, {String? path});

  @override
  void setIgdbMatch(IgdbSearchResult game) {
    applyMatch(game);
  }
}
