import 'package:flutter/material.dart';
import 'package:game_launcher/presentation/pages/import_page.dart';
import 'package:game_launcher/presentation/pages/library.page.dart';
import 'package:game_launcher/presentation/widgets/menu.widget.dart';
import 'dart:io';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const LibraryPage(), // Ta liste de jeux
    const GameImportPage(), // Ta page d'import
    const Center(child: Text("Options")),
  ];

  void _onNavigation(int index) {
    // Si l'index est 3, c'est le bouton Quitter
    if (index == 3) {
      exit(0);
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppNavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onNavigation,
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
