#!/bin/bash
# CS2 Config Installer for macOS (CrossOver)
# Run: curl -sL https://cdn.jsdelivr.net/gh/erel3/cs2-config@main/setup-mac.sh | bash
#
# Uses jsDelivr CDN mirror of GitHub — routes around regional blocks on
# raw.githubusercontent.com. Caches ~10 min after each push.

REPO="https://cdn.jsdelivr.net/gh/erel3/cs2-config@main"
STEAM_ROOT="$HOME/Library/Application Support/CrossOver/Bottles/Steam/drive_c/Program Files (x86)/Steam"
GAME_CFG_DIR="$STEAM_ROOT/steamapps/common/Counter-Strike Global Offensive/game/csgo/cfg"

if [ ! -d "$GAME_CFG_DIR" ]; then
    echo "CS2 game folder not found. Is it installed in CrossOver?"
    exit 1
fi

# Download all cfg modules (all live under cfg/ in the repo)
echo ""
echo "Downloading configs to $GAME_CFG_DIR"
for file in base.cfg binds.cfg crosshair.cfg viewmodel.cfg mouse.cfg practice.cfg practice_off.cfg; do
    printf "  %s..." "$file"
    if curl -fsL --retry 2 "$REPO/cfg/$file" -o "$GAME_CFG_DIR/$file"; then
        echo " OK"
    else
        echo " FAILED"
    fi
done

# Ask which optional modules to include
echo ""
MODULES="exec base"

read -p "Install keybinds? (Y/n) " yn
[ "$yn" != "n" ] && MODULES="$MODULES\nexec binds"

read -p "Install crosshair settings? (Y/n) " yn
[ "$yn" != "n" ] && MODULES="$MODULES\nexec crosshair"

read -p "Install viewmodel settings? (Y/n) " yn
[ "$yn" != "n" ] && MODULES="$MODULES\nexec viewmodel"

read -p "Install mouse sensitivity? (Y/n) " yn
[ "$yn" != "n" ] && MODULES="$MODULES\nexec mouse"

# Build autoexec.cfg
echo -e "// === CS2 CONFIG by erel3 ===\n$MODULES" > "$GAME_CFG_DIR/autoexec.cfg"

echo ""
echo "Generated autoexec.cfg"
echo ""
echo "Done! Launch CS2 — settings apply automatically."
echo "If autoexec doesn't run, add '+exec autoexec' to CS2 launch options."
echo "For practice mode, type 'exec practice' in console."
echo "For video settings, set them manually in-game (see README)."
