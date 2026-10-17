#!/bin/sh
# Laedt PS5BackportGUI.exe aus dem offiziellen Release, prueft SHA-256 und startet sie unter Wine.
# Die EXE wird bewusst nicht ins Image gepackt (Lizenz verbietet Weitergabe).

APPDIR=/config/app
EXE="$APPDIR/PS5BackportGUI.exe"
SUMS="$APPDIR/SHA256SUMS.txt"
# Release-Tag: Variable RELEASE_TAG, sonst der beim Image-Build ermittelte Upstream-Tag
TAG="${RELEASE_TAG:-$(cat /etc/ps5backport/upstream_tag 2>/dev/null)}"
TAG="${TAG:-early-testing-beta}"
BASE="https://github.com/kerrdec97/PS5-Backport-GUI/releases/download/$TAG"
OUT="/data/${OUTPUT_SUBDIR:-ps5-backport}"

mkdir -p "$APPDIR"
mkdir -p "$OUT/zips" "$OUT/originals" 2>/dev/null || echo "WARN: $OUT nicht beschreibbar"

if [ "${AUTO_UPDATE:-1}" = "1" ]; then
  if curl -fsSL "$BASE/SHA256SUMS.txt" -o "$SUMS.new"; then
    mv "$SUMS.new" "$SUMS"
  else
    echo "WARN: SHA256SUMS.txt nicht erreichbar, nutze vorhandene Version"
    rm -f "$SUMS.new"
  fi
fi

[ -f "$SUMS" ] || { echo "FEHLER: keine SHA256SUMS.txt vorhanden"; exit 1; }

WANT=$(grep -i 'PS5BackportGUI.exe' "$SUMS" | head -n1 | awk '{print tolower($1)}')
case "$WANT" in
  [0-9a-f][0-9a-f][0-9a-f][0-9a-f]*) ;;
  *) echo "FEHLER: kein gueltiger Hash fuer PS5BackportGUI.exe in SHA256SUMS.txt:"; cat "$SUMS"; exit 1 ;;
esac

HAVE=""
[ -f "$EXE" ] && HAVE=$(sha256sum "$EXE" | awk '{print $1}')

if [ "$HAVE" != "$WANT" ]; then
  echo "Lade PS5BackportGUI.exe ($BASE) ..."
  curl -fL "$BASE/PS5BackportGUI.exe" -o "$EXE.new" || { echo "FEHLER: Download fehlgeschlagen"; rm -f "$EXE.new"; exit 1; }
  GOT=$(sha256sum "$EXE.new" | awk '{print $1}')
  if [ "$GOT" != "$WANT" ]; then
    echo "FEHLER: Hash-Mismatch ($GOT != $WANT)"
    rm -f "$EXE.new"
    exit 1
  fi
  mv "$EXE.new" "$EXE"
  echo "PS5BackportGUI.exe verifiziert: $WANT"
fi

cd "$APPDIR" || exit 1
exec wine "$EXE"
