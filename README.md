# ps5-backport-docker

Unraid-Container fuer [PS5 Backport GUI](https://github.com/kerrdec97/PS5-Backport-GUI) (Deckerr97) unter Wine, bedienbar im Browser ueber noVNC. Basis: [jlesage/baseimage-gui](https://github.com/jlesage/docker-baseimage-gui) `debian-13-v4`.

## Lizenz der App

PS5 Backport GUI ist proprietaer (nur private, nicht-kommerzielle Nutzung, keine Weitergabe). Dieses Image enthaelt die App deshalb **nicht**. `startapp.sh` laedt `PS5BackportGUI.exe` beim Start aus dem offiziellen Release und prueft sie gegen `SHA256SUMS.txt`. Dieses Repo selbst steht nur fuer die Container-Huelle.

## Installation (Unraid)

Template nach `/boot/config/plugins/dockerMan/templates-user/` kopieren:

```bash
curl -fsSL https://raw.githubusercontent.com/cosmicflow2512/ps5-backport-docker/main/unraid/ps5-backport.xml \
  -o /boot/config/plugins/dockerMan/templates-user/my-ps5-backport.xml
```

Dann Docker → Add Container → Template `ps5-backport` waehlen.

## Pfade

| Container | Standard (Host) | Inhalt |
|---|---|---|
| `/config` | `/mnt/cache/appdata/ps5-backport` | Wine-Prefix, EXE, Settings, Logs |
| `/data` | `/mnt/cache_backup/NZB/` | entpackte Spiele + Ausgabe |

In der App (Wine bildet `/` als `Z:` ab):

- Add folders: `Z:\data\<Ordner mit entpackten Spielen>`
- Backport ZIPs: `Z:\data\ps5-backport\zips`
- Originals backup ZIPs: `Z:\data\ps5-backport\originals`

## Variablen

| Variable | Standard | Zweck |
|---|---|---|
| `AUTO_UPDATE` | `1` | bei jedem Start neue EXE laden, wenn sich der Hash geaendert hat |
| `RELEASE_TAG` | leer (= beim Image-Build ermittelter Upstream-Tag) | Release-Tag im Upstream-Repo fest vorgeben |
| `OUTPUT_SUBDIR` | `ps5-backport` | Unterordner unter `/data` |
| `WINEDEBUG` | `-all` | `err+all` fuer Fehlersuche |

Alle weiteren Variablen (`USER_ID`, `GROUP_ID`, `DARK_MODE`, `KEEP_APP_RUNNING`, ...) siehe jlesage-Doku.

## Status

Ob die EXE unter Wine (Debian 13) vollstaendig laeuft, ist ungetestet. Fehler stehen im Container-Log.

## Upstream-Updates

`.github/workflows/check-upstream.yml` prueft stuendlich das neueste Release von kerrdec97/PS5-Backport-GUI (nach Veroeffentlichungsdatum, egal ob Release, Pre-Release, Alpha, Beta oder Testing-Build). Der EXE-Name darf versioniert sein (`PS5BackportGUI-<version>.exe`); er wird aus `SHA256SUMS.txt` gelesen. Aendert sich Tag oder Hash der EXE, wird `upstream.env` aktualisiert und das Image neu gebaut. Unraid zeigt dann ein Update an; nach dem Update laedt der Container beim Start die neue EXE. Die EXE selbst ist nie im Image.
