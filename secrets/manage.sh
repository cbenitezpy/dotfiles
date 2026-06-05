#!/usr/bin/env bash
# ============================================================
# secrets/manage.sh — gestión de secrets con sops + age
# ------------------------------------------------------------
# Comandos:
#   init-key          Genera la clave age (si no existe) en
#                     ~/.config/sops/age/keys.txt e inyecta la
#                     clave PÚBLICA en secrets/.sops.yaml.
#   migrate [archivo] Cifra un dotenv plano (default ~/.env) hacia
#                     secrets/vars.sops.env. No deja texto plano en el repo.
#   edit              Abre el archivo cifrado en $EDITOR (sops lo
#                     descifra/recifra en memoria).
#   show              Imprime el contenido descifrado (stdout).
#   rekey             Re-cifra para los destinatarios de .sops.yaml.
# ============================================================
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
SECRETS_DIR="$DOTFILES/secrets"
SOPS_YAML="$SECRETS_DIR/.sops.yaml"
ENC="$SECRETS_DIR/vars.sops.env"
KEYFILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Falta '$1'. Instalá con: brew install sops age" >&2; exit 1;
  }
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
  [[ -f "$src" ]] || { echo "No existe el archivo origen: $src" >&2; exit 1; }
  [[ -f "$ENC" ]] && { echo "$ENC ya existe. Usá 'edit' para modificarlo." >&2; exit 1; }
  local pub; pub="$(pubkey_from_keyfile)"
  [[ -n "$pub" ]] || { echo "Primero corré: $0 init-key" >&2; exit 1; }
  # Cifrado directo origen->destino: la salida ya es ciphertext,
  # nunca queda texto plano dentro del repo.
  sops --encrypt --age "$pub" --input-type dotenv --output-type dotenv "$src" > "$ENC"
  echo "Cifrado: $src -> $ENC"
  echo "Verificá con:  $0 show"
  echo "Cuando confirmes, borrá el plano:  rm $src"
}

cmd_edit() { need sops; [[ -f "$ENC" ]] || { echo "No existe $ENC (corré 'migrate')." >&2; exit 1; }; sops "$ENC"; }
cmd_show() { need sops; [[ -f "$ENC" ]] || { echo "No existe $ENC." >&2; exit 1; }; sops -d "$ENC"; }
cmd_rekey(){ need sops; [[ -f "$ENC" ]] || { echo "No existe $ENC." >&2; exit 1; }; sops updatekeys "$ENC"; }

case "${1:-}" in
  init-key) cmd_init_key ;;
  migrate)  shift || true; cmd_migrate "$@" ;;
  edit)     cmd_edit ;;
  show)     cmd_show ;;
  rekey)    cmd_rekey ;;
  *) echo "uso: $0 {init-key | migrate [archivo] | edit | show | rekey}"; exit 1 ;;
esac
