# ai/ — Reglas de IA compartidas

Mismas reglas de trabajo para todos los asistentes, portadas de `~/.claude/CLAUDE.md`
(sin lo específico de Claude). Fuente canónica: `RULES.md`.

Se versionan en el repo, así que viajan a cualquier máquina por el mismo sync de dotfiles.

## Gemini

- **Gemini CLI (global):** `install.py` symlinkea `RULES.md` → `~/.gemini/GEMINI.md`.
  Queda activo en todos tus proyectos sin hacer nada más.
- **Por proyecto:** copiá `RULES.md` como `GEMINI.md` en la raíz del repo.
- **Code Assist (code review):** copiá `RULES.md` como `.gemini/styleguide.md` en el repo.

## GitHub Copilot

Por repo (no hay global limpio). En cada proyecto:

```bash
mkdir -p .github && cp ~/.dotfiles/ai/RULES.md .github/copilot-instructions.md
```

## Cursor

- **Por proyecto (recomendado):**

  ```bash
  mkdir -p .cursor/rules && cp ~/.dotfiles/ai/cursor-workflow.mdc .cursor/rules/workflow.mdc
  ```

  El `.mdc` ya trae el frontmatter (`alwaysApply: true`). El viejo `.cursorrules` no
  se usa: Cursor lo ignora en Agent mode.
- **Global (una vez por máquina):** pegá el contenido de `RULES.md` en
  Cursor → Settings → Rules (User Rules).

## Mantener en sync

`RULES.md` es la fuente. Si la editás, actualizá también `cursor-workflow.mdc`
(mismo cuerpo + frontmatter) y re-copiá donde la hayas dejado por proyecto.
