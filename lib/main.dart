import 'package:flutter/material.dart';

import 'dynasty/dynasty_shell.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/reading_screen.dart';
import 'screens/word_list_screen.dart';
import 'game/achievements.dart';
import 'game/player.dart';
import 'store.dart';
import 'theme.dart';

export 'dynasty/dynasty_shell.dart';

late AppStore store;

/// Para mostrar avisos (p. ej. logro conseguido) desde cualquier pantalla.
final messengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  store = await AppStore.load();
  store.onMedalUnlocked = showMedalToast;
  runApp(const ZikaApp());
}

void showMedalToast(String id) {
  final medal = achievements.where((m) => m.id == id).firstOrNull;
  if (medal == null) return;
  messengerKey.currentState?.showSnackBar(SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.surface,
    duration: const Duration(seconds: 4),
    content: Row(children: [
      CircleAvatar(backgroundColor: medal.color, child: Icon(medal.icon, color: AppColors.bg)),
      const SizedBox(width: 12),
      Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('¡Logro conseguido!', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800)),
        Text(medal.title, style: const TextStyle(color: AppColors.text, fontSize: 16)),
      ])),
    ]),
  ));
}

class ZikaApp extends StatelessWidget {
  const ZikaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Zìkǎ',
    debugShowCheckedModeBanner: false,
    scaffoldMessengerKey: messengerKey,
    theme: buildTheme(),
    home: ListenableBuilder(
      listenable: store,
      builder: (context, _) => switch (store.player.mode) {
        null => const OnboardingScreen(),
        AppMode.free => const Shell(),
        AppMode.dynasty => const DynastyShell(),
      },
    ),
  );
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _tab,
      children: const [HomeScreen(), WordListScreen(), ReadingScreen()],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (i) => setState(() => _tab = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.style_outlined), selectedIcon: Icon(Icons.style), label: 'Tarjetas'),
        NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Palabras'),
        NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Lectura'),
      ],
    ),
  );
}
