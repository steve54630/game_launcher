import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/presentation/pages/import_all.page.dart';
import 'package:game_launcher/presentation/pages/import_page.dart';
import 'package:game_launcher/presentation/pages/library.page.dart';
import 'package:game_launcher/presentation/pages/settings.page.dart';
import 'package:game_launcher/presentation/widgets/common/connect.widget.dart';
import 'package:game_launcher/presentation/widgets/common/menu.widget.dart';
import 'dart:io';

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  final List<Widget> _pages = const [
    LibraryPage(),
    GameImportPage(),
    MultiGameImportPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: Row(
        children: [
          AppNavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              if (index == 5) exit(0);
              if (index == 4) {
                _showIgdbAuthDialog(context);
                return;
              }
              // Mise à jour via le provider
              ref.read(navigationIndexProvider.notifier).state = index;
            },
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: _pages[selectedIndex]),
        ],
      ),
    );
  }

  void _showIgdbAuthDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const IgdbAuthModal());
  }
}
