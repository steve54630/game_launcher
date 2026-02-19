import 'package:flutter/material.dart';
import 'package:game_launcher/core/mocks/game.mock.dart';
import 'package:game_launcher/presentation/widgets/game_details/game_grid.widget.dart';
import '../../../core/theme/app.spacing.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mockGames = GameMocks.games;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ma Bibliothèque"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {}, // Futur filtrage par genre
          ),
          const SizedBox(width: AppSpacing.s),
        ],
      ),
      body: Column(
        children: [
          _buildLibraryHeader(context, mockGames.length),
          Expanded(child: GameGridView(games: mockGames)),
        ],
      ),
    );
  }

  Widget _buildLibraryHeader(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      child: Row(
        children: [
          Text(
            "$count jeux installés",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white38),
          ),
          const Spacer(),
          // Une barre de recherche rapide pourrait aller ici
        ],
      ),
    );
  }
}
