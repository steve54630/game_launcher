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
    _nameController = TextEditingController();

    Future.microtask(() {
      if (mounted) {
        final initialName = ref.read(importProvider).searchName ?? "";
        _nameController.text = initialName;
        if (initialName.isNotEmpty) {
          ref.read(gameSearchTermProvider.notifier).updateTerm(initialName);
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleNameChange(String value) {
    // Met à jour le state de l'import (nom affiché)
    ref.read(importProvider.notifier).updateSearchName(value);

    // Met à jour la recherche IGDB (déclenche le provider de résultats)
    ref.read(gameSearchTermProvider.notifier).updateTerm(value);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importProvider);
    final notifier = ref.read(importProvider.notifier);

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
            selectedPath: state.localPath,
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
