#!/bin/bash
# CS2 Config Installer for macOS (CrossOver)
# Run: curl -fsL https://cdn.jsdelivr.net/gh/erel3/cs2-config@main/setup-mac.sh | bash
#
# Tries multiple public GitHub mirrors in order per file — first-reachable wins.
# All free auto-proxies of the public repo; no deploy step on our side.
# File list AND autoexec composition are driven by cfg/manifest.txt.
# Adding a new cfg = 1 line in manifest, no script edits anywhere.

HOSTS=(
  "https://cdn.jsdelivr.net/gh/erel3/cs2-config@main"
  "https://cdn.statically.io/gh/erel3/cs2-config@main"
  "https://raw.githubusercontent.com/erel3/cs2-config/main"
  "https://rawcdn.githack.com/erel3/cs2-config/main"
)

fetch() {
  # $1 = relative path, $2 = destination
  local path=$1 dest=$2 h
  for h in "${HOSTS[@]}"; do
    if curl -fsL --retry 2 "$h/$path" -o "$dest"; then
      echo "$h"
      return 0
    fi
  done
  return 1
}

STEAM_ROOT="$HOME/Library/Application Support/CrossOver/Bottles/Steam/drive_c/Program Files (x86)/Steam"
GAME_CFG_DIR="$STEAM_ROOT/steamapps/common/Counter-Strike Global Offensive/game/csgo/cfg"

if [ ! -d "$GAME_CFG_DIR" ]; then
    echo "CS2 game folder not found. Is it installed in CrossOver?"
    exit 1
fi

# Download manifest first — drives the file list AND autoexec composition
MANIFEST="$GAME_CFG_DIR/manifest.txt"
echo ""
echo "Fetching manifest..."
if ! fetch "cfg/manifest.txt" "$MANIFEST" >/dev/null; then
    echo "ERROR: cfg/manifest.txt unreachable on every mirror."
    exit 1
fi

# Parse manifest into parallel arrays (bash 3.2 compatible)
NAMES=(); KINDS=(); PROMPTS=()
while IFS='|' read -r fname kind prompt || [ -n "$fname" ]; do
    case "$fname" in ''|\#*) continue ;; esac
    NAMES+=("$fname")
    KINDS+=("${kind:-always}")
    PROMPTS+=("$prompt")
done < "$MANIFEST"

echo ""
echo "Downloading ${#NAMES[@]} configs to $GAME_CFG_DIR"
USED=""
FAILED=0
for file in "${NAMES[@]}"; do
    printf "  %s..." "$file"
    if h=$(fetch "cfg/$file" "$GAME_CFG_DIR/$file"); then
        echo " OK"
        [ -z "$USED" ] && USED="$h"
    else
        echo " FAILED on all mirrors"
        FAILED=$((FAILED + 1))
    fi
done
[ -n "$USED" ] && echo "First-reachable mirror: $USED"
if [ "$FAILED" -gt 0 ]; then
    echo ""
    echo "$FAILED file(s) failed on ALL mirrors — every GitHub proxy blocked."
    echo "Try a different network, or download the ZIP and run install.bat offline."
fi

# Build autoexec.cfg: iterate manifest entries in order, emit `exec NAME` per kind
echo ""
AUTOEXEC="$GAME_CFG_DIR/autoexec.cfg"
echo "// === CS2 CONFIG by erel3 ===" > "$AUTOEXEC"
i=0
while [ $i -lt ${#NAMES[@]} ]; do
    fname=${NAMES[$i]}
    kind=${KINDS[$i]}
    prompt=${PROMPTS[$i]}
    base=${fname%.cfg}
    case "$kind" in
        always)
            echo "exec $base" >> "$AUTOEXEC" ;;
        prompt)
            read -p "$prompt (Y/n) " yn
            [ "$yn" != "n" ] && echo "exec $base" >> "$AUTOEXEC" ;;
        extra)
            : ;;
    esac
    i=$((i + 1))
done

echo ""
echo "Generated autoexec.cfg"
echo ""
echo "Done! Launch CS2 — settings apply automatically."
echo "If autoexec doesn't run, add '+exec autoexec' to CS2 launch options."
echo "For practice mode, type 'exec practice' in console."
echo "For video settings, set them manually in-game (see README)."
