#!/bin/bash
# CS2 Config Installer for macOS (CrossOver)
# Run: curl -sL https://raw.githubusercontent.com/erel3/cs2-config/main/setup-mac.sh | bash

REPO="https://raw.githubusercontent.com/erel3/cs2-config/main"
FILES="autoexec.cfg practice.cfg cs2_video.txt"
BOTTLES_DIR="$HOME/Library/Application Support/CrossOver/Bottles/Steam/drive_c/Program Files (x86)/Steam/userdata"

if [ ! -d "$BOTTLES_DIR" ]; then
    echo "CrossOver Steam bottle not found at: $BOTTLES_DIR"
    exit 1
fi

# Find Steam ID folders
IDS=($(ls "$BOTTLES_DIR" | grep -E '^[0-9]+$'))

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

CFG_DIR="$BOTTLES_DIR/$STEAM_ID/730/local/cfg"
mkdir -p "$CFG_DIR"

echo ""
echo "Installing to: $CFG_DIR"

for file in $FILES; do
    printf "  Downloading %s..." "$file"
    if curl -sL "$REPO/$file" -o "$CFG_DIR/$file"; then
        echo " OK"
    else
        echo " FAILED"
    fi
done

echo ""
echo "Done! Launch CS2 and your settings will apply automatically."
echo "If autoexec doesn't run, add '+exec autoexec' to CS2 launch options."
echo "For practice mode, type 'exec practice' in console."
