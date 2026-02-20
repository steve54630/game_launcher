import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/extensions.dart';
import 'package:game_launcher/core/theme/app.colors.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';
import 'package:game_launcher/presentation/widgets/filter/header.widget.dart';
import 'package:game_launcher/presentation/widgets/filter/sort_chip.widget.dart';

class LibraryFilterSheet extends ConsumerWidget {
  const LibraryFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute le type de tri actuel pour cocher le bon ChoiceChip
    final currentSort = ref.watch(librarySortProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilterHeader(),
          const Divider(height: AppSpacing.l),

          // --- SECTION TRI ---
          const Text("TRIER PAR", style: _sectionLabelStyle),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            children: [
              SortChoiceChip(
                label: "Nom",
                value: LibrarySortType.name,
                currentValue: currentSort,
                onSelected: (type) =>
                    ref.read(librarySortProvider.notifier).state = type,
              ),
              SortChoiceChip(
                label: "Date",
                value: LibrarySortType.releaseDate,
                currentValue: currentSort,
                onSelected: (type) =>
                    ref.read(librarySortProvider.notifier).state = type,
              ),
              SortChoiceChip(
                label: "Genre",
                value: LibrarySortType.genre,
                currentValue: currentSort,
                onSelected: (type) =>
                    ref.read(librarySortProvider.notifier).state = type,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // --- BOUTON FERMER ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("FERMER"),
            ),
          ),
        ],
      ),
    );
  }

  static const _sectionLabelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: Colors.white54,
    letterSpacing: 1.2,
  );
}
