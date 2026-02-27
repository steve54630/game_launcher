import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/core/providers/usecase.providers.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';

class SearchGameModal extends ConsumerStatefulWidget {
  const SearchGameModal({super.key});

  @override
  ConsumerState<SearchGameModal> createState() => _SearchGameModalState();
}

class _SearchGameModalState extends ConsumerState<SearchGameModal> {
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final initialTerm = ref.read(gameSearchTermProvider);
    _controller = TextEditingController(text: initialTerm);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value, dynamic target) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // On attend 500ms avant de lancer la requête IGDB (Debouncing)
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.read(gameSearchTermProvider.notifier).updateTerm(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final target = ref.watch(activeImportTargetProvider);
    final searchAsync = ref.watch(igdbResultsProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: const BoxConstraints(maxHeight: 650, maxWidth: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (val) => _onSearchChanged(val, target),
            decoration: InputDecoration(
              hintText: "Nom du jeu (ex: Cyberpunk 2077)",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchAsync.isLoading
                  ? Transform.scale(
                      scale: 0.5,
                      child: const CircularProgressIndicator(),
                    )
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _onSearchChanged("", target);
                      },
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Expanded(
            child: searchAsync.when(
              skipLoadingOnReload: true,
              data: (results) => _buildResultsList(results, target),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => _buildError(err),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "RECHERCHE IGDB",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildResultsList(List<dynamic> results, dynamic target) {
    if (results.isEmpty) {
      return const Center(
        child: Text("Aucun jeu trouvé. Essayez un autre nom."),
      );
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final game = results[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: game.coverUrl != null
                ? Image.network(
                    game.coverUrl!,
                    width: 45,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
                  )
                : const SizedBox(width: 45, child: Icon(Icons.videogame_asset)),
          ),
          title: Text(
            game.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            game.releaseDate != null
                ? "Sortie en ${game.releaseDate!.year}"
                : "Date inconnue",
          ),
          onTap: () {
            target?.setIgdbMatch(game);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildError(Object err) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 8),
          Text(
            err.toString().replaceAll('Exception: ', ''),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}
