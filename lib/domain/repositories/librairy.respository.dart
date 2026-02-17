import 'package:game_launcher/domain/entities/librairy.entity.dart';

abstract interface class LibrarySourceRepository {
  Future<List<LibrarySource>> getAllSources();
  Future<void> addSource(String path);
  Future<void> removeSource(int sourceId);
}
