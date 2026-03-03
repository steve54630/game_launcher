import 'package:game_launcher/domain/entities/search_result.entity.dart';

enum DiscoveryStatus { pending, searching, matched, noMatch, error }

class DiscoveryResult {
  final String rawName;
  final String fullPath;
  final int fileSize;
  final List<String> pathSegments;

  final DiscoveryStatus status;
  final String? customSearchTerm;
  final List<IgdbSearchResult> proposals;
  final IgdbSearchResult? selectedMatch;
  final bool isSelected;

  DiscoveryResult({
    required this.rawName,
    required this.fullPath,
    required this.pathSegments,
    required this.fileSize,
    this.status = DiscoveryStatus.pending,
    this.customSearchTerm,
    this.proposals = const [],
    this.selectedMatch,
    this.isSelected = true,
  });

  String get effectiveSearchTerm => customSearchTerm ?? rawName;
  bool get isReady => selectedMatch != null && isSelected;
  bool get needsReview =>
      status == DiscoveryStatus.noMatch || selectedMatch == null;

  DiscoveryResult copyWith({
    DiscoveryStatus? status,
    String? customSearchTerm,
    List<IgdbSearchResult>? proposals,
    IgdbSearchResult? Function()? selectedMatch,
    bool? isSelected,
  }) {
    return DiscoveryResult(
      rawName: rawName,
      fullPath: fullPath,
      pathSegments: pathSegments,
      fileSize: fileSize,
      status: status ?? this.status,
      customSearchTerm: customSearchTerm ?? this.customSearchTerm,
      proposals: proposals ?? this.proposals,
      selectedMatch: selectedMatch != null
          ? selectedMatch()
          : this.selectedMatch,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
