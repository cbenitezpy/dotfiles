# Keychron K0 Max — numpad QMK wireless

Numpad low-profile de 27 teclas + **knob (encoder)** + columna de macros `M1–M5`
a la izquierda. Tri-mode (BT / 2.4G / cable), QMK/VIA.

Se configura con el **Keychron Launcher** (<https://launcher.keychron.com>) desde
**Chrome, Edge u Opera** (necesita WebHID; no anda en Safari ni Zen).

## Distribución física

```
[Knob]   Esc    Del    Tab    Backspace
 M1      N.Lck   ÷      ×      -
 M2      7       8      9      +
 M3      4       5      6      |
 M4      1       2      3     N.Ent
 M5      0       .             |
```

## Qué le vamos a poner

| Tecla | Función | Dónde sale en el Launcher |
|---|---|---|
| **Knob girar** | Volumen ± | pestaña **Media** |
| **Knob presionar** | Play / Pause | pestaña **Media** |
| **M1** | Abrir/enfocar **iTerm** | **Special Keys** → `F13` |
| **M2** | Abrir/enfocar **Zen** | **Special Keys** → `F14` |
| **M3** | **Spotlight** (Cmd+Space) | **Macro** (ver abajo) |
| **M4** | **Mission Control** | **Special Keys** → sección *Mac* → `MCtrl` |
| **M5** | Popup de **sesh** en tmux (`Ctrl-a` `T`) | **Macro** (ver abajo) |
| Resto | Numpad clásico | sin tocar |

`M1` y `M2` mandan `F13`/`F14`, que **skhd** traduce a "abrir la app"
(ver `../skhd/skhdrc`). `M4` es una tecla **nativa de macOS**: no necesita skhd.

## Receta paso a paso

1. Conectá el numpad **por cable USB**.
2. Abrí <https://launcher.keychron.com> en **Chrome** → **Connect** → elegí el
   **K0 Max** en el diálogo del navegador.
3. Andá a **Keymap** (menú izquierdo). Vas a ver el mapa del teclado arriba y las
   pestañas `Basic | Media | Macro | Special Keys | Lighting | Custom | Layer`.
   > Si dice *"the keyboard map cannot be displayed because the browser window is
   > too small"*, agrandá la ventana del navegador.
4. Para cada tecla: **clic en la tecla del mapa** → **clic en la pestaña** que
   corresponda → **clic en el keycode**. Se aplica al instante (no hay "guardar").

   - **M1** → pestaña *Special Keys* → `F13`
   - **M2** → pestaña *Special Keys* → `F14`
   - **M4** → pestaña *Special Keys*, sección **Mac** → `MCtrl`
   - **Knob**: clic en el knob del mapa → pestaña *Media* → `Volume Up` /
     `Volume Down` según el sentido de giro, y `Play/Pause` para el push.

5. **Macros** (para M3 y M5): andá a **Macro** en el menú izquierdo, definí:
   - `Macro 0` = `Cmd` + `Space`  → Spotlight
   - `Macro 1` = `Ctrl` + `A`, después `T` → popup de sesh en tmux

   Después volvé a **Keymap** → clic en **M3** → pestaña *Macro* → `M0`;
   clic en **M5** → pestaña *Macro* → `M1`.

> Las macros de tmux solo tienen efecto con iTerm en foco.

## Backup del keymap

El keymap se guarda en la **memoria del teclado**: se configura **una sola vez**
y viaja con el teclado a cualquier computadora.

Si tu versión del Launcher ofrece exportar/guardar el layout a un archivo,
guardalo acá como `k0max-keymap.json` y commitealo — es el backup ante un reset.
En Launcher **v1.4.1** no encontramos esa opción en los menús; si no aparece, la
receta de arriba **es** la fuente de verdad para reconstruirlo.

## Setup de skhd (una vez por máquina)

Necesario solo para `M1`/`M2` (abrir iTerm y Zen):

```bash
brew trust koekeishiya/formulae   # una vez: Homebrew bloquea taps de terceros
brew bundle install               # instala skhd
python3 install.py                # symlink de skhdrc
skhd --start-service              # pide permiso de Accesibilidad
```

Sin el `brew trust`, `brew bundle` falla con
*"Refusing to load formula ... from untrusted tap"*.

Si tras conceder el permiso no responde: `skhd --restart-service`.
