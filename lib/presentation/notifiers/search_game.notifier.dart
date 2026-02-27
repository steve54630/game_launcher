import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameSearchTermNotifier extends Notifier<String> {
  Timer? _debounce;

  @override
  String build() {
    // On enregistre le nettoyage du timer quand le provider est détruit
    ref.onDispose(() => _debounce?.cancel());
    return ""; // État initial
  }

  void updateTerm(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      state = query;
    });
  }
}
