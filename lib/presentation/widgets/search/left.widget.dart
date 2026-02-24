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
        final initialValue = ref.read(importProvider).displayName ?? "";
        _nameController.text = initialValue;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(importProvider.select((s) => s.displayName), (
      previous,
      next,
    ) {
      if (next != null && next != _nameController.text) {
        _nameController.text = next;
        _nameController.selection = TextSelection.fromPosition(
          TextPosition(offset: _nameController.text.length),
        );
      }
    });

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
            onChanged: (value) => notifier.updateDisplayName(value),
            decoration: const InputDecoration(
              labelText: "Nom d'affichage",
              prefixIcon: Icon(Icons.edit),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
