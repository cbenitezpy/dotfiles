# ============================================================
# ~/.zshrc — Zinit + Vi mode + LazyVim + uv + tooling moderno
# ============================================================

# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && \
  builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

# --- Locale & Editor ---
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export EDITOR='nvim'
export VISUAL='nvim'
export _ZO_DOCTOR=0   # zinit's deferred plugins confuse zoxide's doctor heuristic

# --- zsh options ---
setopt interactive_comments   # permite '#' como comentario al pegar comandos

# --- PATH ---
export PATH="/opt/homebrew/bin:$HOME/.cargo/bin:$HOME/.antigravity/antigravity/bin:$PATH"

# --- Load private env vars (sops + age encrypted) ---
# Carga secrets cifrados; ver secrets/README.md. Falla elegante si falta la clave.
[[ -f "$HOME/.dotfiles/shell/secrets.zsh" ]] && source "$HOME/.dotfiles/shell/secrets.zsh"
# Transicional: ~/.env en texto plano. Una vez migrado a sops, borralo y quita esta linea.
[[ -f ~/.env ]] && source ~/.env
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# --- Kubernetes config (chocolandia) ---
export KUBECONFIG="$HOME/chocolandia_kube/terraform/environments/chocolandiadc-mvp/kubeconfig"

# ============================================================
# Zinit bootstrap
# ============================================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d "$ZINIT_HOME/.git" ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# --- Completion (must run before plugins that use compdef) ---
# -C skips the .zcompdump security check (already validated daily by zicompinit
# in the turbo block below). ~10x faster than plain `compinit`.
autoload -Uz compinit && compinit -C
zmodload zsh/complist   # required for `menuselect` keymap below
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
zstyle ':completion:*' menu select
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-max 50
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
# Priorize commands over files in tab completion
zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*' group-name ''
zstyle ':completion:*:commands' rehash 1
zstyle ':completion:*' tag-order 'commands functions aliases builtins reserved-words' 'local-directories directories' files
zstyle ':completion:*:git:*' tag-order 'common-commands'
# Arrow navigation inside completion menu
bindkey -M menuselect '^[[A' up-line-or-history
bindkey -M menuselect '^[[B' down-line-or-history
bindkey -M menuselect '^[[C' forward-char
bindkey -M menuselect '^[[D' backward-char
bindkey -M menuselect '^M' .accept-line

# ============================================================
# Vi mode
# ============================================================
bindkey -v
export KEYTIMEOUT=1   # snappy mode switch
# `v` in normal mode → edit current command in $EDITOR (nvim)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line
# Familiar bindings even in vi-insert mode
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line

# ============================================================
# Zinit plugins (turbo mode = async-after-prompt)
# ============================================================
# Syntax highlighting + autosuggestions + completions, todo async
zinit wait lucid light-mode for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
    zsh-users/zsh-completions

# OMZ kubectl plugin (aliases: kgp, kgs, kgn, kgd, kdp, kds, kdd, kl, kx, kaf, kdf, etc.)
zinit wait lucid for OMZP::kubectl

if command -v carapace &>/dev/null; then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  export CARAPACE_LENIENT=false
  zinit wait'1' lucid as'null' atload'source <(carapace _carapace)' for \
    zdharma-continuum/null
fi

# ============================================================
# Tool initializations
# ============================================================
eval "$(starship init zsh)"     # Prompt

# uv shell completion — cached in ~/.zfunc/_uv (regenerate manually if uv updates)
if command -v uv &>/dev/null; then
  [[ -d "$HOME/.zfunc" ]] || mkdir -p "$HOME/.zfunc"
  fpath=("$HOME/.zfunc" $fpath)
  [[ -f "$HOME/.zfunc/_uv" ]] || uv generate-shell-completion zsh > "$HOME/.zfunc/_uv" 2>/dev/null
fi

