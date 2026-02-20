import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/presentation/widgets/search/left.widget.dart';
import 'package:game_launcher/presentation/widgets/search/right.widget.dart';

class GameImportPage extends ConsumerWidget {
  const GameImportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un jeu")),
      body: Row(
        children: [
          const Expanded(flex: 2, child: LeftImportSection()),
          const VerticalDivider(width: 1),
          const Expanded(flex: 3, child: RightImportSection()),
        ],
      ),
    );
  }
}
