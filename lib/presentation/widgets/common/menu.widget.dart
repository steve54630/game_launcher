import 'package:flutter/material.dart';
import '../../../../core/theme/app.colors.dart';

class AppNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const AppNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: AppColors.surface,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      indicatorColor: AppColors.primary.withValues(alpha: 0.2),
      selectedIconTheme: const IconThemeData(color: AppColors.primary),
      unselectedIconTheme: const IconThemeData(color: Colors.white30),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.library_books_outlined),
          selectedIcon: Icon(Icons.library_books),
          label: Text('Jeux'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle),
          label: Text('Importer'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle),
          label: Text('Import multiple'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Paramètres'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.login_outlined),
          selectedIcon: Icon(Icons.login),
          label: Text('Connexion'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.power_settings_new),
          label: Text('Quitter'),
        ),
      ],
    );
  }
}
