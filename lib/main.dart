import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/reading_screen.dart';
import 'screens/word_list_screen.dart';
import 'store.dart';
import 'theme.dart';

late final AppStore store;

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
    home: const Shell(),
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
