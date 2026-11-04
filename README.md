# Plantilla de proyecto: planificador (Claude) → constructor (Codex)

**En prueba**: criterio para mantenerla o no en `brain/decisions.md`. Si se descarta, usa solo `RULES.md` y un `CLAUDE.md` con `@RULES.md`.

Copia estos archivos a la raíz del proyecto y rellena `RULES.md` > Dominio. Añade `CONTEXT.md` desde `brain/projects/_template/`.

1. Claude: "Crea una tarea para X" → `tasks/NNN-x.md`.
2. Claude lanza `integrations/claude-codex/run_tasks.py` de `ai-setup` (en tu PC): recorre las tareas, Codex implementa desde el peldaño más barato, el comando de verificación decide y si falla sube un peldaño. Bucle sin LLM: 0 tokens de Claude. Alternativa manual: Codex, conversación nueva, "Implementa tasks/NNN-x.md".
3. Claude lee solo `INFORME.md` y replanifica lo BLOQUEADO. Ningún LLM lee el diff salvo `Revisión: sí`.

En tu PC, `global\install.ps1` hace que Claude copie esta plantilla solo al empezar un proyecto de código nuevo.

Coste fijo medido: RULES + CLAUDE/AGENTS ≈ 700–800 tokens por conversación (caracteres/4). Aplicado en `triple-barrier-backend`.
