#!/usr/bin/env bash
# ============================================================
# sync-claude-memory.sh — mirror UNA VÍA de la memoria de Claude → vault Obsidian.
# ------------------------------------------------------------
# La memoria de Claude es la fuente de verdad. El vault es un espejo de solo
# lectura: si editás esas notas en Obsidian, se sobrescriben en el próximo sync.
#
# Config por entorno (las setea el launchd plist):
#   CLAUDE_MEMORY_DIR    carpeta memory/ de Claude (origen)
#   CLAUDE_MEMORY_VAULT  carpeta destino dentro del vault
#
# Lo dispara un launchd agent con WatchPaths sobre CLAUDE_MEMORY_DIR (al instante,
# cuando la memoria cambia). También se puede correr a mano.
# ============================================================
set -euo pipefail

MEM="${CLAUDE_MEMORY_DIR:?falta CLAUDE_MEMORY_DIR}"
VAULT="${CLAUDE_MEMORY_VAULT:?falta CLAUDE_MEMORY_VAULT}"

# Defensivo: si el origen no existe (p.ej. cambió el path de la memoria),
# no rompemos nada — salimos limpio.
[ -d "$MEM" ] || { echo "[sync-claude-memory] origen inexistente: $MEM (omito)" >&2; exit 0; }

mkdir -p "$VAULT"

# Solo archivos .md. Espejo: --delete borra del destino lo que ya no está en
# origen, pero --include/--exclude limitan el alcance a .md (no toca otras notas
# que tengas en esa carpeta del vault).
rsync -a --delete --include='*.md' --exclude='*' "$MEM/" "$VAULT/"

echo "[sync-claude-memory] ok $(date '+%Y-%m-%d %H:%M:%S') :: $MEM -> $VAULT"
