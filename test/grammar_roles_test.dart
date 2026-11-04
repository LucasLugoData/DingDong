import 'dart:convert';

import 'package:dingdong/data/grammar_roles.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('asigna un rol a al menos el 90 % de las palabras HSK1', () async {
    final vocabulary = jsonDecode(await rootBundle.loadString('assets/vocab.json'))
        as List<dynamic>;
    final hsk1 = vocabulary
        .cast<Map<String, dynamic>>()
        .where((word) => word['deck'] == 'hsk1')
        .toList();
    final covered = hsk1.where((word) => grammarRoles.containsKey(word['hanzi']));

    expect(covered.length / hsk1.length, greaterThanOrEqualTo(0.9));
  });

  test('incluye los roles gramaticales esenciales', () {
    expect(grammarRoles['我'], contains(Role.subject));
    expect(grammarRoles['今天'], contains(Role.time));
    expect(grammarRoles['吃'], contains(Role.verb));
    expect(grammarRoles['了'], contains(Role.aspect));
    expect(grammarRoles['个'], contains(Role.measure));
    expect(grammarRoles['比'], contains(Role.comparison));
    expect(grammarRoles['没有'], contains(Role.negation));
    expect(grammarRoles['哪儿'], contains(Role.demonstrative));
  });
}
