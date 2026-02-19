import 'package:flutter/material.dart';
import 'package:game_launcher/core/theme/app.colors.dart';
import 'package:game_launcher/presentation/layout/main.layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Launcher',
      debugShowCheckedModeBanner: false,
      // On configure un thème sombre par défaut pour coller au design
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          surface: AppColors.surface,
        ),
        // Style par défaut des boutons pour le test
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const MainLayout(),
    );
  }
}
