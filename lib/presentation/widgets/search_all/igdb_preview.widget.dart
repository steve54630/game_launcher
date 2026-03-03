import 'package:flutter/material.dart';
import 'package:game_launcher/domain/entities/discovery_result.entity.dart';

class MetadataPreview extends StatelessWidget {
  final DiscoveryResult result;
  const MetadataPreview({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final match =
        result.selectedMatch ??
        (result.proposals.isNotEmpty ? result.proposals.first : null);

    if (match == null) {
      return const Text(
        "Aucun match trouvé",
        style: TextStyle(color: Colors.orange, fontSize: 12),
      );
    }

    // On change la couleur si c'est un match validé manuellement (optionnel mais sympa pour l'UX)
    final isManualMatch = result.selectedMatch != null;

    return Row(
      children: [
        if (match.coverUrl != null)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                match.coverUrl!,
                width: 20,
                height: 28,
                fit: BoxFit.cover,
                // Gestion d'erreur pour les images réseau
                errorBuilder: (_, _, _) => Container(
                  width: 20,
                  height: 28,
                  color: Colors.grey.withValues(alpha: 0.2),
                  child: const Icon(Icons.broken_image, size: 10),
                ),
              ),
            ),
          ),
        Expanded(
          child: Text(
            match.name,
            style: TextStyle(
              color: isManualMatch ? Colors.blueAccent : Colors.green,
              fontWeight: isManualMatch ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
