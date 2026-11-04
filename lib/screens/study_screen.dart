import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../models.dart';
import '../session.dart';
import '../theme.dart';
import '../widgets/flash_card.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key, required this.deckId});
  final String deckId;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> with TickerProviderStateMixin {
  final _focus = FocusNode();
  late final _fly = AnimationController(vsync: this);
  late final _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    value: 1,
  );
  bool _busy = false;
  double _cardWidth = 360;
  late final Deck _deck = Deck.byId(widget.deckId);
  late StudySession _session;
  bool _tracking = true;
  bool _shuffled = false;
  bool _flipped = false;
  bool _fullscreen = false;
  double _drag = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _focus.dispose();
    _fly.dispose();
    _enter.dispose();
    if (_fullscreen) SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _start() {
    final words = store.wordsOf(_deck.id);
    _session = StudySession(
      words: _tracking ? words.where(store.isDue).toList() : words,
      tracking: _tracking,
      shuffled: _shuffled,
    );
    _flipped = false;
  }

  void _restart() => setState(_start);

  void _flip() => setState(() => _flipped = !_flipped);

  /// Anima el desplazamiento horizontal de la tarjeta hasta [to].
  Future<void> _slideTo(double to, Curve curve, int ms) async {
    final from = _drag;
    final anim = CurvedAnimation(parent: _fly, curve: curve);
    void tick() => setState(() => _drag = from + (to - from) * anim.value);
    _fly.duration = Duration(milliseconds: ms);
    _fly.addListener(tick);
    await _fly.forward(from: 0);
    _fly.removeListener(tick);
    anim.dispose();
  }

  /// La tarjeta sale volando hacia un lado y entra la siguiente.
  Future<void> _advance(double direction, VoidCallback change) async {
    if (_busy) return;
    _busy = true;
    await _slideTo(direction * (_cardWidth + 120), Curves.easeInCubic, 240);
    if (!mounted) return;
    setState(() {
      change();
      _flipped = false;
      _drag = 0;
    });
    _enter.forward(from: 0);
    _busy = false;
  }

  void _answer(bool correct) {
    final w = _session.current;
    if (w == null) return;
    _advance(correct ? 1 : -1, () {
      store.answer(w, correct);
      _session.answer(correct);
    });
  }

  void _move(int delta) {
    final can = delta > 0
        ? _session.index < _session.queue.length - 1
        : _session.index > 0;
    if (!can) {
      _slideTo(0, Curves.easeOutBack, 280);
      return;
    }
    _advance(delta > 0 ? -1 : 1, () => delta > 0 ? _session.next() : _session.previous());
  }

  void _toggleShuffle() => setState(() {
    _shuffled = !_shuffled;
    _session.toggleShuffle();
  });

  void _toggleFullscreen() {
    setState(() => _fullscreen = !_fullscreen);
    SystemChrome.setEnabledSystemUIMode(
      _fullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent || _session.isDone) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.space || k == LogicalKeyboardKey.arrowUp || k == LogicalKeyboardKey.arrowDown) {
      _flip();
    } else if (k == LogicalKeyboardKey.arrowLeft || k == LogicalKeyboardKey.digit1) {
      _tracking ? _answer(false) : _move(-1);
    } else if (k == LogicalKeyboardKey.arrowRight || k == LogicalKeyboardKey.digit2) {
      _tracking ? _answer(true) : _move(1);
    } else if (k == LogicalKeyboardKey.keyF) {
      _toggleFullscreen();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _onDragEnd(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    final swipe = _drag.abs() > 80 || v.abs() > 600;
    final right = (_drag + v / 10) > 0;
    if (!swipe) {
      _slideTo(0, Curves.easeOutBack, 320);
      return;
    }
    if (_tracking) {
      _answer(right);
    } else {
      _move(right ? -1 : 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final desktop = defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        appBar: _fullscreen
            ? null
            : AppBar(
                title: Text(_deck.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                actions: [
                  IconButton(
                    tooltip: 'Ajustes',
                    icon: const Icon(Icons.tune),
                    onPressed: _openSettings,
                  ),
                ],
              ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, _fullscreen ? 12 : 4, 16, 12),
            child: Column(
              children: [
                if (!_fullscreen) _topRow(),
                const SizedBox(height: 12),
                Expanded(child: _session.isDone ? _doneView() : _cardArea()),
                if (!_session.isDone && !_fullscreen && (desktop || _session.index == 0)) _hint(desktop),
                const SizedBox(height: 12),
                _bottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topRow() {
    final pos = _session.isDone ? _session.total : _session.position;
    final counter = Text('$pos / ${_session.total}',
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.muted, fontSize: 13));
    final total = _session.total;
    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: total == 0 ? 0 : (pos - (_session.isDone ? 0 : 1)) / total),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        builder: (context, v, _) => LinearProgressIndicator(
          value: v,
          minHeight: 3,
          backgroundColor: AppColors.surface,
          color: AppColors.accent,
        ),
      ),
    );
    return Column(
      children: [
        Row(
          children: [
            if (_tracking)
              _Pill(value: _session.learningCount, label: 'En progreso', color: AppColors.orange, leading: true),
            const Spacer(),
            counter,
            const Spacer(),
            if (_tracking)
              _Pill(value: _session.knownCount, label: 'Conocida', color: AppColors.green, leading: false),
          ],
        ),
        const SizedBox(height: 10),
        bar,
      ],
    );
  }

  Widget _cardArea() {
    final word = _session.current!;
    final progress = (_drag.abs() / (_cardWidth * .6)).clamp(0.0, 1.0);
    final accent = _drag > 0 ? AppColors.green : AppColors.orange;
    return LayoutBuilder(
      builder: (context, c) {
        _cardWidth = c.maxWidth;
        return GestureDetector(
          onHorizontalDragUpdate: (d) {
            if (!_busy) setState(() => _drag += d.delta.dx);
          },
          onHorizontalDragEnd: _onDragEnd,
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _enter, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: Tween(begin: .92, end: 1.0)
                  .animate(CurvedAnimation(parent: _enter, curve: Curves.easeOutBack)),
              child: Opacity(
                opacity: 1 - progress * .35,
                child: Transform.translate(
                  offset: Offset(_drag, _drag.abs() * .04),
                  child: Transform.rotate(
                    angle: _drag / 1800,
                    child: Stack(
                      children: [
                        FlashCard(word: word, flipped: _flipped, onFlip: _flip),
                        if (_tracking && _drag != 0)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: accent.withValues(alpha: progress * .8),
                                    width: 2,
                                  ),
                                ),
                                child: Align(
                                  alignment: _drag > 0 ? Alignment.topLeft : Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Icon(
                                      _drag > 0 ? Icons.check_rounded : Icons.close_rounded,
                                      color: accent.withValues(alpha: progress),
                                      size: 36,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _hint(bool desktop) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Text(
      !desktop
          ? (_tracking
              ? 'Toca para girar · desliza → la sé · ← no la sé'
              : 'Toca para girar · desliza para pasar')
          : _tracking
          ? 'Espacio: girar · ←: no la sé · →: la sé · F: pantalla completa'
          : 'Espacio: girar · ← →: anterior / siguiente · F: pantalla completa',
      style: TextStyle(color: AppColors.muted.withValues(alpha: .7), fontSize: 12),
    ),
  );

  Widget _bottomBar() {
    final done = _session.isDone;
    final center = _tracking
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RoundButton(
                icon: Icons.close_rounded,
                color: AppColors.orange,
                tooltip: 'No la sé',
                onTap: done ? null : () => _answer(false),
              ),
              const SizedBox(width: 40),
              _RoundButton(
                icon: Icons.check_rounded,
                color: AppColors.green,
                tooltip: 'La sé',
                onTap: done ? null : () => _answer(true),
              ),
            ],
          )
        : SizedBox(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Anterior',
                  onPressed: _session.index > 0 ? () => _move(-1) : null,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text('${_session.position} / ${_session.total}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  tooltip: 'Siguiente',
                  onPressed: _session.index < _session.queue.length - 1 ? () => _move(1) : null,
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ],
            ),
          );
    return LayoutBuilder(
      builder: (context, c) {
        final narrow = c.maxWidth < 520;
        final trackSwitch = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Seguir progreso',
                style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(width: 6),
            Tooltip(
              message: 'Seguir progreso (repetición espaciada)',
              child: Switch(
                value: _tracking,
                onChanged: (v) {
                  _tracking = v;
                  _restart();
                },
              ),
            ),
          ],
        );
        final tools = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: _shuffled ? 'Aleatorio (pulsa para orden por pinyin)' : 'Orden por pinyin (pulsa para aleatorio)',
              onPressed: _toggleShuffle,
              style: IconButton.styleFrom(
                backgroundColor: _shuffled ? AppColors.accent.withValues(alpha: .25) : Colors.transparent,
                foregroundColor: _shuffled ? AppColors.accentSoft : AppColors.muted,
              ),
              icon: Icon(_shuffled ? Icons.shuffle_rounded : Icons.sort_by_alpha_rounded),
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: _fullscreen ? 'Salir de pantalla completa' : 'Pantalla completa',
              onPressed: _toggleFullscreen,
              color: AppColors.muted,
              icon: Icon(_fullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded),
            ),
          ],
        );
        if (narrow) {
          return Column(
            children: [
              center,
              const SizedBox(height: 12),
              Row(children: [trackSwitch, const Spacer(), tools]),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: Align(alignment: Alignment.centerLeft, child: trackSwitch)),
            center,
            Expanded(child: Align(alignment: Alignment.centerRight, child: tools)),
          ],
        );
      },
    );
  }

  Widget _doneView() {
    final stats = store.statsOf(_deck.id);
    final nothingDue = _session.queue.isEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(nothingDue ? '🎉' : '🏁', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              nothingDue ? '¡Nada pendiente en este mazo!' : '¡Vuelta completada!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              store.reviewKnown
                  ? 'Las conocidas volverán a salir más adelante, cada vez más espaciadas.'
                  : 'Las conocidas no volverán a salir hasta que reinicies el progreso.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _Pill(value: stats.known, label: 'Conocidas', color: AppColors.green, leading: true),
                _Pill(value: stats.learning, label: 'En progreso', color: AppColors.orange, leading: true),
                _Pill(value: stats.fresh, label: 'Sin ver', color: AppColors.muted, leading: true),
              ],
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                if (stats.due > 0)
                  FilledButton.icon(
                    onPressed: _restart,
                    icon: const Icon(Icons.replay),
                    label: Text('Seguir (${stats.due} pendientes)'),
                  ),
                OutlinedButton.icon(
                  onPressed: () {
                    _tracking = false;
                    _restart();
                  },
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Repasar todo libremente'),
                ),
                OutlinedButton.icon(
                  onPressed: _confirmReset,
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.orange),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reiniciar progreso (nueva vuelta)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Reiniciar progreso?'),
        content: Text(
          'Todas las tarjetas de "${_deck.title}" volverán a estar sin ver. '
          'Tus notas y favoritas se conservan.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reiniciar')),
        ],
      ),
    );
    if (ok == true) {
      store.resetProgress(_deck.id);
      _tracking = true;
      _restart();
    }
  }

  void _openSettings() => showModalBottomSheet(
    context: context,
    builder: (context) => ListenableBuilder(
      listenable: store,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Las conocidas vuelven a salir'),
              subtitle: const Text(
                'Activado: reaparecen cada vez más espaciadas (1, 3, 7, 15… días).\n'
                'Desactivado: no vuelven hasta que reinicies el progreso.',
              ),
              value: store.reviewKnown,
              onChanged: (v) {
                store.setReviewKnown(v);
                _restart();
              },
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt, color: AppColors.orange),
              title: Text('Reiniciar progreso de ${_deck.title}'),
              subtitle: const Text('Empieza una nueva vuelta al temario'),
              onTap: () {
                Navigator.pop(context);
                _confirmReset();
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.value, required this.label, required this.color, required this.leading});
  final int value;
  final String label;
  final Color color;
  final bool leading;

  @override
  Widget build(BuildContext context) {
    final children = [
      Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text('$value', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15)),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: leading ? children : children.reversed.toList(),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.color, required this.tooltip, this.onTap});
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: color.withValues(alpha: .08),
      shape: CircleBorder(side: BorderSide(color: color.withValues(alpha: .35), width: 1.5)),
      child: InkWell(
        customBorder: const CircleBorder(),
        splashColor: color.withValues(alpha: .25),
        onTap: onTap,
        child: SizedBox(width: 64, height: 64, child: Icon(icon, color: color, size: 30)),
      ),
    ),
  );
}
