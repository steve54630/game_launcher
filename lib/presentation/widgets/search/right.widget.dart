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

    // On extrait le match depuis le DiscoveryResult
    final game = state.result?.selectedMatch;
    final searchAsync = ref.watch(igdbResultsProvider);

    // Écoute les résultats pour l'auto-matching
    ref.listen<AsyncValue<List<IgdbSearchResult>>>(igdbResultsProvider, (
      previous,
      next,
    ) {
      final notifier = ref.read(importProvider.notifier);

      if (searchTerm.trim().isEmpty) return;

      next.whenData((results) {
        if (results.isEmpty) {
          // Utilise une méthode de ton notifier pour gérer l'erreur UI si besoin
        } else {
          // On n'auto-sélectionne que si aucun match n'est déjà fixé
          if (state.result?.selectedMatch == null) {
            notifier.applyMatch(results.first);
          }
        }
      });
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
              // On utilise l'ID IGDB comme clé pour reset le scroll quand le jeu change
              key: ValueKey(game?.igdbId),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IgdbMatchCard(
                    title:
                        game?.name ??
                        (searchTerm.isEmpty
                            ? "En attente de sélection de fichier"
                            : "Recherche en cours..."),
                    imageUrl: game?.coverUrl,
                    onEdit: () {
                      // On définit la cible de la modal (BYOK/Interface commune)
                      ref.read(activeImportTargetProvider.notifier).state = ref
                          .read(importProvider.notifier);

                      // On s'assure que la modal s'ouvre avec le terme actuel
                      final currentTerm =
                          state.result?.effectiveSearchTerm ?? "";
                      ref
                          .read(gameSearchTermProvider.notifier)
                          .updateTerm(currentTerm);

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