# --- Atuin (history search, customized bindings to not conflict with tmux Ctrl-B) ---
if command -v atuin &> /dev/null; then
  eval "$(atuin init zsh --disable-ctrl-r --disable-up-arrow)"
  # Up-arrow keeps atuin search in both vi modes
  bindkey -M viins '^[[A' atuin-up-search
  bindkey -M vicmd '^[[A' atuin-up-search
  # Ctrl-F: full atuin search (Ctrl-R conflicts with tmux for some)
  bindkey '^F' _atuin_search_widget
  # Ctrl-G: directory-scoped atuin search
  _atuin_search_directory_widget() {
    emulate -L zsh
    zle -I
    local selected=$(atuin search --interactive --filter-mode directory)
    if [[ -n $selected ]]; then
      BUFFER=$selected
      zle end-of-line
    fi
    zle reset-prompt
  }
  zle -N _atuin_search_directory_widget
  bindkey '^G' _atuin_search_directory_widget
fi

# --- FZF ---
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ============================================================
# Kubectl / Helm / k8s tooling
# ============================================================
alias k=kubectl
[ -f "$(command -v kubectl)" ] && source <(kubectl completion zsh) && compdef __start_kubectl k

# Extra k8s aliases not provided by OMZP::kubectl
alias kctx='kubectx'
alias kns='kubens'
alias ks='stern'                 # mejores logs multi-pod
alias k9='k9s'

# Helm
alias h='helm'
alias hls='helm list'
alias hin='helm install'
alias hun='helm uninstall'
alias hup='helm upgrade'

# ============================================================
# AWS CLI completion + fzf profile picker
# ============================================================
autoload -Uz bashcompinit && bashcompinit
# Portable across Intel (/usr/local) and Apple Silicon (/opt/homebrew) Macs
_aws_comp=$(command -v aws_completer 2>/dev/null)
[[ -n "$_aws_comp" ]] && complete -C "$_aws_comp" aws
unset _aws_comp

awsp() {
  local profile
  profile=$(aws configure list-profiles 2>/dev/null | fzf --prompt="AWS profile> " --height=40% --reverse) || return
  if [[ -n "$profile" ]]; then
    export AWS_PROFILE="$profile"
    echo "AWS_PROFILE=$profile"
  fi
}
awsp-clear() { unset AWS_PROFILE; echo "AWS_PROFILE cleared"; }

# ============================================================
# Python venv auto-activation (chpwd hook, no plugin needed)
# ============================================================
autoload -Uz add-zsh-hook
_auto_venv() {
  if [[ -r "$PWD/.venv/bin/activate" ]]; then
    if [[ "$VIRTUAL_ENV" != "$PWD/.venv" ]]; then
      source "$PWD/.venv/bin/activate"
    fi
  elif [[ -n "$VIRTUAL_ENV" ]]; then
    local venv_root="$(dirname "$VIRTUAL_ENV")"
    if [[ "$PWD" != "$venv_root"* ]]; then
      deactivate 2>/dev/null
    fi
  fi
}
add-zsh-hook chpwd _auto_venv
_auto_venv  # run once for initial directory

# ============================================================
# Lazy load NVM (for occasional Node.js work)
# ============================================================
export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  nvm "$@"
}
node() { nvm; node "$@"; }
npm() { nvm; npm "$@"; }
npx() { nvm; npx "$@"; }

# ============================================================
# SDKMAN (Java)
# ============================================================
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# ============================================================
# Docker
# ============================================================
fpath=("$HOME/.docker/completions" $fpath)

# ============================================================
# Aliases — Modern CLI replacements
# ============================================================
alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --icons --grid'
alias la='eza -lah --icons --grid'
alias tree='eza --tree --icons'
alias cat='bat --style=plain'
alias g='git'
alias zi='z -i'
alias top='btm'
alias ping='gping'
alias find='fd'

# Claude Code: only alias to the local install if it actually exists;
# otherwise let the binary be found via PATH (brew, npm, etc.)
[ -x "$HOME/.claude/local/claude" ] && alias claude="$HOME/.claude/local/claude"

# ============================================================
# iTerm2 shell integration
# ============================================================
[[ -e "${HOME}/.iterm2_shell_integration.zsh" ]] && source "${HOME}/.iterm2_shell_integration.zsh"

# ============================================================
# zoxide must be initialized last (per zoxide doctor)
# ============================================================
eval "$(zoxide init zsh)"

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && \
  builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"

# Created by `pipx` on 2026-06-13 21:23:58
export PATH="$PATH:/Users/cbenitez/.local/bin"

# headroom proxy (Docker container 'headroom' on :8787)
alias cc='ANTHROPIC_BASE_URL=http://localhost:8787 claude'
