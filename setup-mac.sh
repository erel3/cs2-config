#!/bin/bash
# CS2 Config Installer for macOS (CrossOver)
# Run: curl -sL https://raw.githubusercontent.com/erel3/cs2-config/main/setup-mac.sh | bash

REPO="https://raw.githubusercontent.com/erel3/cs2-config/main"
STEAM_ROOT="$HOME/Library/Application Support/CrossOver/Bottles/Steam/drive_c/Program Files (x86)/Steam"
USERDATA_DIR="$STEAM_ROOT/userdata"
GAME_CFG_DIR="$STEAM_ROOT/steamapps/common/Counter-Strike Global Offensive/game/csgo/cfg"

if [ ! -d "$USERDATA_DIR" ]; then
    echo "CrossOver Steam bottle not found."
    exit 1
fi

# cfg files go to game folder (for exec command)
echo ""
echo "Config files -> $GAME_CFG_DIR"
for file in autoexec.cfg practice.cfg; do
    printf "  Downloading %s..." "$file"
    if curl -sL "$REPO/$file" -o "$GAME_CFG_DIR/$file"; then
        echo " OK"
    else
        echo " FAILED"
    fi
done

echo ""
echo "Done! Launch CS2 and your settings will apply automatically."
echo "If autoexec doesn't run, add '+exec autoexec' to CS2 launch options."
echo "For practice mode, type 'exec practice' in console."
echo "For video settings, set them manually in-game (see README)."
