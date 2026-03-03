import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:game_launcher/core/theme/app.colors.dart';
import 'package:game_launcher/presentation/layout/main.layout.dart';
import 'package:game_launcher/presentation/layout/watcher.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  ThemeMode _getThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      data: (settings) => MaterialApp(
        title: 'Game Launcher',
        debugShowCheckedModeBanner: false,
        themeMode: _getThemeMode(settings.themeMode),
        // Thème Clair
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.blueGrey,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
        ),
        // Thème Sombre
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
            surface: AppColors.surface,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        home: WindowWatcher(child: const MainLayout()),
      ),
      // Écran de chargement pendant que la BDD s'initialise
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      // Repli en cas d'erreur critique
      error: (err, stack) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Erreur d\'initialisation : $err')),
        ),
      ),
    );
  }
}
