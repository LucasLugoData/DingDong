import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/reading_screen.dart';
import 'screens/word_list_screen.dart';
import 'game/player.dart';
import 'store.dart';
import 'theme.dart';

late AppStore store;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  store = await AppStore.load();
  runApp(const ZikaApp());
}

class ZikaApp extends StatelessWidget {
  const ZikaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Zìkǎ',
    debugShowCheckedModeBanner: false,
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

class DynastyShell extends StatelessWidget {
  const DynastyShell({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Modo Dinastía')),
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
