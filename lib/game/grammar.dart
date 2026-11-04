import 'dart:math';

import '../data/grammar_roles.dart';
import 'mastery.dart';

const auxiliaryTokens = ['我', '你', '他', '是', '的', '在', '很', '不', '吗', '了'];

const _special = {
  '了', '会', '比', '很', '又', '又…又', '没有', '没（有）', '不',
  '那', '那个', '那些', '那儿', '那里', '哪', '哪个', '哪些', '哪儿', '哪里',
};
const _numbers = {'零', '一', '二', '两', '三', '四', '五', '六', '七', '八', '九', '十', '百', '千'};
const _pronouns = {'我', '你', '他', '她', '它', '我们', '你们', '他们'};

bool _has(String word, Role role, Map<String, Set<Role>> roles) {
  if (_pronouns.contains(word)) {
    return role == Role.subject || role == Role.object;
  }
  if (word == '是') return role == Role.verb;
  if (_numbers.contains(word)) return role == Role.number;
  if (_special.contains(word) || auxiliaryTokens.contains(word)) return false;
  return roles[word]?.contains(role) ?? false;
}

bool _rare(String word, Map<String, Set<Role>> roles) =>
    _special.contains(word) ||
    _numbers.contains(word) ||
    (roles[word]?.any({Role.measure, Role.number, Role.aspect,
      Role.comparison, Role.negation, Role.demonstrative, Role.youYou}.contains) ?? false);

/// Solo usa palabras vistas y distintas. Sin dos candidatas o sin verbo no hay tirada.
List<String> drawBalls(
  Iterable<String> seenWords,
  Map<String, Set<Role>> roles,
  Random random, {
  int extra = 0,
  bool harder = false,
  bool rarer = false,
}) {
  final pool = seenWords.toSet().where((w) =>
      (roles[w]?.isNotEmpty ?? false) || _special.contains(w) ||
      _pronouns.contains(w) || w == '是').toList();
  final verbs = pool.where((w) => _has(w, Role.verb, roles)).toList();
  if (pool.length < 2 || verbs.isEmpty) {
    throw ArgumentError('Se necesitan dos palabras vistas y al menos un verbo');
  }
  final count = min(pool.length,
      (2 + random.nextInt(4) + extra + (harder ? 1 : 0)).clamp(2, 5));
  final result = [verbs[random.nextInt(verbs.length)]];
  pool.remove(result.single);
  while (result.length < count) {
    final rare = pool.where((w) => _rare(w, roles)).toList();
    final common = pool.where((w) => !_rare(w, roles)).toList();
    final preferRare = random.nextDouble() < (rarer ? 0.4 : 0.2);
    final candidates = preferRare
        ? (rare.isEmpty ? common : rare)
        : (common.isEmpty ? rare : common);
    final word = candidates[random.nextInt(candidates.length)];
    result.add(word);
    pool.remove(word);
  }
  return result..shuffle(random);
}

typedef _Test = bool Function(String);

class _Edge {
  _Edge(this.to, [this.test]);
  final int to;
  final _Test? test;
}

class _Rule {
  _Rule(this.start, this.end);
  final int start;
  final int end;
}

/// Autómata de las reglas de orden; conserva la mejor lectura de roles ambiguos.
class _Grammar {
  final edges = <List<_Edge>>[];

  int node() {
    edges.add([]);
    return edges.length - 1;
  }

  _Rule token(_Test test) {
    final start = node(), end = node();
    edges[start].add(_Edge(end, test));
    return _Rule(start, end);
  }

  _Rule sequence(List<_Rule> rules) {
    for (var i = 1; i < rules.length; i++) {
      edges[rules[i - 1].end].add(_Edge(rules[i].start));
    }
    return _Rule(rules.first.start, rules.last.end);
  }

  _Rule choice(List<_Rule> rules) {
    final start = node(), end = node();
    for (final rule in rules) {
      edges[start].add(_Edge(rule.start));
      edges[rule.end].add(_Edge(end));
    }
    return _Rule(start, end);
  }

  _Rule optional(_Rule rule) {
    final start = node(), end = node();
    edges[start].addAll([_Edge(rule.start), _Edge(end)]);
    edges[rule.end].add(_Edge(end));
    return _Rule(start, end);
  }

  void close(Map<int, List<int>> paths) {
    final queue = paths.keys.toList();
    for (var i = 0; i < queue.length; i++) {
      final from = queue[i];
      for (final edge in edges[from]) {
        if (edge.test != null) continue;
        final path = paths[from]!;
        if (!paths.containsKey(edge.to) || paths[edge.to]!.length < path.length) {
          paths[edge.to] = path;
          queue.add(edge.to);
        }
      }
    }
  }
}

