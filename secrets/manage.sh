#!/usr/bin/env bash
# ============================================================
# secrets/manage.sh — gestión de secrets con sops + age
# ------------------------------------------------------------
# El [archivo] es opcional; default = vars.sops.env (tu secret personal).
# Pasá otro (p.ej. work.sops.env) para manejar un set aparte con la
# clave age de ESTA máquina — útil en la oficina sin mezclar con lo
# personal. work.sops.env queda gitignored (no va a tu repo personal).
#
# Comandos:
#   init-key              Genera la clave age (si no existe) e inyecta la
#                         clave PÚBLICA en secrets/.sops.yaml si está vacío.
#   migrate [src] [dest]  Cifra un dotenv plano (src default ~/.env) hacia
#                         dest (default vars.sops.env), con la clave local.
#   edit  [archivo]       Abre el cifrado en $EDITOR (sops descifra/recifra).
#   show  [archivo]       Imprime el contenido descifrado (stdout).
#   rekey [archivo]       Re-cifra para los destinatarios de .sops.yaml.
# ============================================================
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
SECRETS_DIR="$DOTFILES/secrets"
SOPS_YAML="$SECRETS_DIR/.sops.yaml"
DEFAULT_ENC="vars.sops.env"
KEYFILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"
# En macOS sops busca la clave en ~/Library/Application Support/sops/age por
# defecto; la nuestra vive en ~/.config. Exportar la ruta hace que edit/show/
# rekey la encuentren (igual que el loader del shell).
export SOPS_AGE_KEY_FILE="$KEYFILE"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Falta '$1'. Instalá con: brew install sops age" >&2; exit 1;
  }
}

# Resuelve el archivo destino: vacío -> default; relativo -> dentro de secrets/.
resolve_enc() {
  local a="${1:-$DEFAULT_ENC}"
  case "$a" in
    /*) echo "$a" ;;
    *)  echo "$SECRETS_DIR/$a" ;;
  esac
}

pubkey_from_keyfile() {
  # age-keygen escribe '# public key: age1...' en el keyfile
  grep -oE 'age1[0-9a-z]+' "$KEYFILE" | head -1
}

cmd_init_key() {
  need age
  mkdir -p "$(dirname "$KEYFILE")"
  if [[ -f "$KEYFILE" ]]; then
    echo "Ya existe la clave: $KEYFILE (no la sobreescribo)"
  else
    age-keygen -o "$KEYFILE" >/dev/null 2>&1
    chmod 600 "$KEYFILE"
    echo "Clave age creada: $KEYFILE (chmod 600)"
  fi
  local pub; pub="$(pubkey_from_keyfile)"
  [[ -n "$pub" ]] || { echo "No pude leer la clave pública de $KEYFILE" >&2; exit 1; }
  echo "Clave pública: $pub"
  if grep -q 'REPLACE_WITH_YOUR_AGE_PUBLIC_KEY' "$SOPS_YAML"; then
    # sed portable (BSD/macOS y GNU)
    sed -i.bak "s|REPLACE_WITH_YOUR_AGE_PUBLIC_KEY|$pub|" "$SOPS_YAML" && rm -f "$SOPS_YAML.bak"
    echo "Inyectada en $SOPS_YAML"
  else
    echo "Nota: .sops.yaml ya tenía una clave (no lo toqué)."
  fi
  echo
  echo "IMPORTANTE: respaldá $KEYFILE en un lugar seguro (1Password, USB cifrado)."
  echo "Sin esa clave privada NO podés descifrar tus secrets en otra máquina."
}

cmd_migrate() {
  need sops; need age
  local src="${1:-$HOME/.env}"
  local enc; enc="$(resolve_enc "${2:-}")"
  [[ -f "$src" ]] || { echo "No existe el archivo origen: $src" >&2; exit 1; }
  [[ -f "$enc" ]] && { echo "$enc ya existe. Usá 'edit' para modificarlo." >&2; exit 1; }
  local pub; pub="$(pubkey_from_keyfile)"
  [[ -n "$pub" ]] || { echo "Primero corré: $0 init-key" >&2; exit 1; }
  # Cifrado directo origen->destino con la clave LOCAL (--age, no .sops.yaml):
  # la salida ya es ciphertext, nunca queda texto plano dentro del repo.
  sops --encrypt --age "$pub" --input-type dotenv --output-type dotenv "$src" > "$enc"
  echo "Cifrado: $src -> $enc"
  echo "Verificá con:  $0 show $(basename "$enc")"
  echo "Cuando confirmes, borrá el plano:  rm $src"
}

cmd_edit()  { need sops; local enc; enc="$(resolve_enc "${1:-}")"; [[ -f "$enc" ]] || { echo "No existe $enc (corré 'migrate')." >&2; exit 1; }; sops "$enc"; }
cmd_show()  { need sops; local enc; enc="$(resolve_enc "${1:-}")"; [[ -f "$enc" ]] || { echo "No existe $enc." >&2; exit 1; }; sops -d "$enc"; }
cmd_rekey() { need sops; local enc; enc="$(resolve_enc "${1:-}")"; [[ -f "$enc" ]] || { echo "No existe $enc." >&2; exit 1; }; sops updatekeys "$enc"; }

case "${1:-}" in
  init-key) cmd_init_key ;;
  migrate)  shift || true; cmd_migrate "$@" ;;
  edit)     shift || true; cmd_edit "$@" ;;
  show)     shift || true; cmd_show "$@" ;;
  rekey)    shift || true; cmd_rekey "$@" ;;
  *) echo "uso: $0 {init-key | migrate [src] [dest] | edit [archivo] | show [archivo] | rekey [archivo]}"; exit 1 ;;
esac
