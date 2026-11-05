import 'dart:math';

import 'package:flutter/material.dart';

import '../main.dart';
import '../models.dart';
import '../theme.dart';
import 'note_editor.dart';

/// Tarjeta que gira: delante solo los caracteres; detrás pinyin arriba,
/// traducción en el centro y notas abajo.
class FlashCard extends StatefulWidget {
  const FlashCard({super.key, required this.word, required this.flipped, required this.onFlip});

  final Word word;
  final bool flipped;
  final VoidCallback onFlip;

  @override
  State<FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<FlashCard> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
    value: widget.flipped ? 1 : 0,
  );

  @override
  void didUpdateWidget(FlashCard old) {
    super.didUpdateWidget(old);
    if (old.word.id != widget.word.id) {
      _ctrl.value = widget.flipped ? 1 : 0;
    } else if (old.flipped != widget.flipped) {
      widget.flipped ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onFlip,
    child: AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = Curves.easeInOutCubic.transform(_ctrl.value);
        final showBack = t >= .5;
        final angle = t * pi;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(showBack ? pi : 0),
            child: _Face(
              color: showBack ? AppColors.cardBack : AppColors.card,
              word: widget.word,
              child: showBack ? _Back(word: widget.word) : _Front(word: widget.word),
            ),
          ),
        );
      },
    ),
  );
}

class _Face extends StatelessWidget {
  const _Face({required this.color, required this.word, required this.child});
  final Color color;
  final Word word;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: const Color(0xFF8A6A3E), width: 1.2),
      boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 8))],
    ),
    child: Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: PapyrusPainter(color: color))),
        Positioned.fill(child: DefaultTextStyle.merge(
          style: const TextStyle(color: AppColors.ink),
          child: IconTheme.merge(data: const IconThemeData(color: AppColors.ink), child: child),
        )),
        Positioned(top: 8, right: 8, child: _FavButton(word: word)),
      ],
    ),
  );
}

class _FavButton extends StatelessWidget {
  const _FavButton({required this.word});
  final Word word;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final fav = store.isFavorite(word.id);
      return IconButton(
        tooltip: fav ? 'Quitar de favoritas' : 'Añadir a favoritas',
        onPressed: () => store.toggleFavorite(word.id),
        icon: Icon(fav ? Icons.star_rounded : Icons.star_outline_rounded,
            color: fav ? AppColors.seal : AppColors.inkMuted.withValues(alpha: .6), size: 26),
      );
    },
  );
}

class _Front extends StatelessWidget {
  const _Front({required this.word});
  final Word word;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      // Lo más grande posible sin partir la palabra en dos líneas.
      final size = min(c.maxHeight * .42, 150.0);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(word.hanzi, maxLines: 1, softWrap: false, style: hanziStyle(size).copyWith(color: AppColors.ink)),
          ),
        ),
      );
    },
  );
}

class _Back extends StatelessWidget {
  const _Back({required this.word});
  final Word word;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final note = store.noteOf(word.id);
      return LayoutBuilder(
        builder: (context, c) => Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
          child: Column(
            children: [
              Text(
                word.pinyin,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  color: AppColors.seal,
                  fontWeight: FontWeight.w500,
                  letterSpacing: .5,
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Text(
                      word.meaning,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 26, height: 1.35, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
              if (note.isEmpty)
                TextButton.icon(
                  onPressed: () => showNoteEditor(context, word),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.inkMuted,
                    shape: const StadiumBorder(),
                    side: BorderSide(color: AppColors.inkMuted.withValues(alpha: .4)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nota'),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: c.maxHeight * .45),
                  child: _NoteBox(word: word, note: note),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _NoteBox extends StatelessWidget {
  const _NoteBox({required this.word, required this.note});
  final Word word;
  final String note;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.ink.withValues(alpha: .08),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => showNoteEditor(context, word),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Text(note, style: const TextStyle(fontSize: 15, height: 1.5)),
          ),
        ),
      ),
    ),
  );
}
