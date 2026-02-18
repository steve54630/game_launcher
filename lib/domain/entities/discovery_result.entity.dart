import 'package:game_launcher/domain/entities/search_result.entity.dart';

class DiscoveryResult {
  final String rawName; // Ex: "witcher3.exe"
  final String fullPath; // Ex: "C:\Games\The Witcher 3\bin\x64\witcher3.exe"
  final List<String>
  pathSegments; // Ex: ["Games", "The Witcher 3", "bin", "x64"]

  // Ces champs seront remplis après l'action de l'utilisateur
  String? selectedSearchTerm; // Le terme choisi dans la liste ou tapé à la main
  List<IgdbSearchResult> igdbProposals; // Les résultats renvoyés par l'API

  DiscoveryResult({
    required this.rawName,
    required this.fullPath,
    required this.pathSegments,
    this.selectedSearchTerm,
    this.igdbProposals = const [],
  });
}
