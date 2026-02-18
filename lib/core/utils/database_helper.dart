import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('launcher.db');
    return _database!;
  }

  @visibleForTesting
  DatabaseHelper.test();

  @visibleForTesting
  void setTestDatabase(Database db) {
    _database = db;
  }

  Future<Database> _initDB(String fileName) async {
    // 1. Initialiser le moteur FFI pour Windows
    sqfliteFfiInit();
    final databaseFactory = databaseFactoryFfi;

    // 2. Obtenir le dossier de stockage de l'application
    // Sur Windows, cela va généralement dans AppData/Roaming/votre_app
    final dbDirectory = await getApplicationSupportDirectory();
    // Construire le chemin complet du fichier de base de données
    final path = join(dbDirectory.path, fileName);

    // 3. Ouvrir la base de données
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: createDB,
        onConfigure: onConfigure,
      ),
    );
  }

  // Configuration de la base avant création/ouverture
  Future<void> onConfigure(Database db) async {
    // Force le respect des relations entre les tables (ex: Games -> IgdbCache)
    await db.execute('PRAGMA foreign_keys = ON');
    // Optimisation des performances pour Windows (Mode WAL)
    await db.execute('PRAGMA journal_mode = WAL');
  }

  Future<void> createDB(Database db, int version) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE igdb_cache (
        igdb_id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        cover_url TEXT,
        summary TEXT,
        screenshot_urls TEXT,
        video_id TEXT,
        updated_at TEXT NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE games (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        igdb_id INTEGER,
        display_name TEXT NOT NULL,
        executable_path TEXT NOT NULL UNIQUE,
        playtime_seconds INTEGER DEFAULT 0,
        last_played_at TEXT,
        is_favorite INTEGER DEFAULT 0,
        FOREIGN KEY (igdb_id) REFERENCES igdb_cache (igdb_id) ON DELETE SET NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE library_sources (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT NOT NULL UNIQUE,
        last_scan_at TEXT NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await batch.commit(noResult: true);
  }
}
