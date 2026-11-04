import 'package:dingdong/main.dart';
import 'package:dingdong/store.dart';
import 'package:dingdong/models.dart';
import 'package:dingdong/theme.dart';
import 'package:dingdong/screens/word_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await AppStore.load();
  });

  testWidgets('ordena por fallos y pinta de rojo en Dinastía', (tester) async {
    final words = store.wordsOf(Deck.all);
    final second = words[1];
    final first = (words.where((w) => w.id != second.id).toList()
          ..sort((a, b) => a.pinyin.compareTo(b.pinyin)))
        .first;
    store.recordAnswer(second.id, false);
    store.recordAnswer(second.id, false);
    store.recordAnswer(second.id, false);

    await tester.pumpWidget(const MaterialApp(home: WordListScreen(dynasty: true)));
    await tester.tap(find.byKey(const ValueKey('word-list-sort')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Más falladas').last);
    await tester.pumpAndSettle();

    final tiles = find.byType(InkWell);
    expect(tiles, findsWidgets);
    expect(find.text(second.hanzi), findsOneWidget);
    expect(find.text(first.hanzi), findsOneWidget);
    expect(tester.getTopLeft(find.text(second.hanzi)).dy,
        lessThan(tester.getTopLeft(find.text(first.hanzi)).dy));

    final marker = tester.widget<Container>(
      find.descendant(of: find.ancestor(of: find.text(second.hanzi), matching: find.byType(InkWell)).first,
          matching: find.byType(Container)).first,
    );
    expect((marker.decoration! as BoxDecoration).color, AppColors.red);
  });
}