List<bool> checkSentence(List<String> tokens, Map<String, Set<Role>> roles) {
  final g = _Grammar();
  _Rule literal(String word) => g.token((w) => w == word);
  _Rule role(Role role) => g.token((w) => _has(w, role, roles));
  _Rule noun() => g.token((w) =>
      _has(w, Role.object, roles) &&
      !_has(w, Role.verb, roles) &&
      !_has(w, Role.time, roles) &&
      !_has(w, Role.manner, roles) &&
      !_has(w, Role.measure, roles));
  _Rule nominal() => g.sequence([
    g.optional(g.choice([
      g.sequence([
        g.choice([noun(), role(Role.adjective)]), literal('的'),
      ]),
      g.sequence([role(Role.number), role(Role.measure)]),
      g.sequence([
        g.token((w) => {'那', '哪', '那个', '哪个', '那些', '哪些'}.contains(w)),
        g.optional(role(Role.measure)),
      ]),
    ])),
    noun(),
  ]);
  _Rule subject() => g.choice([role(Role.subject), nominal()]);
  _Rule prefix() => g.sequence([
    g.optional(role(Role.time)), subject(), g.optional(role(Role.time)),
  ]);
  _Rule beforeVerb() => g.sequence([
    g.optional(g.token((w) => {'不', '没有', '没（有）'}.contains(w) ||
        (roles[w]?.contains(Role.negation) ?? false))),
    g.optional(literal('会')),
    g.optional(g.choice([
      g.sequence([literal('在'), g.choice([
        role(Role.place),
        g.token((w) => {'那儿', '那里', '哪儿', '哪里'}.contains(w)),
      ])]),
      role(Role.manner),
    ])),
  ]);
  _Rule verbPhrase({required bool objectRequired}) => g.sequence([
    beforeVerb(), role(Role.verb),
    if (objectRequired)
      g.sequence([g.optional(literal('了')), nominal(), g.optional(literal('了'))])
    else
      g.choice([
        g.sequence([g.optional(literal('了')), nominal(), g.optional(literal('了'))]),
        g.optional(literal('了')),
      ]),
  ]);
  final sentence = g.sequence([
    g.choice([
      g.sequence([prefix(), verbPhrase(objectRequired: false)]),
      verbPhrase(objectRequired: true),
      g.sequence([
        prefix(),
        g.choice([
          g.sequence([literal('比'), subject(), role(Role.adjective)]),
          g.sequence([literal('很'), role(Role.adjective)]),
          g.sequence([literal('又'), role(Role.adjective), literal('又'), role(Role.adjective)]),
        ]),
      ]),
    ]),
    g.optional(literal('吗')),
  ]);
  var paths = <int, List<int>>{sentence.start: []};
  g.close(paths);
  for (var i = 0; i < tokens.length; i++) {
    final next = Map<int, List<int>>.of(paths);
    for (final entry in paths.entries) {
      for (final edge in g.edges[entry.key]) {
        if (edge.test == null || !edge.test!(tokens[i])) continue;
        final path = [...entry.value, i];
        if (!next.containsKey(edge.to) || next[edge.to]!.length < path.length) {
          next[edge.to] = path;
        }
      }
    }
    g.close(next);
    paths = next;
  }
  final correct = (paths[sentence.end] ?? <int>[]).toSet();
  return List.generate(tokens.length, correct.contains);
}

bool isValidSentence(
  List<String> tokens,
  Iterable<String> balls,
  Map<String, Set<Role>> roles,
) => tokens.isNotEmpty &&
    checkSentence(tokens, roles).every((correct) => correct) &&
    balls.toSet().intersection(tokens.toSet()).length >= 2;

double scoreSentence(
  List<String> tokens,
  Iterable<String> balls,
  Map<String, Set<Role>> roles,
  Map<String, Mastery> mastery, {
  int previousValidSentences = 0,
}) {
  if (previousValidSentences < 0) {
    throw ArgumentError.value(previousValidSentences, 'previousValidSentences');
  }
  if (!isValidSentence(tokens, balls, roles)) return 0;
  final scoring = balls.toSet().intersection(tokens.toSet())
    ..removeAll(auxiliaryTokens);
  final base = scoring.fold(0.0, (sum, word) =>
      sum + 10 * difficultyMult(mastery[word] ?? Mastery.red));
  return base * (1 + 0.25 * previousValidSentences);
}
