import 'package:flutter/material.dart';

import '../main.dart';
import '../models.dart';
import '../pinyin.dart';
import '../theme.dart';
import '../widgets/note_editor.dart';

/// Lista de palabras con buscador, favoritas y alta de tarjetas propias.
class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  String _deck = Deck.all;
  String _query = '';

  List<Word> _filtered() {
    final words = store.wordsOf(_deck);
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return words;
    final pq = pinyinSearchKey(q);
    return words
        .where((w) =>
            w.hanzi.contains(q) ||
            w.meaning.toLowerCase().contains(q) ||
            (pq.isNotEmpty && w.searchKey.contains(pq)))
        .toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => showWordEditor(context),
      icon: const Icon(Icons.add),
      label: const Text('Nueva tarjeta'),
    ),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final words = _filtered();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar 汉字, pinyin o traducción',
                    fillColor: AppColors.surface,
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (final d in [Deck.byId(Deck.all), ...Deck.list.where((d) => d.id != Deck.all)])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(d.title),
                          selected: _deck == d.id,
                          onSelected: (_) => setState(() => _deck = d.id),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Row(
                  children: [
                    Text('${words.length} palabras · orden por pinyin',
                        style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: words.isEmpty
                    ? const Center(
                        child: Text('No hay palabras aquí todavía',
                            style: TextStyle(color: AppColors.muted)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                        itemCount: words.length,
                        itemExtent: 72,
                        itemBuilder: (context, i) => _WordTile(word: words[i]),
                      ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _WordTile extends StatelessWidget {
  const _WordTile({required this.word});
  final Word word;

  @override
  Widget build(BuildContext context) {
    final p = store.progressOf(word.id);
    final status = p.isKnown ? AppColors.green : p.isLearning ? AppColors.orange : AppColors.line;
    final fav = store.isFavorite(word.id);
    final hasNote = store.noteOf(word.id).isNotEmpty;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _showDetail(context, word),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Container(width: 4, height: 40, decoration: BoxDecoration(color: status, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            SizedBox(
              width: 96,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(word.hanzi, style: hanziStyle(26)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(word.pinyin,
                      style: const TextStyle(color: AppColors.accentSoft, fontWeight: FontWeight.w600)),
                  Text(word.meaning,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted)),
                ],
              ),
            ),
            if (hasNote) const Icon(Icons.sticky_note_2_outlined, size: 18, color: AppColors.muted),
            IconButton(
              onPressed: () => store.toggleFavorite(word.id),
              icon: Icon(fav ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: fav ? AppColors.gold : AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

void _showDetail(BuildContext context, Word word) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final note = store.noteOf(word.id);
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text(word.hanzi, style: hanziStyle(64))),
            Center(
              child: Text(word.pinyin,
                  style: const TextStyle(fontSize: 22, color: AppColors.accentSoft)),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(word.meaning,
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            const Text('Notas', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: SingleChildScrollView(
                child: Text(note.isEmpty ? 'Sin notas' : note,
                    style: TextStyle(color: note.isEmpty ? AppColors.muted : AppColors.text, height: 1.45)),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => showNoteEditor(context, word),
                  icon: const Icon(Icons.edit_note),
                  label: Text(note.isEmpty ? 'Añadir nota' : 'Editar nota'),
                ),
                if (word.isCustom) ...[
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      showWordEditor(context, word: word);
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar tarjeta'),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.orange),
                    onPressed: () {
                      store.deleteCustom(word.id);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Borrar'),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    },
  ),
);

/// Diálogo para crear o editar una tarjeta propia (con nota opcional).
Future<void> showWordEditor(BuildContext context, {Word? word}) {
  final hanzi = TextEditingController(text: word?.hanzi);
  final pinyin = TextEditingController(text: word?.pinyin);
  final meaning = TextEditingController(text: word?.meaning);
  final note = TextEditingController(text: word == null ? '' : store.noteOf(word.id));
  final formKey = GlobalKey<FormState>();
  String? required(String? v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(word == null ? 'Nueva tarjeta' : 'Editar tarjeta',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Se guarda en "Mis tarjetas" y aparece también en "Todo".',
                  style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 16),
              TextFormField(
                controller: hanzi,
                validator: required,
                style: hanziStyle(24),
                decoration: const InputDecoration(labelText: 'Caracteres (汉字)'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: pinyin,
                validator: required,
                decoration: const InputDecoration(labelText: 'Pinyin (ej. běifāng)'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: meaning,
                validator: required,
                decoration: const InputDecoration(labelText: 'Traducción'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: note,
                minLines: 3,
                maxLines: 8,
                decoration: const InputDecoration(labelText: 'Nota (opcional)'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  final saved = store.saveCustom(
                    id: word?.id,
                    hanzi: hanzi.text,
                    pinyin: pinyin.text,
                    meaning: meaning.text,
                  );
                  store.setNote(saved.id, note.text);
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
