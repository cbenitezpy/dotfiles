# ============================================================
# Secrets — carga de env cifrado (sops + age) al iniciar el shell
# ------------------------------------------------------------
# Carga TODOS los archivos secrets/*.sops.env que esta máquina pueda
# descifrar con su clave age (~/.config/sops/age/keys.txt) y exporta
# las variables. Los archivos que NO se pueden descifrar (porque son
# de otra clave, p.ej. tu secret personal en la máquina de la oficina)
# se saltean EN SILENCIO.
#
# Esto permite, en máquinas distintas con claves distintas:
#   - vars.sops.env   → personal   (en el repo; solo descifra tu máquina)
#   - work.sops.env   → oficina     (gitignored; solo descifra esa máquina)
#
# Silencioso por diseño. Para depurar: export DOTFILES_SECRETS_DEBUG=1
#
# Gestión: ~/.dotfiles/secrets/manage.sh {init-key|migrate|edit|show|rekey} [archivo]
# Doc:     ~/.dotfiles/secrets/README.md
# ============================================================

_dotfiles_load_secrets() {
  local dir="${DOTFILES_SECRETS_DIR:-$HOME/.dotfiles/secrets}"
  local keyfile="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"
  local dbg="${DOTFILES_SECRETS_DEBUG:-}"

  command -v sops >/dev/null 2>&1 || { [[ -n "$dbg" ]] && print -u2 "[secrets] sops no instalado"; return 0; }
  [[ -f "$keyfile" ]] || { [[ -n "$dbg" ]] && print -u2 "[secrets] sin clave age ($keyfile)"; return 0; }

  local f out line k v
  # (N) = NULL_GLOB: si no hay coincidencias, no itera (sin error).
  for f in "$dir"/*.sops.env(N); do
    out="$(SOPS_AGE_KEY_FILE="$keyfile" sops -d "$f" 2>/dev/null)" || {
      [[ -n "$dbg" ]] && print -u2 "[secrets] $f: no se pudo descifrar con esta clave — salteo"
      continue
    }
    while IFS= read -r line; do
      [[ -z "$line" || "$line" == \#* ]] && continue
      k="${line%%=*}"; v="${line#*=}"
      [[ "$k" == "$line" ]] && continue   # línea sin '='
      export "$k=$v"
    done <<< "$out"
    [[ -n "$dbg" ]] && print -u2 "[secrets] $f: cargado"
  done
}

_dotfiles_load_secrets
