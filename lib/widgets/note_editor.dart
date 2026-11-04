import 'package:flutter/material.dart';

import '../main.dart';
import '../models.dart';
import '../theme.dart';

/// Hoja inferior para escribir notas largas de una tarjeta.
Future<void> showNoteEditor(BuildContext context, Word word) {
  final ctrl = TextEditingController(text: store.noteOf(word.id));
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(word.hanzi, style: hanziStyle(28)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(word.pinyin,
                    style: const TextStyle(color: AppColors.accentSoft, fontSize: 18)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            autofocus: true,
            minLines: 8,
            maxLines: 16,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText: 'Escribe aquí tu nota: gramática, frases de ejemplo…',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (store.noteOf(word.id).isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    store.setNote(word.id, '');
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Borrar nota'),
                ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  store.setNote(word.id, ctrl.text);
                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
