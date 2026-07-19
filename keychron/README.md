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

En el [Keychron Launcher](https://launcher.keychron.com) (Chrome/Edge/Opera):

1. Conectá el numpad **por cable** y dale *Authorize device*.
2. Para **respaldar**: `Save/Load` → **Save Current Layout** → guardá el `.json`
   acá como `k0max-keymap.json` y commiteá.
3. Para **restaurar** (máquina nueva o después de un reset):
   `Save/Load` → **Load Saved Layout** → elegí `k0max-keymap.json`.

El keymap vive en la EEPROM del teclado, así que viaja con el teclado: no hace
falta reconfigurar por máquina. El JSON es el backup y el historial.

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
