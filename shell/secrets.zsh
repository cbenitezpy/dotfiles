# ============================================================
# Secrets — carga de env cifrado (sops + age) al iniciar el shell
# ------------------------------------------------------------
# Descifra ~/.dotfiles/secrets/vars.sops.env con la clave age de
# ~/.config/sops/age/keys.txt y exporta las variables.
# Si falta sops, la clave o el archivo: avisa por stderr y sigue,
# para que una máquina sin secrets igual tenga un shell funcional.
#
# Gestión: ~/.dotfiles/secrets/manage.sh {init-key|migrate|edit|show|rekey}
# Doc:     ~/.dotfiles/secrets/README.md
# ============================================================

_dotfiles_load_secrets() {
  local enc="${DOTFILES_SECRETS_FILE:-$HOME/.dotfiles/secrets/vars.sops.env}"
  local keyfile="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"

  command -v sops >/dev/null 2>&1 || { print -u2 "[secrets] sops no instalado — omito (brew install sops age)"; return 0; }
  [[ -f "$enc" ]]     || { print -u2 "[secrets] no existe $enc — omito (corré secrets/manage.sh migrate)"; return 0; }
  [[ -f "$keyfile" ]] || { print -u2 "[secrets] falta la clave age en $keyfile — omito"; return 0; }

  local out
  out="$(SOPS_AGE_KEY_FILE="$keyfile" sops -d "$enc" 2>/dev/null)" \
    || { print -u2 "[secrets] fallo al descifrar $enc — omito"; return 0; }

  # Parseo línea por línea con export (NO eval): seguro ante espacios,
  # caracteres especiales y valores tipo $(...).
  local line k v
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    k="${line%%=*}"; v="${line#*=}"
    [[ "$k" == "$line" ]] && continue   # línea sin '='
    export "$k=$v"
  done <<< "$out"
}

_dotfiles_load_secrets
