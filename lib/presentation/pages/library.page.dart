import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/domain/model/game.model.dart';
import 'package:game_launcher/presentation/widgets/common/search.widget.dart';
import 'package:game_launcher/presentation/widgets/game_details/game_grid.widget.dart';
import '../../../core/theme/app.spacing.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute la liste filtrée (via le provider créé précédemment)
    final filteredGamesAsync = ref.watch(filteredGamesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ma Bibliothèque"),
        actions: [
          // On passe la liste actuelle aux actions pour la logique si besoin
          // ou on laisse le widget interne gérer ses propres watch
          const LibraryAppBarActions(),
        ],
      ),
      body: filteredGamesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Erreur : $err")),
        data: (games) => Column(
          children: [
            _buildLibraryHeader(context, games),
            Expanded(child: GameGridView(games: games)),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryHeader(
    BuildContext context,
    List<GameWithDetails> games,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.s,
      ),
      child: Row(
        children: [
          Text(
            "${games.length} jeux",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white38),
          ),
        ],
      ),
    );
  }
}
