import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/reading_screen.dart';
import '../screens/word_list_screen.dart';
import '../theme.dart';
import '../widgets/top_bar.dart';

class DynastyShell extends StatefulWidget {
  const DynastyShell({super.key});

  @override
  State<DynastyShell> createState() => _DynastyShellState();
}

class _DynastyShellState extends State<DynastyShell> {
  int _tab = 0;

  static const _destinations = [
    (label: 'Tarjetas', icon: Icons.style_outlined),
    (label: 'Hanziario', icon: Icons.list_alt_outlined),
    (label: 'Perfil', icon: Icons.person_outline),
    (label: 'Gramática', icon: Icons.translate),
    (label: 'Lectura', icon: Icons.menu_book_outlined),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _tab == 2 ? null : const TopBar(),
    body: IndexedStack(
      index: _tab,
      children: const [
        HomeScreen(),
        WordListScreen(),
        SafeArea(child: Center(child: Text('Perfil'))),
        SafeArea(child: Center(child: Text('Gramática'))),
        ReadingScreen(),
      ],
    ),
    bottomNavigationBar: Material(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < _destinations.length; i++)
                Expanded(child: _destination(i)),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _destination(int index) {
    final destination = _destinations[index];
    final selected = _tab == index;
    final color = selected ? AppColors.accentSoft : AppColors.muted;
    final size = index == 2 ? 52.0 : 40.0;
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey('dynasty-tab-$index'),
        onTap: () => setState(() => _tab = index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected || index == 2
                    ? AppColors.accent.withValues(alpha: .25)
                    : Colors.transparent,
              ),
              child: Icon(destination.icon, color: color, size: index == 2 ? 30 : 24),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  destination.label,
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
