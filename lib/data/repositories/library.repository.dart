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
    AppLogger.info(
      "LibrarySourceRepo: Récupération de tous les dossiers sources...",
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('library_sources');

      AppLogger.info(
        "LibrarySourceRepo: ${maps.length} source(s) trouvée(s) en base.",
      );
      return maps.map((map) => LibrarySourceModel.fromMap(map)).toList();
    } catch (e, stack) {
      AppLogger.error(
        "LibrarySourceRepo: Erreur lors de la récupération des sources",
        e,
        stack,
      );
      return [];
    }
  }

  @override
  Future<void> addSource(String path) async {
    AppLogger.info(
      "LibrarySourceRepo: Tentative d'ajout d'une nouvelle source: $path",
    );
    try {
      final db = await dbHelper.database;

      // On logue la création du modèle pour vérifier la date de scan initiale
      final model = LibrarySourceModel(path: path, lastScanAt: DateTime.now());
      AppLogger.debug(
        "LibrarySourceRepo: Timestamp du premier scan fixé à ${model.lastScanAt}",
      );

      await db.insert('library_sources', model.toMap());

      AppLogger.info(
        "LibrarySourceRepo: Nouvelle source ajoutée avec succès: $path",
      );
    } catch (e, stack) {
      AppLogger.error(
        "LibrarySourceRepo: Impossible d'ajouter la source: $path",
        e,
        stack,
      );
      rethrow;
    }
  }

  @override
  Future<void> removeSource(int sourceId) async {
    AppLogger.warning(
      "LibrarySourceRepo: Demande de suppression de la source ID: $sourceId",
    );
    try {
      final db = await dbHelper.database;
      final count = await db.delete(
        'library_sources',
        where: 'id = ?',
        whereArgs: [sourceId],
      );

      if (count > 0) {
        AppLogger.info(
          "LibrarySourceRepo: Source ID $sourceId supprimée avec succès.",
        );
      } else {
        AppLogger.warning(
          "LibrarySourceRepo: Aucune source trouvée avec l'ID $sourceId pour suppression.",
        );
      }
    } catch (e, stack) {
      AppLogger.error(
        "LibrarySourceRepo: Erreur lors de la suppression de la source ID $sourceId",
        e,
        stack,
      );
      rethrow;
    }
  }
}
