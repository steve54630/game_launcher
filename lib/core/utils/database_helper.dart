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
    sqfliteFfiInit();
    final databaseFactory = databaseFactoryFfi;

    final dbDirectory = await getApplicationSupportDirectory();
    final path = join(dbDirectory.path, fileName);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: createDB,
        onConfigure: onConfigure,
      ),
    );
  }

  Future<void> onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('PRAGMA journal_mode = WAL');
  }

  Future<void> createDB(Database db, int version) async {
    final batch = db.batch();

    // 1. Table des Genres (Référentiel normalisé)
    batch.execute('''
      CREATE TABLE genres (
        id INTEGER PRIMARY KEY, -- ID officiel IGDB
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // 2. Cache IGDB (Enrichi avec le genre principal et la date)
    batch.execute('''
      CREATE TABLE igdb_cache (
        igdb_id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        cover_url TEXT,
        summary TEXT,
        screenshot_urls TEXT, -- Stocké en JSON ou CSV
        video_id TEXT,
        release_date TEXT,    -- ISO8601 String
        genre_id INTEGER,     -- FK vers genres
        updated_at TEXT NOT NULL,
        FOREIGN KEY (genre_id) REFERENCES genres (id) ON DELETE SET NULL
      )
    ''');

    // 3. Ta table de jeux locaux
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
