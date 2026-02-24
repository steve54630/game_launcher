import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';

class SearchGameModal extends ConsumerWidget {
  const SearchGameModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ;
    final notifier = ref.read(importProvider.notifier);
    final searchAsync = ref.watch(igdbResultsProvider);

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
            onChanged: notifier.updateDisplayName,
            decoration: InputDecoration(
              hintText: "Entrez le nom du jeu...",
              prefixIcon: const Icon(Icons.search),
              suffix: searchAsync.isLoading
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
            child: searchAsync.when(
              data: (results) => results.isEmpty
                  ? const Center(child: Text("Aucun résultat trouvé"))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final game = results[index];
                        return ListTile(
                          leading: game.coverUrl != null
                              ? Image.network(
                                  game.coverUrl!,
                                  width: 40,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.videogame_asset),
                          title: Text(game.name),
                          subtitle: Text(
                            game.releaseDate != null
                                ? "${game.releaseDate!.day}/${game.releaseDate!.month}/${game.releaseDate!.year}"
                                : "Date inconnue",
                          ),
                          onTap: () {
                            notifier.setIgdbMatch(game);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text(
                  "Erreur : ${err.toString().replaceAll('Exception: ', '')}",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
