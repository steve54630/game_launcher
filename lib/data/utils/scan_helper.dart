class ExecutableFilter {
  static const _excludedTerms = ['unins', 'crashpad', 'helper', 'setup'];

  static bool isGameExecutable(String path, List<String> segments) {
    final lowerPath = path.toLowerCase();

    // 1. Extension
    if (!lowerPath.endsWith('.exe')) return false;

    // 2. Dossiers cachés (ex: .cache, .git)
    if (segments.any((s) => s.startsWith('.') && s != '.' && s != '..')) {
      return false;
    }

    // 3. Mots-clés interdits
    final fileName = lowerPath.split(r'\').last; // Simplifié pour Windows
    return !_excludedTerms.any((term) => fileName.contains(term));
  }
}
