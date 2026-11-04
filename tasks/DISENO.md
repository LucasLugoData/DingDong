# Diseño común (Modo Dinastía) — leer antes de cada tarea

Contratos compartidos. No cambiar nombres sin actualizar este archivo.

## Datos y migración (OBLIGATORIO)
- La app instalada ya tiene datos. NUNCA renombrar ni borrar las claves de `shared_preferences` existentes:
  `progress`, `notes`, `favorites`, `custom`, `reviewKnown`. `applicationId` sigue siendo `com.ariel.dingdong`.
- Todo lo nuevo va en UNA clave nueva `player` (JSON) con valores por defecto si falta.
- Usuario con datos previos y sin `player`: se le muestra igualmente la elección de modo; sus datos siguen ahí.

## Modos de la app
- `AppMode.free` = app actual (Shell de 3 pestañas), sin cambios salvo los bugs 001-002 y la lectura de 022.
- `AppMode.dynasty` = "Modo Dinastía": todo lo nuevo, exclusivo de este modo.
- `player.mode == null` → pantalla de bienvenida (elige modo + nombre).

## Player (`lib/game/player.dart`, puro, con toJson/fromJson)
name (String), mode (AppMode?), xp (int total acumulado), seen (Set<String> ids vistos en Dinastía),
wordStats (Map<String,(hits,misses)>), medals (Set<String>), featuredMedal (String?),
gamesPlayed (Map<String,int> con claves `cards`, `grammar`, `reading`), bonusMode (String?), lastBonusAt (DateTime?).
x2: modo con menos partidas (empate → sorteo, guardado); se aplica a UNA partida y no vuelve hasta pasadas 2 h.

## API del store (`lib/store.dart`)
`store.player`, `setName`, `setMode`, `recordAnswer(String wordId, bool correct)` (suma hits/misses y añade a seen),
`markSeen(String id)`, `grantXp(String gameMode, int baseXp) -> int` (aplica x2 del modo menos usado, suma
gamesPlayed, guarda, notifica y devuelve la XP final), `resetAccount()` (borra `player` y `progress`; conserva notas,
favoritas y tarjetas propias), `unlockMedal(String id)`, `setFeaturedMedal(String? id)`.

## Lógica pura (`lib/game/`, con tests en `test/`)
`xp.dart`, `mastery.dart` (`enum Mastery {red, orange, blue, green, gold}`, 0 conocimiento → consolidado),
`achievements.dart`, `solitaire.dart`, `passives.dart`, `fusion.dart`, `grammar.dart`, `segment.dart`.

## Colores (`lib/theme.dart`, AppColors)
Existentes: orange, green, gold, accent. Nuevos: `red 0xFFFF4D4D`, `blue 0xFF2E9BFF`, `lilac 0xFFB57BFF`,
`bronze 0xFFCD7F32`, `silver 0xFFC0C8D8`, `paper 0xFFE9DCC0`, `ink 0xFF2A1E14`, `seal 0xFFB3261E`.
Marcador estilo referencia: "+50 Fichas" (número en `blue`), "+10 Mult" (número en `red`, "Mult" en `gold`),
multiplicador del multiplicador como píldora roja "X1.5" + "Mult" dorado. Fondo oscuro actual.

## UI
- Móvil, 375 px de ancho. Widget tests: `tester.view.physicalSize = const Size(1125, 2436); tester.view.devicePixelRatio = 3;`
- En tests: `SharedPreferences.setMockInitialValues({...}); store = await AppStore.load();` (el `store` global de main.dart).
- Barra superior Dinastía (`lib/widgets/top_bar.dart`): nombre a la izquierda, medalla destacada en el centro, nivel +
  barra de XP a la derecha. Visible en todas las pestañas salvo Perfil; partidas y ejercicios se abren con
  `Navigator.push` a pantalla completa y no la muestran.
- Pestañas Dinastía de izquierda a derecha: Tarjetas, Hanziario, Perfil (botón central más grande), Gramática, Lectura.
- Estética de pasivas: papel antiguo (`paper`), tinta (`ink`), sello rojo (`seal`), inspiración dinastía Qing / Chunqiu,
  bocetos de montañas, papiro y muros agrietados con CustomPaint (sin imágenes ni dependencias nuevas).

## Verificación estándar
`flutter test test/<archivo>_test.dart` y `flutter analyze lib test` sin errores. Sin dependencias nuevas en pubspec.
