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

# EXE-Name aus SHA256SUMS.txt: seit 0.3.3 versioniert (PS5BackportGUI-0.3.3.exe), vorher PS5BackportGUI.exe.
# Lokal wird sie immer als PS5BackportGUI.exe abgelegt, damit Einstellungen/Ledger im selben Ordner bleiben.
LINE=$(grep -iE '^[0-9a-fA-F]{64}[[:space:]]+\*?PS5BackportGUI[^[:space:]/]*\.exe[[:space:]]*$' "$SUMS" | head -n1)
WANT=$(echo "$LINE" | awk '{print tolower($1)}')
NAME=$(echo "$LINE" | awk '{print $2}' | sed 's/^\*//')
case "$WANT" in
  [0-9a-f][0-9a-f][0-9a-f][0-9a-f]*) ;;
  *) echo "FEHLER: keine PS5BackportGUI*.exe mit gueltigem Hash in SHA256SUMS.txt ($TAG):"; cat "$SUMS"; exit 1 ;;
esac
echo "Release $TAG: $NAME $WANT"

HAVE=""
[ -f "$EXE" ] && HAVE=$(sha256sum "$EXE" | awk '{print $1}')

if [ "$HAVE" != "$WANT" ]; then
  echo "Lade $NAME ($BASE) ..."
  curl -fL "$BASE/$NAME" -o "$EXE.new" || { echo "FEHLER: Download fehlgeschlagen"; rm -f "$EXE.new"; exit 1; }
  GOT=$(sha256sum "$EXE.new" | awk '{print $1}')
  if [ "$GOT" != "$WANT" ]; then
    echo "FEHLER: Hash-Mismatch ($GOT != $WANT)"
    rm -f "$EXE.new"
    exit 1
  fi
  mv "$EXE.new" "$EXE"
  echo "$NAME verifiziert: $WANT (gespeichert als PS5BackportGUI.exe)"
fi

cd "$APPDIR" || exit 1
exec wine "$EXE"
