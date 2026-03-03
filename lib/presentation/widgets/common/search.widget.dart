import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';
import 'package:game_launcher/presentation/widgets/filter/filter.widget.dart';

class LibraryAppBarActions extends ConsumerStatefulWidget {
  const LibraryAppBarActions({super.key});

  @override
  ConsumerState<LibraryAppBarActions> createState() =>
      _LibraryAppBarActionsState();
}

class _LibraryAppBarActionsState extends ConsumerState<LibraryAppBarActions> {
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        ref.read(librarySearchProvider.notifier).state = "";
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // On observe le mode d'affichage actuel
    final displayMode = ref.watch(
      settingsProvider.select((s) => s.value?.libraryDisplayMode ?? 'grid'),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSearching)
            Container(
              width: 250,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "Rechercher un jeu...",
                  border: InputBorder.none,
                  isDense: true,
                  hintStyle: TextStyle(color: Colors.white24),
                ),
                onChanged: (value) {
                  ref.read(librarySearchProvider.notifier).state = value;
                },
              ),
            ),
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            tooltip: isSearching ? "Fermer" : "Rechercher",
            onPressed: _toggleSearch,
          ),
          // Bouton pour switcher Grid / List
          IconButton(
            icon: Icon(
              displayMode == 'grid'
                  ? Icons.format_list_bulleted_rounded
                  : Icons.grid_view_rounded,
            ),
            tooltip: displayMode == 'grid'
                ? "Passer en vue liste"
                : "Passer en vue grille",
            onPressed: () {
              final newMode = displayMode == 'grid' ? 'list' : 'grid';
              ref.read(settingsProvider.notifier).toggleDisplayMode(newMode);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => const LibraryFilterSheet(),
              );
            },
          ),
          const SizedBox(width: AppSpacing.s),
        ],
      ),
    );
  }
}
