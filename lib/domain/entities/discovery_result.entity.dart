import 'package:game_launcher/domain/entities/search_result.entity.dart';

class DiscoveryResult {
  final String rawName;
  final String fullPath;
  final List<String> pathSegments;
  final String? selectedSearchTerm;
  final List<IgdbSearchResult> igdbProposals; // List non-nullable par défaut
  final IgdbSearchResult? igdbMatch; // Le choix final
  final int fileSize;

  DiscoveryResult({
    required this.rawName,
    required this.fullPath,
    required this.pathSegments,
    this.selectedSearchTerm,
    this.igdbProposals = const [],
    this.igdbMatch,
    required this.fileSize,
  });

  DiscoveryResult copyWith({
    String? rawName,
    String? fullPath,
    List<String>? pathSegments,
    String? selectedSearchTerm,
    List<IgdbSearchResult>? igdbProposals,
    IgdbSearchResult? Function()? igdbMatch, // Pattern pour null
    int? fileSize,
  }) {
    return DiscoveryResult(
      rawName: rawName ?? this.rawName,
      fullPath: fullPath ?? this.fullPath,
      pathSegments: pathSegments ?? this.pathSegments,
      selectedSearchTerm: selectedSearchTerm ?? this.selectedSearchTerm,
      igdbProposals: igdbProposals ?? this.igdbProposals,
      igdbMatch: igdbMatch != null ? igdbMatch() : this.igdbMatch,
      fileSize: fileSize ?? this.fileSize,
    );
  }
}
