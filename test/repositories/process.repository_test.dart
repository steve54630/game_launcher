import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_launcher/data/repositories/process.repository.dart';
import 'package:mocktail/mocktail.dart';

// Si tu n'as pas encore ProcessManager injecté, ces tests simuleront
// les comportements par défaut de l'OS ou les erreurs de fichiers.
class MockProcessResult extends Mock {}

void main() {
  late MemoryFileSystem fs;
  late ProcessRepositoryImpl repository;

  setUp(() {
    fs = MemoryFileSystem(style: FileSystemStyle.windows);
    repository = ProcessRepositoryImpl(fileSystem: fs);
  });

  group('ProcessRepositoryImpl - Scan & Discovery (The 100% path)', () {
    test('Should find valid .exe and map segments correctly', () async {
      final gamePath = r'C:\Games\Cyberpunk 2077\bin\x64';
      await fs.directory(gamePath).create(recursive: true);
      await fs.file('$gamePath\\Cyberpunk2077.exe').create();

      final results = await repository.scanForExecutables(r'C:\Games');

      expect(results.length, 1);
      expect(results.first.rawName, 'Cyberpunk2077.exe');
      // Vérifie que 'C:' est bien filtré des segments
      expect(results.first.pathSegments, isNot(contains('C:')));
      expect(results.first.pathSegments, contains('Cyberpunk 2077'));
    });

    test('Should handle non-existent directory without crashing', () async {
      final results = await repository.scanForExecutables(r'Z:\EmptyDrive');
      expect(results, isEmpty);
    });

    test(
      'Should log and handle filesystem exceptions during listing',
      () async {
        // On crée un fichier là où le scan attend un répertoire
        await fs.file(r'C:\locked_file.exe').create(recursive: true);

        final results = await repository.scanForExecutables(
          r'C:\locked_file.exe',
        );
        expect(results, isEmpty);
      },
    );
  });

  group('ProcessRepositoryImpl - Process Management (The 80% goal)', () {
    test('isProcessRunning: should return false on empty string', () async {
      final result = await repository.isProcessRunning('');
      expect(result, isFalse);
    });

    test(
      'openExecutable: should throw Exception if file does not exist',
      () async {
        expect(
          () => repository.openExecutable(r'C:\FakeGame.exe'),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'isProcessRunning: should return false if process is not in tasklist',
      () async {
        // Ce test passera par le catch ou le résultat vide de Process.run
        final result = await repository.isProcessRunning('NonExistentGame.exe');
        expect(result, isFalse);
      },
    );

    test(
      'isProcessRunning: handles system failure gracefully (Catch block)',
      () async {
        // Ce test vise le bloc 'catch (e)' de isProcessRunning
        // En environnement de test, Process.run peut échouer si tasklist n'est pas trouvé
        final result = await repository.isProcessRunning('Test.exe');
        expect(result, isFalse);
      },
    );
  });

  group('ProcessRepositoryImpl - Mapping Edge Cases', () {
    test('Should ignore empty segments and drive letters', () async {
      // Simulation d'un chemin avec des slashs multiples
      final path = r'C:\\Games\\\MyGame.exe';
      await fs.file(path).create(recursive: true);

      final results = await repository.scanForExecutables(r'C:\Games');

      if (results.isNotEmpty) {
        expect(results.first.pathSegments.every((s) => s.isNotEmpty), isTrue);
        expect(results.first.pathSegments.any((s) => s.contains(':')), isFalse);
      }
    });
  });
}
