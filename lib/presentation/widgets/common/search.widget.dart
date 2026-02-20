import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/extensions.dart';
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
        // Reset du filtre de recherche global
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSearching)
            Container(
              width: 250, // Largeur de la barre sur Desktop
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
                  // Mise à jour réactive du provider
                  ref.read(librarySearchProvider.notifier).state = value;
                },
              ),
            ),
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            tooltip: isSearching ? "Fermer" : "Rechercher",
            onPressed: _toggleSearch,
          ),
          // Bouton Filtre
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
