import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';
import 'package:game_launcher/presentation/widgets/game_details/gallery.widget.dart';
import 'package:game_launcher/presentation/widgets/search/game_search.widget.dart';
import 'package:game_launcher/presentation/widgets/search/igdb_match.widget.dart';
import 'package:game_launcher/presentation/widgets/search/import_button.widget.dart';
import 'package:game_launcher/providers.dart';

class RightImportSection extends ConsumerWidget {
  const RightImportSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importProvider);
    final game = state.selectedIgdbGame;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: "3. LIAISON IGDB",
            isLoading: state.isSearching,
          ),
          const SizedBox(height: AppSpacing.m),
          IgdbMatchCard(
            title: game?.name ?? "Aucun jeu lié",
            imageUrl: game?.coverUrl,
            onEdit: () => showDialog(
              context: context,
              builder: (_) => const Dialog(child: SearchGameModal()),
            ),
          ),
          if (game != null) ...[
            const SizedBox(height: AppSpacing.l),

            if (game.screenshots.isNotEmpty) ...[
              GameScreenshotGallery(screenshots: game.screenshots),
              const SizedBox(height: AppSpacing.l),
            ],
            if (game.screenshots.isEmpty) ...[
              IgdbMatchCard(
                title: game.name,
                imageUrl: game.coverUrl,
                onEdit: () => showDialog(
                  context: context,
                  builder: (_) => const Dialog(child: SearchGameModal()),
                ),
              ),
            ],

            const Divider(color: Colors.white10),
            const SizedBox(height: AppSpacing.l),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailInfo(
                  label: "Sortie",
                  value: game.releaseDate.toString(),
                ),
                const SizedBox(width: AppSpacing.xl),
                if (game.genre != null)
                  _DetailInfo(label: "Genre", value: game.genre!.name),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            const Text("SYNOPSIS", style: _labelStyle),
            const SizedBox(height: AppSpacing.s),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  game.summary ?? "Aucune description disponible.",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ] else
            const Spacer(),
          const SizedBox(height: AppSpacing.m),
          const ImportActionButton(),
        ],
      ),
    );
  }
}

const _labelStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.bold,
  color: Colors.white38,
  letterSpacing: 1.2,
);

class _DetailInfo extends StatelessWidget {
  final String label;
  final String value;
  const _DetailInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: _labelStyle),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isLoading;
  const _SectionHeader({required this.title, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (isLoading) ...[
          const SizedBox(width: AppSpacing.m),
          const SizedBox(
            height: 14,
            width: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ],
    );
  }
}
