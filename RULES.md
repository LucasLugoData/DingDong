# Reglas del proyecto Zìkǎ (字卡)

Reglas comunes a Claude (planificador) y Codex (constructor). Mantener corto: se paga en cada turno.

## Dominio
- App Flutter **para móvil** (Android primero): diseñar y probar a 375 px de ancho.
- Vocabulario en `assets/vocab.json` (HSK1-3 de los PDF Xindongfang; HSK4 de hsk.wordswing.com traducido al español, sin repetir HSK1-3. Todo en español). Orden siempre por pinyin.
- Progreso, notas, favoritas y tarjetas propias en `shared_preferences` (`lib/store.dart`); lógica SRS pura en `lib/srs.dart` y `lib/session.dart` con tests en `test/`.

## Coste
- Solo lo pedido. Otro módulo, dependencia nueva o salirse del plan: para y pregunta.
- Falta una decisión humana: pregunta; no construyas sustitutos por iniciativa propia.
- Sin web, capturas ni subagentes salvo que se pidan en ese mensaje.
- `grep`/`rg` antes de leer; solo los archivos necesarios.
- Tests del módulo afectado; suite completa una vez al final. Salidas recortadas (`| tail -20`).
- Sin documentación extra salvo que la tarea la pida.
