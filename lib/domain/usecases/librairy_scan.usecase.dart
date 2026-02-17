import 'package:game_launcher/domain/entities/discovery_result.entity.dart';
import 'package:game_launcher/domain/repositories/process.repository.dart';

class ScanLibrarySource {
  final ProcessRepository repository;

  ScanLibrarySource(this.repository);

  Future<List<DiscoveryResult>> execute(String path) async {
    final results = await repository.scanForExecutables(path);

    // Logique métier : on ne présente à l'utilisateur que
    // les résultats ayant un minimum de pertinence.
    return results.where((res) => res.confidenceScore > 0.1).toList();
  }
}
