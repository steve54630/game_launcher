import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';
import 'package:game_launcher/domain/entities/search_result.entity.dart';
import 'package:game_launcher/presentation/widgets/common/gallery.widget.dart';
import 'package:game_launcher/presentation/widgets/common/video_preview.widget.dart';
import 'package:game_launcher/presentation/widgets/search/game_search.widget.dart';
import 'package:game_launcher/presentation/widgets/search/igdb_match.widget.dart';
import 'package:game_launcher/presentation/widgets/search/import_button.widget.dart';
import 'package:game_launcher/presentation/widgets/search/left/detail.widget.dart';
import 'package:game_launcher/presentation/widgets/search/left/header.widget.dart';

class RightImportSection extends ConsumerWidget {
  const RightImportSection({super.key});

  static const labelStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 12,
    color: Colors.white54,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchTerm = ref.watch(gameSearchTermProvider);
    final state = ref.watch(importProvider);
    final game = state.selectedIgdbGame;
    final searchAsync = ref.watch(igdbResultsProvider);

    // Écoute les résultats de recherche pour l'auto-matching
    ref.listen<AsyncValue<List<IgdbSearchResult>>>(igdbResultsProvider, (
      previous,
      next,
    ) {
      final notifier = ref.read(importProvider.notifier);

      if (searchTerm.trim().isEmpty) {
        notifier.setErrorMessage(null);
        return;
      }

      next.when(
        data: (results) {
          if (results.isEmpty) {
            notifier.setErrorMessage("Aucun jeu trouvé sur IGDB.");
          } else {
            notifier.setErrorMessage(null);

            // On n'auto-sélectionne le premier résultat QUE si l'utilisateur
            // n'a pas déjà fait un choix manuel via la modal.
            if (state.selectedIgdbGame == null) {
              notifier.applyMatch(results.first);
            }
          }
        },
        error: (err, stack) =>
            notifier.setErrorMessage("Erreur technique IGDB."),
        loading: () {},
      );
    });

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: "3. LIAISON IGDB",
            isLoading: searchAsync.isLoading,
          ),
          const SizedBox(height: AppSpacing.m),
          Expanded(
            child: SingleChildScrollView(
              key: ValueKey(game?.igdbId),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IgdbMatchCard(
                    title:
                        game?.name ??
                        (searchTerm.isEmpty
                            ? "En attente de saisie"
                            : "Recherche en cours..."),
                    imageUrl: game?.coverUrl,
                    onEdit: () {
                      ref.read(activeImportTargetProvider.notifier).state = ref
                          .read(importProvider.notifier);

                      // On initialise la recherche avec le nom actuellement dans le state
                      final currentName =
                          ref.read(importProvider).searchName ?? "";
                      ref
                          .read(gameSearchTermProvider.notifier)
                          .updateTerm(currentName);

                      showDialog(
                        context: context,
                        builder: (_) => const Dialog(child: SearchGameModal()),
                      );
                    },
                  ),
                  if (game != null) ...[
                    const SizedBox(height: AppSpacing.l),
                    if (game.screenshots.isNotEmpty) ...[
                      GameScreenshotGallery(screenshots: game.screenshots),
                      const SizedBox(height: AppSpacing.l),
                    ],
                    const Divider(color: Colors.white10),
                    const SizedBox(height: AppSpacing.l),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DetailInfo(
                          label: "Sortie",
                          value: game.releaseDate != null
                              ? "${game.releaseDate!.day}/${game.releaseDate!.month}/${game.releaseDate!.year}"
                              : "Inconnue",
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        if (game.genre != null)
                          DetailInfo(label: "Genre", value: game.genre!.name),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.l),
                    const Text("SYNOPSIS", style: labelStyle),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      game.summary ?? "Aucune description disponible.",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    if (game.youtubeVideoId != null) ...[
                      const Text("PREVIEW", style: labelStyle),
                      const SizedBox(height: AppSpacing.m),
                      GameVideoPreview(
                        key: ValueKey(game.youtubeVideoId),
                        youtubeVideoId: game.youtubeVideoId!,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          const ImportActionButton(),
        ],
      ),
    );
  }
}
