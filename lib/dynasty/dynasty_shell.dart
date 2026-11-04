import 'dart:async';

import 'package:flutter/material.dart';

import '../main.dart' as app;
import 'cards_home.dart';
import 'grammar_screen.dart';
import 'profile_screen.dart';
import '../screens/reading_screen.dart';
import '../screens/word_list_screen.dart';
import '../theme.dart';
import '../widgets/top_bar.dart';

class DynastyShell extends StatefulWidget {
  const DynastyShell({super.key, this.shineInterval = const Duration(seconds: 8)});

  final Duration shineInterval;

  @override
  State<DynastyShell> createState() => _DynastyShellState();
}

class _DynastyShellState extends State<DynastyShell>
    with SingleTickerProviderStateMixin {
  int _tab = 0;
  late final AnimationController _shineController;
  late final Animation<double> _shine;
  Timer? _shineTimer;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _shine = Tween<double>(begin: -1, end: 2).animate(_shineController);
    _scheduleShine();
  }

  void _scheduleShine() {
    _shineTimer?.cancel();
    _shineTimer = Timer(widget.shineInterval, () {
      if (!mounted) return;
      _shineController.forward(from: 0).whenComplete(() {
        if (mounted) _scheduleShine();
      });
    });
  }

  @override
  void dispose() {
    _shineTimer?.cancel();
    _shineController.dispose();
    super.dispose();
  }

  static const _destinations = [
    (label: 'Tarjetas', icon: Icons.style_outlined),
    (label: 'Hanziario', icon: Icons.list_alt_outlined),
    (label: 'Perfil', icon: Icons.person_outline),
    (label: 'Gramática', icon: Icons.translate),
    (label: 'Lectura', icon: Icons.menu_book_outlined),
  ];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app.store,
    builder: (context, _) => Scaffold(
    appBar: _tab == 2 ? null : const TopBar(),
    body: IndexedStack(
      index: _tab,
      children: const [
        CardsHome(),
        WordListScreen(dynasty: true),
        ProfileScreen(),
        GrammarScreen(),
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
  ));

  int? get _bonusTabIndex => switch (app.store.bonusMode) {
    'cards' => 0,
    'grammar' => 3,
    'reading' => 4,
    _ => null,
  };

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
            AnimatedBuilder(
              animation: _shine,
              builder: (context, child) => _bonusTabIndex == index
                  ? ShaderMask(
                      blendMode: BlendMode.srcATop,
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment(_shine.value - 1, -1),
                        end: Alignment(_shine.value, 1),
                        colors: const [
                          Colors.transparent,
                          Color(0xB3FFD54F),
                          Colors.transparent,
                        ],
                        stops: const [0.35, 0.5, 0.65],
                      ).createShader(bounds),
                      child: child,
                    )
                  : child!,
              child: Stack(
                clipBehavior: Clip.none,
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
            if (_bonusTabIndex == index)
              Positioned(
                right: -4,
                top: -3,
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Color(0xFFFFD54F), shape: BoxShape.circle),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    child: Text('x2', style: TextStyle(color: Color(0xFF3E2D00), fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
                ],
              ),
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
