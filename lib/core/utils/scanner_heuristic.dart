import 'dart:math';

class ScannerHeuristics {
  static double calculateScore({
    required String fileName,
    required String folderName,
    required int fileSizeInBytes,
  }) {
    // Nettoyage : on enlève l'extension et on passe en minuscule
    final name = fileName.toLowerCase().replaceAll('.exe', '').trim();
    final folder = folderName.toLowerCase().trim();

    // 1. Similarité textuelle (Levenshtein)
    double score = _similarityScore(name, folder);

    // 2. Bonus "Launcher" ou nom exact du dossier
    if (name == 'launcher' || name == 'start' || name == folder) {
      score += 0.5;
    } else if (name.contains('launcher') || name.contains('game')) {
      score += 0.2;
    }

    // 3. Bonus Poids (un programme principal fait rarement moins de 2Mo)
    final sizeInMb = fileSizeInBytes / (1024 * 1024);
    if (sizeInMb > 2.0) score += 0.2;
    if (sizeInMb > 20.0) score += 0.1;

    // 4. Pénalités pour le bruit (Utilitaires système et dossiers techniques)
    final noise = [
      'crash',
      'handler',
      'helper',
      'setup',
      'install',
      'unins',
      'patch',
      'elevator',
      'notifier',
      'update',
      'tool',
      'config',
      'fsnotifier',
      'redist',
      'unitycrash',
    ];

    if (noise.any((pattern) => name.contains(pattern))) {
      score -= 0.8;
    }

    return score;
  }

  static double _similarityScore(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    int distance = _levenshtein(s1, s2);
    int maxLength = max(s1.length, s2.length);
    return 1.0 - (distance / maxLength);
  }

  static int _levenshtein(String s, String t) {
    List<int> v0 = List<int>.generate(t.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      v0.setRange(0, v0.length, v1);
    }
    return v0[t.length];
  }
}
