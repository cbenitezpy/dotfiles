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
| **Knob presionar** | Mute (silenciar) | pestaña **Media** — default, se dejó así |
| **M1** | Abrir/enfocar **iTerm** | **Special Keys** → `F13` |
| **M2** | Abrir/enfocar **Zen** | **Special Keys** → `F14` |
| **M3** | **Spotlight** (Cmd+Space) | **Custom** → `Any` → `LGUI(KC_SPC)` |
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

5. **M3 — Spotlight (NO usar macro):**
   clic en **M3** → pestaña **Custom** → botón **`Any`** → escribí
   **`LGUI(KC_SPC)`** → confirmar.

   `LGUI` = Cmd, `KC_SPC` = Space. Manda Cmd+Space como una sola tecla.

6. **M5 — macro de tmux** (esta sí es macro, porque son dos pulsaciones
   seguidas): andá a **Macro** en el menú izquierdo y definí
   `Macro 0` = `Ctrl` + `A`, después `T`.
   Después volvé a **Keymap** → clic en **M5** → pestaña *Macro* → `M0`.

> Las macros de tmux solo tienen efecto con iTerm en foco.

## Problemas conocidos

**El grabador de macros solo captura el modificador (ej. queda solo `L win`).**
Pasa cuando el atajo que intentás grabar ya lo usa macOS: el sistema lo
intercepta antes de que el Launcher lo vea. Es el caso de `Cmd+Space`
(Spotlight).

Regla práctica: para **modificador + tecla** (una sola pulsación) usá
**Custom → `Any`** con el keycode QMK, no el grabador de macros. Ejemplos:

| Querés | Escribí en `Any` |
|---|---|
| Cmd + Space | `LGUI(KC_SPC)` |
| Cmd + Tab | `LGUI(KC_TAB)` |
| Ctrl + A (prefijo tmux) | `LCTL(KC_A)` |

Las macros dejalas solo para **secuencias** de varias pulsaciones.

## Otras teclas útiles que encontramos

En **Custom**: `MCtl` (Mission Control), `LPad` (Launchpad), `SShot`
(screenshot), `Siri`, `Task`, `File`, `BTH1/2/3` y `2.4G` (cambiar de canal
inalámbrico), `Batt` (nivel de batería).

## Backup del keymap

El keymap se guarda en la **memoria del teclado**: se configura **una sola vez**
y viaja con el teclado a cualquier computadora.

El backup son **dos archivos** (el Launcher los exporta por separado):

| Archivo | Contiene |
|---|---|
| `k0max-keymap.json` | keymap de las 4 capas + knob |
| `k0max-macros.json` | definición de las macros |

> ⚠️ Importante: **el keymap NO incluye las macros**. Si restaurás solo el
> keymap, `M5` va a apuntar a `MACRO 1` pero la macro estará vacía. Restaurá
> **ambos** archivos.

### Contenido de las macros

| Slot | Nombre | Secuencia | Para qué |
|---|---|---|---|
| `MACRO 1` | `tmux` | `Ctrl↓ A↓ A↑ Ctrl↑ T↓ T↑` | prefijo tmux (`Ctrl-a`) + `T` = popup de sesh |

### Estado verificado del keymap actual

Decodificado del `k0max-keymap.json`:

| Tecla | Keycode |
|---|---|
| Knob girar | `KC_VOLD` / `KC_VOLU` |
| Knob push | `KC_MUTE` |
| M1 | `KC_F13` → skhd → iTerm |
| M2 | `KC_F14` → skhd → Zen |
| M3 | `LGUI(KC_SPC)` → Spotlight |
| M4 | `KC_MCTL` → Mission Control |
| M5 | `MACRO 1` → sesh en tmux |

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

### skhd no arranca y nunca pide permiso de Accesibilidad

Revisá el log primero:

```bash
tail -5 /tmp/skhd_$USER.err.log
```

Si dice **`secure keyboard entry is enabled by (PID) 'app'! abort..`**, el
problema **no es Accesibilidad**: macOS tiene activo *Secure Keyboard Entry* y
skhd se niega a arrancar (por eso nunca llega a pedir el permiso).

Quién lo tiene activo:

```bash
pid=$(ioreg -l -w 0 | grep -o 'kCGSSessionSecureInputPID"=[0-9]*' | grep -o '[0-9]*$' | head -1)
ps -p $pid -o pid=,args=
```

Causas típicas:

- **Un campo de contraseña con foco** en un navegador (Zen/Firefox/Chrome) o en
  cualquier app. Es transitorio: hacé clic fuera y se libera.
- **iTerm2 con el toggle fijo**: menú *iTerm2* → **Secure Keyboard Entry** debe
  estar destildado. Verificar con:
  `defaults read com.googlecode.iterm2 'Secure Input'`
  (`1` = activado; que no exista = está bien).

Con el Secure Input liberado: `skhd --restart-service`.

#### Caso especial: Secure Input colgado con un PID muerto

Si el PID que aparece **ya no existe** (`ps -p $pid` no devuelve nada), el estado
quedó pegado: la app lo activó y terminó sin liberarlo (bug conocido de macOS).
Ningún programa va a poder leer el teclado global hasta limpiarlo, y **no hay
comando** para forzarlo.

1. Intento rápido: reabrí la app culpable, enfocá un campo de contraseña, clic
   afuera, y cerrala con **Cmd+Q** (cierre limpio).
2. Si sigue: **cerrar sesión y volver a entrar** (menú Apple → Cerrar sesión).
   No hace falta reiniciar.

### Agregar skhd a Accesibilidad a mano

skhd es un binario CLI, **no una `.app`**, así que no aparece solo en la lista.
Ajustes del Sistema → Privacidad y Seguridad → **Accesibilidad** → `+` →
`Cmd+Shift+G` → pegar `/opt/homebrew/bin/skhd` → *Abrir*.

> El binario de Homebrew es un symlink a `Cellar/skhd/<versión>/bin/skhd`, así que
> tras un `brew upgrade skhd` puede hacer falta volver a autorizarlo.
