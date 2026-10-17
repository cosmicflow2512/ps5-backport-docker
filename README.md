# ps5-backport-docker

Unraid-Container fuer [PS5 Backport GUI](https://github.com/kerrdec97/PS5-Backport-GUI) (Deckerr97) unter Wine, bedienbar im Browser ueber noVNC. Basis: [jlesage/baseimage-gui](https://github.com/jlesage/docker-baseimage-gui) `debian-12-v4`.

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
| `RELEASE_TAG` | `early-testing-beta` | Release-Tag im Upstream-Repo |
| `OUTPUT_SUBDIR` | `ps5-backport` | Unterordner unter `/data` |
| `WINEDEBUG` | `-all` | `err+all` fuer Fehlersuche |

Alle weiteren Variablen (`USER_ID`, `GROUP_ID`, `DARK_MODE`, `KEEP_APP_RUNNING`, ...) siehe jlesage-Doku.

## Status

Ob die EXE unter Wine (Debian 12, Wine 8.0) vollstaendig laeuft, ist ungetestet. Fehler stehen im Container-Log.
