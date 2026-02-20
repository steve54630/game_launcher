import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/presentation/widgets/game_details/game_grid.widget.dart';
import '../../../core/theme/app.spacing.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(getGamesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ma Bibliothèque"),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
          const SizedBox(width: AppSpacing.s),
        ],
      ),
      body: libraryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Erreur : $err")),
        data: (games) => Column(
          children: [
            _buildLibraryHeader(context, games.length),
            Expanded(child: GameGridView(games: games)),
          ],
        ),
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
        ],
      ),
    );
  }
}
