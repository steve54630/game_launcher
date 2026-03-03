import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/core/theme/app.spacing.dart';
import 'package:game_launcher/presentation/widgets/search/flie_picker.widget.dart';

class LeftImportSection extends ConsumerStatefulWidget {
  const LeftImportSection({super.key});

  @override
  ConsumerState<LeftImportSection> createState() => _LeftImportSectionState();
}

class _LeftImportSectionState extends ConsumerState<LeftImportSection> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // On initialise avec le nom effectif (custom ou raw)
    final initialName =
        ref.read(importProvider).result?.effectiveSearchTerm ?? "";
    _nameController = TextEditingController(text: initialName);

    if (initialName.isNotEmpty) {
      Future.microtask(() {
        ref.read(gameSearchTermProvider.notifier).updateTerm(initialName);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleNameChange(String value) {
    ref.read(importProvider.notifier).updateSearchName(value);
    ref.read(gameSearchTermProvider.notifier).updateTerm(value);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importProvider);
    final notifier = ref.read(importProvider.notifier);

    // IMPORTANT : Synchroniser le controller si le fichier change via le picker
    // (Le nom du fichier devient le nouveau terme de recherche par défaut)
    ref.listen(importProvider.select((s) => s.result?.effectiveSearchTerm), (
      prev,
      next,
    ) {
      if (next != null && next != _nameController.text) {
        _nameController.text = next;
        // On déclenche la recherche IGDB automatiquement au pick du fichier
        ref.read(gameSearchTermProvider.notifier).updateTerm(next);
      }
    });

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "1. SÉLECTION DU FICHIER",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          FilePickerZone(
            // On utilise le path contenu dans l'objet DiscoveryResult
            selectedPath: state.result?.fullPath,
            onTap: notifier.selectGameFile,
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            "2. INFORMATIONS LOCALES",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _nameController,
            onChanged: _handleNameChange,
            decoration: const InputDecoration(
              labelText: "Nom pour la recherche IGDB",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
