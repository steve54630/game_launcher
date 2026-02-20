import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';

class IgdbAuthModal extends ConsumerStatefulWidget {
  const IgdbAuthModal({super.key});

  @override
  ConsumerState<IgdbAuthModal> createState() => _IgdbAuthModalState();
}

class _IgdbAuthModalState extends ConsumerState<IgdbAuthModal> {
  late final TextEditingController _clientIdController;
  late final TextEditingController _clientSecretController;

  @override
  void initState() {
    super.initState();
    _clientIdController = TextEditingController();
    _clientSecretController = TextEditingController();
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    _clientSecretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.vpn_key, color: Colors.purple),
          SizedBox(width: 10),
          Text("Configuration IGDB (BYOK)"),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Entrez vos identifiants Twitch Developer pour activer la recherche de jeux.",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _clientIdController,
            decoration: const InputDecoration(
              labelText: "Client ID",
              border: OutlineInputBorder(),
              hintText: "Ton Client ID",
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _clientSecretController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Client Secret",
              border: OutlineInputBorder(),
              hintText: "Ton Client Secret",
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("ANNULER"),
        ),
        ElevatedButton(
          onPressed: () async {
            // 1. On extrait les données du controller
            final clientId = _clientIdController.text.trim();
            final clientSecret = _clientSecretController.text.trim();

            // 2. On effectue l'opération asynchrone
            await ref
                .read(settingsProvider.notifier)
                .saveCredentials(clientId, clientSecret);

            // 3. On capture le Navigator et le ScaffoldMessenger AVANT le check mounted
            // ou on utilise le context directement s'il est encore valide.
            if (!context.mounted) return;

            // Ici, le context est garanti valide par context.mounted (Flutter 3.7+)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Credentials IGDB enregistrés !")),
            );

            Navigator.of(context).pop();
          },
          child: const Text("ENREGISTRER"),
        ),
      ],
    );
  }
}
