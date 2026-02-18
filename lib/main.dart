import 'dart:io';

import 'package:flutter/material.dart';
import 'package:game_launcher/core/utils/database_helper.dart';
import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/presentation/pages/myapp.page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialisation du logger
  await AppLogger.init();
  AppLogger.info("Lancement de l'application");

  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    AppLogger.info("FFI SQLite configuré pour Windows");
  }

  try {
    // 2. Appel de l'initialisation
    // Le simple fait d'accéder au getter 'database' déclenche _initDB puis _createDB
    final db = await DatabaseHelper.instance.database;

    AppLogger.info("Base de données initialisée avec succès : ${db.path}");
  } catch (e) {
    AppLogger.error("Erreur lors de l'initialisation de la base : $e");
  }

  runApp(const MyApp());
}
