# Guía práctica de tu terminal

Instructivo hands-on de lo configurado en junio 2026: **sesh** (sesiones), **sops + age** (secrets), **plugins de tmux**, **nvim/LazyVim** y los atajos clave del stack. Hacé los ejercicios en orden; toman ~30 minutos.

> **Tu prefix de tmux es `Ctrl-a`.** En esta guía escribo las teclas completas: cuando veas `Ctrl-a` `T`, es soltá `Ctrl-a` y después apretá `T`. (También tenés `` ` `` como prefix alternativo, pero usá `Ctrl-a` que es el principal.)

---

## 1. Sesiones con sesh + tmux

### La idea
Una **sesión** tmux por proyecto, con sus ventanas y paneles. sesh te deja saltar entre proyectos con fuzzy search, creando la sesión si no existe. Olvidate de `tmux attach -t ...`.

### Ejercicio 1 — el popup
```bash
tmux
```
1. `Ctrl-a` `T` → se abre el popup de sesh.
2. Escribí unas letras de cualquier proyecto que hayas visitado (sesh lee tu historial de **zoxide**).
3. Enter → te crea/conecta la sesión y te deja en ese directorio.
4. `Ctrl-a` `T` de nuevo → elegí `dotfiles ⚙️` (sesión fija de `sesh/sesh.toml`, arranca mostrando `git status -sb`).

### Filtros dentro del popup
| Tecla | Muestra |
|-------|---------|
| `Ctrl-a` | todo (default) |
| `Ctrl-t` | solo sesiones tmux activas |
| `Ctrl-g` | sesiones fijas de `sesh.toml` |
| `Ctrl-x` | directorios de zoxide |
| `Ctrl-f` | buscar carpetas en `~` (con fd) |
| `Ctrl-d` | **matar** la sesión seleccionada (deshabilitado en modo find, a propósito) |

### Ejercicio 2 — flujo real
1. `Ctrl-a` `T` → andá a un proyecto A.
2. `Ctrl-a` `T` → andá a un proyecto B.
3. `Ctrl-a` `T` → `Ctrl-t` → volvé a A. Las dos sesiones siguen vivas, cada una con su estado.
4. `Ctrl-a` `T` → `Ctrl-d` sobre B para matarla cuando termines.

### Sesiones fijas
Editá `~/.dotfiles/sesh/sesh.toml` para agregar proyectos frecuentes con comando de arranque. Recargá con `Ctrl-a` `r`.

---

## 2. Persistencia: resurrect + continuum

Tus sesiones **sobreviven reinicios** de la Mac.

| Atajo | Acción |
|-------|--------|
| `Ctrl-a` `Ctrl-s` | guardar snapshot de todas las sesiones |
| `Ctrl-a` `Ctrl-r` | restaurar el último snapshot |

**continuum** además guarda solo cada 15 min.

### Ejercicio 3
1. Armá 2 sesiones con algunas ventanas.
2. `Ctrl-a` `Ctrl-s` (vas a ver "saved").
3. `tmux kill-server` (mata todo).
4. `tmux` → `Ctrl-a` `Ctrl-r` → todo de vuelta.

---

## 3. nvim + LazyVim

### La idea
Tu editor es Neovim con **LazyVim**. La tecla mágica es **`Space`** (el "leader"). El truco para aprender: apretá `Space` y **esperá** — aparece un menú (**which-key**) con todo lo que podés hacer. No hace falta memorizar.

> Moverte entre splits de nvim y paneles de tmux es el **mismo atajo**: `Ctrl-h/j/k/l` (gracias a vim-tmux-navigator). No notás la frontera.

### Atajos esenciales (leader = `Space`)
| Atajo | Acción |
|-------|--------|
| `Space` (y esperar) | menú which-key — tu mapa de todo |
| `Space` `e` | explorador de archivos (neo-tree) |
| `Space` `Space` | buscar archivos (fuzzy) |
| `Space` `/` | buscar texto en el proyecto (live grep) |
| `Space` `,` | cambiar entre buffers abiertos |
| `Ctrl-s` | guardar |
| `Space` `q` `q` | salir |

### Navegación de código (LSP — ya tenés Pyright, Ruff, yaml, helm, terraform, etc.)
| Atajo | Acción |
|-------|--------|
| `g` `d` | ir a la definición |
| `g` `r` | ver referencias |
| `K` | doc/hover del símbolo bajo el cursor |
| `Space` `c` `a` | code action (quick fix, imports, etc.) |
| `Space` `c` `r` | renombrar símbolo en todo el proyecto |
| `]d` / `[d` | siguiente / anterior diagnóstico (error/warning) |
| `Space` `c` `d` | ver el diagnóstico de la línea |

### Gestión del editor
| Atajo | Acción |
|-------|--------|
| `Space` `l` | UI de **Lazy** (plugins) |
| `Space` `c` `m` | **Mason** (LSPs/formatters instalados) |

### Ejercicio 4
1. `cd ~/.dotfiles && nvim install.py`
2. Apretá `Space` y esperá: leé el menú un par de segundos.
3. `Space` `Space` → escribí `zshrc` → abrí `shell/.zshrc`.
4. `Space` `/` → buscá `atuin` → saltá a una coincidencia.
5. Parate sobre una función y apretá `K` para ver su doc; `gd` para ir a su definición.
6. `Ctrl-s` para guardar, `Space` `q` `q` para salir.

---

## 4. Movimiento dentro de tmux

| Atajo | Acción |
|-------|--------|
| `Ctrl-a` `-` | split horizontal (panel abajo) |
| `Ctrl-a` `=` | split vertical (panel al lado) |
| `Ctrl-h/j/k/l` | moverte entre paneles **sin prefix** (y entre splits de nvim) |
| `Ctrl-a` `r` | recargar config de tmux |
| `Ctrl-a` `I` | instalar/actualizar plugins (TPM) |

**Copy mode** (estilo vim): `Ctrl-a` `[` para entrar, movete con `hjkl`, `v` selecciona, `y` copia al portapapeles de macOS, `q` sale. El mouse también funciona (scroll y selección).

---

## 5. Historial y navegación de shell

| Atajo | Acción |
|-------|--------|
| `↑` | búsqueda Atuin desde lo tipeado |
| `Ctrl-F` | Atuin full-screen, historial global (fuzzy) |
| `Ctrl-G` | Atuin filtrado al **directorio actual** |
| `z nombre` | saltar a directorio frecuente (zoxide) |
| `zi nombre` | igual pero interactivo |
| `Esc` → `v` | editar el comando actual en nvim (vi-mode del shell) |

En Atuin: `Enter` trae el comando al prompt para editarlo; `Enter` de nuevo lo ejecuta.

### Ejercicio 5
1. `Ctrl-F` → buscá `brew` → Enter → editá → ejecutá.
2. `cd ~/.dotfiles` → `Ctrl-G` → mirá solo lo que corriste acá.
3. `z dot` → deberías caer en `~/.dotfiles`.

---

## 6. Secrets cifrados (sops + age)

### La idea
Tus API keys ya no viven en `~/.env` plano: viven **cifradas** en `~/.dotfiles/secrets/vars.sops.env` (versionable en git sin riesgo) y se cargan solas al abrir el shell. La clave privada está en `~/.config/sops/age/keys.txt` — **fuera** del repo.

### Setup inicial (una sola vez — si aún no lo hiciste)
```bash
cd ~/.dotfiles
./secrets/manage.sh init-key
./secrets/manage.sh migrate
./secrets/manage.sh show
rm ~/.env
exec zsh
```

> **CRÍTICO:** respaldá `~/.config/sops/age/keys.txt` (1Password, USB cifrado). Sin esa clave NO recuperás tus secrets en otra máquina.

### Uso diario
```bash
./secrets/manage.sh edit
./secrets/manage.sh show
```
Tras editar: `exec zsh` para recargar las variables.

### Ejercicio 6
1. `./secrets/manage.sh edit` → agregá `PRUEBA_GUIA=funciona`.
2. Guardá y salí. `exec zsh`.
3. `echo $PRUEBA_GUIA` → debe decir `funciona`.
4. `cat secrets/vars.sops.env` → fijate que es ciphertext ilegible. Eso es lo que ve GitHub.
5. `./secrets/manage.sh edit` → borrá la variable de prueba.

---

## 7. Detalle: comentarios interactivos

Ahora podés pegar bloques con comentarios sin que exploten:
```bash
git status   # esto ya no rompe nada
```
(Antes tu zsh pasaba el `#` como argumento al comando.)

---

## Chuleta final

```
SESIONES     Ctrl-a T (sesh) · Ctrl-a Ctrl-s / Ctrl-a Ctrl-r (guardar/restaurar)
PANELES      Ctrl-a - / =  · Ctrl-h/j/k/l (entre paneles y splits de nvim)
NVIM         Space (menú) · Space e (archivos) · Space Space (buscar) · Space / (grep)
             gd (definición) · K (doc) · Space c a (fix) · Space c r (rename)
HISTORIAL    ↑ · Ctrl-F global · Ctrl-G directorio
SALTOS       z <dir> · zi <dir>
SECRETS      ./secrets/manage.sh {edit|show}
COPY MODE    Ctrl-a [ · v · y · q
RELOAD       Ctrl-a r (tmux) · exec zsh (shell)
```

El detalle completo del stack está en el [README](../README.md).
