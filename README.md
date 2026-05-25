# Dotfiles

Configuración personal de terminal para macOS — orientada a SRE, Kubernetes, AWS, Python.

## Stack

| Capa | Herramienta |
|------|-------------|
| Shell | **zsh** con **Vi mode** (`v` abre comando en `$EDITOR`) |
| Plugin manager | **Zinit** (turbo mode async post-prompt) |
| Prompt | **Starship** con prompt de dos líneas y módulos contextuales |
| History | **Atuin** (Ctrl-F búsqueda global, Ctrl-G por directorio) |
| Dir nav | **Zoxide** (`z`, `zi`) |
| Completions | **Carapace** (universal) + `OMZP::kubectl` |
| Editor | **Neovim** + **LazyVim** (python / yaml / helm / terraform / docker / markdown) |
| Python | **uv** + auto-activación de `.venv` vía hook `chpwd` |
| Files | `eza` (ls), `bat` (cat), `fd` (find), `rg` (grep) |
| System | `btm` (top), `gping` (ping), `fzf` (search) |
| Kubernetes | `kubectl` + alias `k`, `kctx`, `kns`, `ks` (stern), `k9` (k9s) |
| AWS | `aws` CLI + función `awsp` (fzf profile picker) |
| Java | SDKMAN (lazy) |
| Node | NVM (lazy) |

## Instalación

```bash
git clone https://github.com/cbenitezpy/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
python3 install.py
```

`install.py` crea symlinks desde `~/.dotfiles/*` hacia las ubicaciones reales en home, haciendo backup de cualquier archivo previo a `*.pre-dotfiles`.

## Dependencias (Homebrew)

```bash
brew install \
  zsh starship zoxide atuin carapace fzf \
  eza bat fd ripgrep bottom gping \
  neovim uv \
  awscli kubectl helm

# Nerd Font usado en iTerm2 (JetBrainsMono parcheada con iconos)
brew install --cask font-jetbrains-mono-nerd-font
```

Plus:
```bash
# Zinit (plugin manager)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

# SDKMAN (Java)
curl -s "https://get.sdkman.io" | bash

# NVM (Node)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
```

## Post-instalación

1. **Neovim** — al abrir `nvim` por primera vez, LazyVim instala plugins + Mason instala LSPs/formatters (Pyright, Ruff, yaml-language-server, helm-ls, terraform-ls, etc.).
2. **GitHub CLI** — `gh auth login`
3. **Atuin** — `atuin login` para sincronizar history entre máquinas
4. **Claude Code MCP** — copiar template y completar token:
   ```bash
   cp ~/.dotfiles/claude/mcp.json.template ~/.claude/mcp.json
   ```
5. **iTerm2** — apuntar prefs al dotfiles folder:
   - Abrir iTerm2 → `Settings` → `General` → `Preferences`
   - Marcar **"Load preferences from a custom folder or URL"** → `~/.dotfiles/iterm2/`
   - Cuando pregunte: **"Use settings from folder"** (no copiar).
   - Marcar **"Save changes to folder when iTerm2 quits"** para que los cambios queden versionados.
   - En `Settings` → `Profiles` → `Text`, verificar que la fuente sea **JetBrainsMono Nerd Font Mono** (size 13). Si no aparece, reiniciar iTerm2 después del `brew install --cask font-jetbrains-mono-nerd-font`.

## Contenido del repo

```
~/.dotfiles/
├── shell/         # .zshrc, .zprofile, .bashrc, ...
├── starship/      # starship.toml (2-line prompt + Nerd Font icons)
├── nvim/          # LazyVim config (init.lua + lua/ + lazy-lock.json)
├── iterm2/        # com.googlecode.iterm2.plist (Load via custom folder)
├── git/           # .gitconfig, .gitignore_global
├── tmux/          # .tmux.conf
├── atuin/         # config.toml (history sync)
├── gh/            # GitHub CLI config
├── zed/           # Zed editor settings
├── claude/        # Claude Code CLAUDE.md, settings.json, mcp.json.template
├── dev/           # .sdkmanrc
├── install.py     # symlink installer
└── README.md
```

## Keybindings notables

| Key | Modo | Acción |
|-----|------|--------|
| `Esc` | insert | Entra a vi-normal mode |
| `v` | vi-normal | Edita comando actual en `$EDITOR` (nvim) |
| `Up Arrow` | ambos | Búsqueda Atuin |
| `Ctrl-F` | insert | Búsqueda Atuin full-screen |
| `Ctrl-G` | insert | Búsqueda Atuin scoped al directorio actual |
| `Ctrl-A` / `Ctrl-E` | vi-insert | Beginning/end of line (emacs compat) |

## Funciones custom

- **`awsp`** — fuzzy-select AWS profile con fzf, exporta `AWS_PROFILE`
- **`awsp-clear`** — unset `AWS_PROFILE`
- **`_auto_venv`** — hook `chpwd` que activa/desactiva `.venv/` al moverte entre directorios

## Aliases destacados

```bash
# Modern CLI
alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --icons --grid'
alias cat='bat --style=plain'
alias find='fd'
alias top='btm'
alias ping='gping'

# Kubernetes
alias k='kubectl'        # + completion compdef
alias kctx='kubectx'
alias kns='kubens'
alias ks='stern'
alias k9='k9s'

# Helm
alias h='helm'
alias hls='helm list'
alias hin='helm install'
alias hup='helm upgrade'
alias hun='helm uninstall'
```

(El plugin `OMZP::kubectl` que carga Zinit aporta también `kgp`, `kgs`, `kgn`, `kgd`, `kdp`, `kds`, `kdd`, `kl`, `kx`, `kaf`, `kdf`.)

## Starship — preview

El prompt de dos líneas muestra (de izquierda a derecha):
`OS · dir · git branch/status · lenguaje detectado · k8s context · gcloud · terraform · docker · cmd_duration` y a la derecha la hora local. El símbolo `❯` queda en la segunda línea para tipeo rápido sin importar el largo del segmento superior.

## Filosofía

- **Velocidad antes que features**: Zinit turbo difiere todo lo no esencial al primer prompt.
- **CLI moderno sobre alias clásicos**: pero sin romper portabilidad (no aliasear `grep`, `cd`, etc. cuando hay conflicto conocido — por ejemplo `rg` choca con la función shell que define Claude Code).
- **Auto-activación de venvs sin plugins externos**: un hook nativo `chpwd` de 12 líneas vs una dependencia.
- **Symlinks sobre copia**: edits al repo se reflejan inmediatamente en home; rollback es `git checkout`.
