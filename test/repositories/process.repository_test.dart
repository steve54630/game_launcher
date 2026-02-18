import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_launcher/data/repositories/process.repository.dart';

void main() {
  late MemoryFileSystem fs;
  late ProcessRepositoryImpl repository;

  setUp(() {
    fs = MemoryFileSystem(style: FileSystemStyle.windows);
    repository = ProcessRepositoryImpl(fileSystem: fs);
  });

  group('ProcessRepositoryImpl - Scan Tests', () {
    test('Should find valid .exe and ignore filtered ones', () async {
      final gamePath = r'C:\Games\Cyberpunk 2077\bin\x64';
      await fs.directory(gamePath).create(recursive: true);

      await fs.file('$gamePath\\Cyberpunk2077.exe').create();
      await fs.file('$gamePath\\Cyberpunk2077_unins.exe').create();
      await fs.file('$gamePath\\crashpad_handler.exe').create();
      await fs.file('$gamePath\\settings.json').create();

      final results = await repository.scanForExecutables(r'C:\Games');

      expect(results.length, 1);
      expect(results.first.rawName, 'Cyberpunk2077.exe');
      expect(results.first.pathSegments, contains('Cyberpunk 2077'));
      expect(results.first.pathSegments, isNot(contains('C:')));
    });

    test('Should return empty list if directory does not exist', () async {
      final results = await repository.scanForExecutables(r'D:\NonExistent');
      expect(results, isEmpty);
    });
  });

  group('ProcessRepositoryImpl - Execution & Process Management', () {
    test(
      'openExecutable should throw exception if file not found in FileSystem',
      () async {
        expect(
          () => repository.openExecutable(r'C:\MissingGame.exe'),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'isProcessRunning should return false if tasklist fails (Edge Case)',
      () async {
        // On utilise un nom de fichier totalement improbable avec des caractères spéciaux
        // pour garantir que tasklist ne retournera rien
        final isRunning = await repository.isProcessRunning(
          'NON_EXISTENT_GAME_Z9Y8X7.exe',
        );

        expect(isRunning, false);
      },
    );
  });

  group('ProcessRepositoryImpl - Edge Cases & Robustness', () {
    test('Should be case insensitive for .exe extension', () async {
      final path = r'C:\Games\Minesweeper.EXE';
      await fs.file(path).create(recursive: true);

      final results = await repository.scanForExecutables(r'C:\Games');

      expect(results.length, 1);
      expect(results.first.rawName.toLowerCase(), 'minesweeper.exe');
    });

    test('Should ignore system/hidden directories if possible', () async {
      // Simule un dossier de cache qui pourrait contenir des .exe inutiles
      final cachePath = r'C:\Games\.cache\internal.exe';
      await fs.file(cachePath).create(recursive: true);

      final results = await repository.scanForExecutables(r'C:\Games');

      // Si ton repo ne filtre pas les dossiers cachés, ce test échouera,
      // ce qui te permettra de décider si tu veux ajouter ce filtre.
      expect(results.any((r) => r.pathSegments.contains('.cache')), false);
    });

    test('Should handle very deep paths without crashing', () async {
      String deepPath = r'C:\Source';
      for (int i = 0; i < 20; i++) {
        deepPath += '\\subdir$i';
      }
      await fs.directory(deepPath).create(recursive: true);
      await fs.file('$deepPath\\deep.exe').create();

      final results = await repository.scanForExecutables(r'C:\Source');
      expect(results.length, 1);
    });

    test(
      'Should ignore files that only contain .exe in their name but are not executables',
      () async {
        await fs.file(r'C:\Games\readme.exe.txt').create(recursive: true);
        await fs.file(r'C:\Games\not_an_exe.png').create();

        final results = await repository.scanForExecutables(r'C:\Games');

        expect(results, isEmpty);
      },
    );
  });
}
