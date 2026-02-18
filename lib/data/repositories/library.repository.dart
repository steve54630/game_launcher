import 'package:game_launcher/core/utils/logger.dart';
import 'package:game_launcher/data/models/library.model.dart';
import 'package:game_launcher/domain/repositories/librairy.respository.dart';

import '../../core/utils/database_helper.dart';
import '../../domain/entities/librairy.entity.dart';

class LibrarySourceRepositoryImpl implements LibrarySourceRepository {
  final DatabaseHelper dbHelper;

  LibrarySourceRepositoryImpl(this.dbHelper);

  @override
  Future<List<LibrarySource>> getAllSources() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('library_sources');

      return maps.map((map) => LibrarySourceModel.fromMap(map)).toList();
    } catch (e, stack) {
      AppLogger.error("Erreur lors de la récupération des sources", e, stack);
      return [];
    }
  }

  @override
  Future<void> addSource(String path) async {
    try {
      final db = await dbHelper.database;
      final model = LibrarySourceModel(path: path, lastScanAt: DateTime.now());

      await db.insert('library_sources', model.toMap());

      AppLogger.info("Nouvelle source ajoutée : $path");
    } catch (e, stack) {
      AppLogger.error("Impossible d'ajouter la source : $path", e, stack);
      rethrow;
    }
  }

  @override
  Future<void> removeSource(int sourceId) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'library_sources',
        where: 'id = ?',
        whereArgs: [sourceId],
      );

      AppLogger.info("Source ID $sourceId supprimée.");
    } catch (e, stack) {
      AppLogger.error(
        "Erreur lors de la suppression de la source ID $sourceId",
        e,
        stack,
      );
      rethrow;
    }
  }
}
