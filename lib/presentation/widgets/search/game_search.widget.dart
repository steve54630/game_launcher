import 'package:flutter/material.dart';
import '../../../../../core/theme/app.spacing.dart';

class SearchGameModal extends StatelessWidget {
  const SearchGameModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      // On fixe une hauteur pour la modal sur Desktop
      constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
      child: Column(
        children: [
          const Text(
            "RECHERCHER SUR IGDB",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.m),
          const TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Entrez le nom du jeu...",
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Simulation de 5 résultats
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.videogame_asset),
                  title: Text("Résultat de recherche #$index"),
                  subtitle: const Text("Studio • Année"),
                  onTap: () => Navigator.pop(context),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
