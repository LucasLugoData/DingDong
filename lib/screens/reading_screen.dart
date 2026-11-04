import 'package:flutter/material.dart';

import '../data/readings.dart';
import '../theme.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lectura', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Text('Textos cortos graduados. Toca una frase para ver su traducción.',
                  style: TextStyle(color: AppColors.muted)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final r in readings)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                title: Text(r.original, style: hanziStyle(24)),
                subtitle: Text(r.title, style: const TextStyle(color: AppColors.muted)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(r.level,
                      style: const TextStyle(color: AppColors.accentSoft, fontWeight: FontWeight.w700)),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => _ReadingDetail(reading: r)),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _ReadingDetail extends StatefulWidget {
  const _ReadingDetail({required this.reading});
  final Reading reading;

  @override
  State<_ReadingDetail> createState() => _ReadingDetailState();
}

class _ReadingDetailState extends State<_ReadingDetail> {
  bool _pinyin = false;
  bool _translation = false;
  final Set<int> _open = {};

  @override
  Widget build(BuildContext context) {
    final r = widget.reading;
    return Scaffold(
      appBar: AppBar(title: Text(r.title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Text(r.original, textAlign: TextAlign.center, style: hanziStyle(34)),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Pinyin'),
                      selected: _pinyin,
                      onSelected: (v) => setState(() => _pinyin = v),
                    ),
                    FilterChip(
                      label: const Text('Traducción'),
                      selected: _translation,
                      onSelected: (v) => setState(() {
                        _translation = v;
                        _open.clear();
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                for (var i = 0; i < r.sentences.length; i++) _sentence(i, r.sentences[i]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sentence(int i, (String, String, String) s) {
    final showTr = _translation || _open.contains(i);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _open.contains(i) ? _open.remove(i) : _open.add(i)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_pinyin)
              Text(s.$2, style: const TextStyle(color: AppColors.accentSoft, fontSize: 15)),
            Text(s.$1, style: hanziStyle(26).copyWith(height: 1.5)),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: showTr
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(s.$3, style: const TextStyle(color: AppColors.muted, fontSize: 15)),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
