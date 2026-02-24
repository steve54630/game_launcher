import 'package:flutter/material.dart';
import 'package:game_launcher/presentation/widgets/game_details/delete_game.widget.dart';
import 'package:game_launcher/presentation/widgets/game_details/game_card.widget.dart';
import '../../../../core/theme/app.spacing.dart';
import '../../../domain/entities/game_details.entity.dart';
import '../../pages/game_details.page.dart';

class GameGridView extends StatelessWidget {
  final List<GameWithDetails> games;

  const GameGridView({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.l),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 500, // Largeur max pour tes cartes horizontales
        mainAxisExtent: 200, // Hauteur fixe pour tes GameCard
        crossAxisSpacing: AppSpacing.m,
        mainAxisSpacing: AppSpacing.m,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        return GameCard(
          gameDetails: games[index],
          onShowDetails: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameDetailsPage(item: games[index]),
              ),
            );
          },
          onDelete: () => DeleteGameDialog.show(context, games[index].game),
        );
      },
    );
  }
}
