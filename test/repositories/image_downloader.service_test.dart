import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_launcher/data/utils/image_downloader.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:path/path.dart' as p;

// Mock pour path_provider (nécessaire pour getApplicationSupportDirectory)
class MockPathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getApplicationSupportPath() async =>
      Directory.systemTemp.path;
}

void main() {
  late Directory testDir;

  setUpAll(() {
    PathProviderPlatform.instance = MockPathProvider();
  });

  setUp(() async {
    testDir = Directory(p.join(Directory.systemTemp.path, 'media'));
    if (await testDir.exists()) await testDir.delete(recursive: true);
  });

  group('ImageDownloaderService - Tests', () {
    test('Should return null if URL is empty', () async {
      final result = await ImageDownloaderService.downloadAndSaveImage(
        '',
        'test_folder',
      );
      expect(result, isNull);
    });

    test('Should handle IGDB URLs starting with //', () async {
      // Note: Ce test échouera réellement sans internet ou sans Mock Dio,
      // mais ici on teste la logique de construction de l'URL.
      const url = '//images.igdb.com/igdb/image/upload/t_cover_big/co1r8v.jpg';
      await ImageDownloaderService.downloadAndSaveImage(url, 'test_igdb');

      // On vérifie si le dossier a au moins été créé avant l'erreur réseau potentielle
      final dir = Directory(
        p.join(Directory.systemTemp.path, 'media', 'test_igdb'),
      );
      expect(await dir.exists(), isTrue);
    });

    test('deleteFolder should remove directory if it exists', () async {
      const folderName = 'to_delete';
      final dir = Directory(
        p.join(Directory.systemTemp.path, 'media', folderName),
      );
      await dir.create(recursive: true);

      expect(await dir.exists(), isTrue);

      await ImageDownloaderService.deleteFolder(folderName);

      expect(await dir.exists(), isFalse);
    });

    test('Should catch and log errors gracefully on invalid paths', () async {
      // On force une erreur en utilisant un nom de dossier interdit sur Windows (si possible)
      // ou en simulant une erreur filesystem.
      final result = await ImageDownloaderService.downloadAndSaveImage(
        'http://invalid.url',
        '\u0000',
      );

      expect(result, isNull); // Le catch doit retourner null
    });
  });
}
