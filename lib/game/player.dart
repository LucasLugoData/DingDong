/// The two modes available in the app.
enum AppMode { free, dynasty }

/// Dynasty account state, stored as JSON under the `player` preference key.
class Player {
  Player({
    this.name = '',
    this.mode,
    this.xp = 0,
    Set<String>? seen,
    Map<String, ({int hits, int misses})>? wordStats,
    Set<String>? medals,
    this.featuredMedal,
    Map<String, int>? gamesPlayed,
    this.bonusMode,
    this.lastBonusAt,
  }) : seen = seen ?? <String>{},
       wordStats = wordStats ?? <String, ({int hits, int misses})>{},
       medals = medals ?? <String>{},
       gamesPlayed = gamesPlayed ?? <String, int>{};

  String name;
  AppMode? mode;
  int xp;
  final Set<String> seen;
  final Map<String, ({int hits, int misses})> wordStats;
  final Set<String> medals;
  String? featuredMedal;
  final Map<String, int> gamesPlayed;
  String? bonusMode;
  DateTime? lastBonusAt;

  Map<String, dynamic> toJson() => {
    'name': name,
    'mode': mode?.name,
    'xp': xp,
    'seen': seen.toList(),
    'wordStats': wordStats.map((k, v) => MapEntry(k, {'hits': v.hits, 'misses': v.misses})),
    'medals': medals.toList(),
    'featuredMedal': featuredMedal,
    'gamesPlayed': gamesPlayed,
    'bonusMode': bonusMode,
    'lastBonusAt': lastBonusAt?.toIso8601String(),
  };

  factory Player.fromJson(dynamic value) {
    final json = value is Map ? value : const <dynamic, dynamic>{};
    final modeName = json['mode'];
    final mode = AppMode.values.where((e) => e.name == modeName).firstOrNull;
    final stats = <String, ({int hits, int misses})>{};
    if (json['wordStats'] is Map) {
      (json['wordStats'] as Map).forEach((key, value) {
        if (value is Map) {
          stats['$key'] = (
            hits: _int(value['hits']),
            misses: _int(value['misses']),
          );
        }
      });
    }
    final games = <String, int>{};
    if (json['gamesPlayed'] is Map) {
      (json['gamesPlayed'] as Map).forEach((key, value) => games['$key'] = _int(value));
    }
    return Player(
      name: json['name'] is String ? json['name'] as String : '',
      mode: mode,
      xp: _int(json['xp']),
      seen: _strings(json['seen']),
      wordStats: stats,
      medals: _strings(json['medals']),
      featuredMedal: json['featuredMedal'] is String ? json['featuredMedal'] as String : null,
      gamesPlayed: games,
      bonusMode: json['bonusMode'] is String ? json['bonusMode'] as String : null,
      lastBonusAt: DateTime.tryParse(json['lastBonusAt'] is String ? json['lastBonusAt'] as String : ''),
    );
  }

  static int _int(dynamic value) => value is int ? value : 0;
  static Set<String> _strings(dynamic value) => value is List
      ? value.whereType<String>().toSet()
      : <String>{};
}
