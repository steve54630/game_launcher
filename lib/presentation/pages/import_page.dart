import 'package:flutter/material.dart';
import 'package:game_launcher/presentation/widgets/search/flie_picker.widget.dart';
import 'package:game_launcher/presentation/widgets/search/game_search.widget.dart';
import 'package:game_launcher/presentation/widgets/search/igdb_match.widget.dart';
import '../../../core/theme/app.spacing.dart';

class GameImportPage extends StatelessWidget {
  const GameImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un jeu")),
      body: Row(
        children: [
          // Colonne de gauche : Fichier local
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SOURCE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white30,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  FilePickerZone(
                    selectedPath: "C:/Games/Hades/Hades.exe", // Simulation
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.l),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: "Nom d'affichage local",
                      hintText: "Ex: Hades",
                    ),
                  ),
                ],
              ),
            ),
          ),

          const VerticalDivider(width: 1),

          // Colonne de droite : Méta-données
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "CORRESPONDANCE IGDB",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white30,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  IgdbMatchCard(
                    title: "Hades",
                    subtitle: "Supergiant Games (2020)",
                    onEdit: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            const Dialog(child: SearchGameModal()),
                      );
                    },
                  ),
                  const Spacer(),
                  _buildImportButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        child: const Text("IMPORTER DANS LA BIBLIOTHÈQUE"),
      ),
    );
  }
}
