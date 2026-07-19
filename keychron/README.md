# Keychron K0 Max — numpad QMK wireless

Numpad low-profile de 27 teclas + **knob (encoder)** + columna de macros a la
izquierda. Tri-mode (BT / 2.4G / cable), QMK/VIA.

Se configura con el **Keychron Launcher** (web app; requiere Chrome/Edge/Opera
por WebHID). El keymap se exporta/importa como JSON, y ese JSON se versiona acá.

## Archivos

| Archivo | Qué es |
|---|---|
| `k0max-keymap.json` | keymap exportado del Launcher (fuente de verdad, importable) |

## Layout

| Zona | Función | Keycode / macro |
|---|---|---|
| **Knob — girar** | Volumen ± | `KC_VOLU` / `KC_VOLD` |
| **Knob — push** | Play / Pause | `KC_MPLY` |
| **Macro 1** | Abrir/enfocar **iTerm** | `KC_F13` → lo traduce skhd |
| **Macro 2** | Abrir/enfocar **navegador** | `KC_F14` → lo traduce skhd |
| **Macro 3** | **Spotlight** | `LGUI(KC_SPC)` (Cmd+Space) |
| **Macro 4** | Popup de **sesh** en tmux | macro: `Ctrl-a` luego `T` |
| **Base** | Numpad clásico (números, operadores, Enter) | sin cambios |
| **Capa Fn** | tmux: split `-` / `=`, zoom, cambiar ventana | macros con prefijo `Ctrl-a` |

> Las macros de tmux solo tienen sentido con iTerm en foco.

## Por qué hace falta skhd

Un teclado solo manda **pulsaciones**, no puede lanzar apps. Por eso las teclas
de iTerm y navegador mandan `F13`/`F14` (teclas que macOS reconoce y nada más
usa) y **skhd** las traduce a `open -a`. Ver `../skhd/skhdrc`.

Spotlight, el knob y las macros de tmux **no** necesitan skhd: son pulsaciones
directas.

## Exportar / importar el keymap

> El keymap vive en la **memoria del teclado**, así que esto se hace **una sola
> vez**, en la máquina donde esté conectado. Después el teclado lleva su config
> a cualquier computadora.

### Paso 1 — Exportar el keymap actual (hacelo primero)

No hace falta configurar nada acá: solo sacar una copia del estado actual.

1. Conectá el numpad **por cable USB** (para configurar, cable — no Bluetooth).
2. Abrí **<https://launcher.keychron.com>** en **Chrome, Edge u Opera**.
   (No funciona en Safari ni Zen: necesita WebHID.)
3. Clic en **Authorize device** / *Connect* → en el diálogo del navegador
   seleccioná el **K0 Max** → *Connect*.
4. Buscá la sección de guardar/cargar layout (rotulada **Save + Load**,
   *Backup* o similar según versión) y usá la opción de **guardar / exportar el
   layout actual**. Descarga un `.json`.
5. Guardalo en este repo como `keychron/k0max-keymap.json` y commiteá:

   ```bash
   cd ~/.dotfiles && git add keychron/k0max-keymap.json
   git commit -m "chore(keychron): keymap base exportado del K0 Max"
   git push
   ```

### Paso 2 — Aplicar el layout personalizado

Con el JSON exportado ya versionado, el keymap con el layout de arriba se
prepara editando ese archivo (no hace falta remapear tecla por tecla en la UI).
Después, en el Launcher:

**Save + Load → cargar / importar layout** → elegí el `.json` actualizado.

### Restaurar (reset, teclado nuevo, etc.)

Mismo import del Paso 2 con `k0max-keymap.json`.

## Setup de skhd (una vez por máquina)

```bash
brew trust koekeishiya/formulae   # una vez: Homebrew bloquea taps de terceros
brew bundle install               # instala skhd
python3 install.py                # symlink de skhdrc
skhd --start-service              # pide permiso de Accesibilidad
```

Sin el `brew trust`, `brew bundle` falla con
*"Refusing to load formula ... from untrusted tap"*.

Si tras conceder el permiso no responde: `skhd --restart-service`.
