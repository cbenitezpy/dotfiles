# Guía práctica de tu terminal

Instructivo hands-on de lo configurado en junio 2026: **sesh** (sesiones), **sops + age** (secrets), **plugins de tmux** y los atajos clave del stack. Hacé los ejercicios en orden; toman ~20 minutos en total.

> Recordatorio: el prefix de tmux es **`Ctrl-a`** (también funciona `` ` ``). Cuando leas `prefix + T`, es: soltá `Ctrl-a`, después apretá `T`.

---

## 1. Sesiones con sesh + tmux

### La idea
Una **sesión** tmux por proyecto, con sus ventanas y paneles. sesh te deja saltar entre proyectos con fuzzy search, creando la sesión si no existe. Olvidate de `tmux attach -t ...`.

### Ejercicio 1 — el popup
```bash
tmux                 # entrá a tmux
```
1. `prefix + T` → se abre el popup de sesh.
2. Escribí unas letras de cualquier proyecto que hayas visitado (sesh lee tu historial de **zoxide**).
3. Enter → te crea/conecta la sesión y te deja en ese directorio.
4. `prefix + T` de nuevo → elegí `dotfiles ⚙️` (sesión fija definida en `sesh/sesh.toml`, arranca mostrando `git status -sb`).

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
1. `prefix + T` → andá a un proyecto A.
2. `prefix + T` → andá a un proyecto B.
3. `prefix + T` → `Ctrl-t` → volvé a A. Las dos sesiones siguen vivas, cada una con su estado.
4. `prefix + T` → `Ctrl-d` sobre B para matarla cuando termines.

### Sesiones fijas
Editá `~/.dotfiles/sesh/sesh.toml` para agregar proyectos frecuentes con comando de arranque. Recargá con `prefix + r`.

---

## 2. Persistencia: resurrect + continuum

Tus sesiones **sobreviven reinicios** de la Mac.

| Atajo | Acción |
|-------|--------|
| `prefix + Ctrl-s` | guardar snapshot de todas las sesiones |
| `prefix + Ctrl-r` | restaurar el último snapshot |

**continuum** además guarda solo cada 15 min. Tras un reinicio: abrí tmux y `prefix + Ctrl-r` — vuelven sesiones, ventanas y paneles.

### Ejercicio 3
1. Armá 2 sesiones con algunas ventanas.
2. `prefix + Ctrl-s` (vas a ver "saved").
3. `tmux kill-server` (mata todo).
4. `tmux` → `prefix + Ctrl-r` → todo de vuelta.

---

## 3. Secrets cifrados (sops + age)

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
Verificá con `echo $TU_VARIABLE` que siguen cargadas.

> **CRÍTICO:** respaldá `~/.config/sops/age/keys.txt` (1Password, USB cifrado). Sin esa clave NO recuperás tus secrets en otra máquina.

### Uso diario
```bash
./secrets/manage.sh edit    # editar (abre nvim, recifra al guardar)
./secrets/manage.sh show    # ver en claro
```
Tras editar: `exec zsh` para recargar las variables.

### Ejercicio 4
1. `./secrets/manage.sh edit` → agregá `PRUEBA_GUIA=funciona`.
2. Guardá y salí. `exec zsh`.
3. `echo $PRUEBA_GUIA` → debe decir `funciona`.
4. `cat secrets/vars.sops.env` → fijate que es ciphertext ilegible. Eso es lo que ve GitHub.
5. `./secrets/manage.sh edit` → borrá la variable de prueba.

---

## 4. Movimiento dentro de tmux

| Atajo | Acción |
|-------|--------|
| `prefix + -` | split horizontal (panel abajo) |
| `prefix + =` | split vertical (panel al lado) |
| `Ctrl-h/j/k/l` | moverte entre paneles **sin prefix** (y entre splits de nvim, mismo atajo) |
| `prefix + r` | recargar config de tmux |
| `prefix + I` | instalar/actualizar plugins (TPM) |

**Copy mode** (estilo vim): `prefix + [` para entrar, movete con `hjkl`, `v` selecciona, `y` copia al portapapeles de macOS, `q` sale. El mouse también funciona (scroll y selección).

---

## 5. Historial y navegación (lo que ya tenías, dominalo)

| Atajo | Acción |
|-------|--------|
| `↑` | búsqueda Atuin desde lo tipeado |
| `Ctrl-F` | Atuin full-screen, historial global (fuzzy) |
| `Ctrl-G` | Atuin filtrado al **directorio actual** |
| `z nombre` | saltar a directorio frecuente (zoxide) |
| `zi nombre` | igual pero interactivo |
| `Esc` → `v` | editar el comando actual en nvim (vi-mode) |

En Atuin: `Enter` trae el comando al prompt para editarlo; `Enter` de nuevo lo ejecuta.

### Ejercicio 5
1. `Ctrl-F` → buscá `brew` → Enter → editá → ejecutá.
2. `cd ~/.dotfiles` → `Ctrl-G` → mirá solo lo que corriste acá.
3. `z dot` → deberías caer en `~/.dotfiles`.

---

## 6. Detalle nuevo: comentarios interactivos

Ahora podés pegar bloques con comentarios sin que exploten:
```bash
git status   # esto ya no rompe nada
```
(Antes tu zsh pasaba el `#` como argumento al comando.)

---

## Chuleta final

```
SESIONES        prefix T (sesh) · prefix Ctrl-s/Ctrl-r (guardar/restaurar)
PANELES         prefix - / =  · Ctrl-h/j/k/l
HISTORIAL       ↑ · Ctrl-F global · Ctrl-G directorio
SALTOS          z <dir> · zi <dir>
SECRETS         ./secrets/manage.sh {edit|show}
COPY MODE       prefix [ · v · y · q
RELOAD          prefix r (tmux) · exec zsh (shell)
```

El detalle completo del stack está en el [README](../README.md).
