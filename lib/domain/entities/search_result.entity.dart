class IgdbSearchResult {
  final int igdbId;
  final String name;
  final String? coverUrl;
  final String? summary;
  final List<String> screenshotUrls;
  final String? videoId; // ID YouTube pour le trailer

  IgdbSearchResult({
    required this.igdbId,
    required this.name,
    this.coverUrl,
    this.summary,
    this.screenshotUrls = const [],
    this.videoId,
  });
}
