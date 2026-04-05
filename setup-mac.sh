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

# Find Steam ID folders
IDS=($(ls "$USERDATA_DIR" | grep -E '^[0-9]+$'))

if [ ${#IDS[@]} -eq 0 ]; then
    echo "No Steam accounts found."
    exit 1
elif [ ${#IDS[@]} -eq 1 ]; then
    STEAM_ID="${IDS[0]}"
else
    echo "Multiple Steam accounts found:"
    for i in "${!IDS[@]}"; do
        echo "  [$i] ${IDS[$i]}"
    done
    read -p "Select account number: " choice
    STEAM_ID="${IDS[$choice]}"
fi

USER_CFG_DIR="$USERDATA_DIR/$STEAM_ID/730/local/cfg"
mkdir -p "$USER_CFG_DIR"

# cs2_video.txt goes to userdata (read at startup)
echo ""
echo "Video settings -> $USER_CFG_DIR"
printf "  Downloading cs2_video.txt..."
if curl -sL "$REPO/cs2_video.txt" -o "$USER_CFG_DIR/cs2_video.txt"; then
    echo " OK"
else
    echo " FAILED"
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
