import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';

class SearchGameModal extends ConsumerWidget {
  const SearchGameModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importProvider);
    final notifier = ref.read(importProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
      child: Column(
        children: [
          const Text(
            "RECHERCHER SUR IGDB",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            autofocus: true,
            onChanged: notifier.searchIgdb,
            decoration: InputDecoration(
              hintText: "Entrez le nom du jeu...",
              prefixIcon: const Icon(Icons.search),
              suffix: state.isSearching
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Expanded(
            child: ListView.builder(
              itemCount: state.searchResults.length,
              itemBuilder: (context, index) {
                final game = state.searchResults[index];
                return ListTile(
                  leading: game.coverUrl != null
                      ? Image.network(
                          game.coverUrl!,
                          width: 40,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.videogame_asset),
                  title: Text(game.name),
                  subtitle: Text(game.releaseDate.toString()),
                  onTap: () {
                    notifier.setIgdbMatch(game);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
