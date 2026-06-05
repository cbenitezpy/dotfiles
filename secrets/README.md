# Secrets — sops + age

Reemplaza el viejo `source ~/.env` en texto plano por **variables cifradas**
con [sops](https://github.com/getsops/sops) + [age](https://github.com/FiloSottile/age).
El archivo cifrado (`vars.sops.env`) se versiona en el repo sin riesgo; la clave
privada vive **fuera** del repo, en `~/.config/sops/age/keys.txt`.

## Modelo de seguridad (sé consciente de esto)

- **Qué protege:** los secrets quedan cifrados *at rest* en el repo. Podés
  pushear el repo a GitHub sin exponer nada. No hay más texto plano sincronizado
  ni en backups de Time Machine.
- **Qué NO protege:** la carga es automática al abrir el shell, así que la clave
  privada está en disco sin passphrase. Si alguien obtiene lectura de tu `$HOME`,
  puede descifrar. Es un gran salto respecto a `~/.env` plano, pero no es una
  bóveda con biometría. Para endurecer: mover la clave al Keychain o usar passphrase
  (a costa de pedirla en cada shell).

## Setup inicial (en tu Mac, una sola vez)

```bash
cd ~/.dotfiles
brew bundle install                 # instala sops + age

./secrets/manage.sh init-key        # genera la clave age + actualiza .sops.yaml
./secrets/manage.sh migrate         # cifra ~/.env -> secrets/vars.sops.env
./secrets/manage.sh show            # verificá que se ve igual que tu ~/.env

rm ~/.env                           # borrá el plano una vez verificado
exec zsh                            # recargá el shell; las vars deben seguir ahí
```

> Respaldá `~/.config/sops/age/keys.txt` en un lugar seguro. Sin esa clave no
> podés descifrar en otra máquina.

## Uso diario

```bash
./secrets/manage.sh edit    # editar secrets (sops abre $EDITOR, recifra al guardar)
./secrets/manage.sh show    # ver en claro
./secrets/manage.sh rekey   # re-cifrar tras cambiar destinatarios en .sops.yaml
```

## Cómo se cargan

`shell/secrets.zsh` (sourceado desde `.zshrc`) descifra `vars.sops.env` al iniciar
el shell y exporta cada variable. Si falta `sops`, la clave o el archivo, **avisa
por stderr y sigue** — una máquina nueva sin secrets igual arranca con un shell sano.

El parseo es línea por línea con `export` (no `eval`), así que valores con espacios
o caracteres especiales no rompen y un valor tipo `$(...)` queda como literal.

## Archivos

| Archivo | Versionado | Contenido |
|---|---|---|
| `.sops.yaml` | sí | reglas + clave **pública** age |
| `vars.sops.env` | sí | secrets **cifrados** (dotenv) |
| `env.example` | sí | plantilla con claves de ejemplo |
| `manage.sh` | sí | helper de gestión |
| `~/.config/sops/age/keys.txt` | **NO** | clave **privada** age |
