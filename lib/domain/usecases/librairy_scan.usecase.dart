import 'package:game_launcher/domain/entities/discovery_result.entity.dart';
import 'package:game_launcher/domain/repositories/process.repository.dart';

class ScanLibrarySource {
  final ProcessRepository repository;

  ScanLibrarySource(this.repository);

  Future<List<DiscoveryResult>> execute(String path) async {
    final results = await repository.scanForExecutables(path);

    return results.toList();
  }
}
