import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/providers/ui.providers.dart';
import 'package:window_manager/window_manager.dart';

class WindowWatcher extends ConsumerStatefulWidget {
  final Widget child;
  const WindowWatcher({super.key, required this.child});

  @override
  ConsumerState<WindowWatcher> createState() => _WindowWatcherState();
}

class _WindowWatcherState extends ConsumerState<WindowWatcher>
    with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    final settings = ref.read(settingsProvider).value;
    final bool closeOnExit = settings?.closeOnExit ?? false;

    if (closeOnExit) {
      await windowManager.destroy(); // Ferme vraiment l'app
    } else {
      await windowManager.minimize(); // Réduit dans le tray / cache la fenêtre
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
