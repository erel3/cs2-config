# CS2 Config

Portable CS2 configuration for quick setup at computer clubs.

## What's Inside

| File | What it does | Where to put it |
|------|-------------|-----------------|
| `autoexec.cfg` | Sensitivity, crosshair, keybinds, audio, HUD, radar | `Steam/userdata/<ID>/730/local/cfg/` |
| `practice.cfg` | Grenade training mode (infinite ammo, trajectories, etc.) | Same folder |
| `cs2_video.txt` | Video settings (resolution, MSAA, shadows, textures) | Same folder |
| `setup.ps1` | Auto-installs configs (Windows) | Run from PowerShell |
| `setup-mac.sh` | Auto-installs configs (macOS/CrossOver) | Run from Terminal |

## Quick Setup (Computer Club)

### Option A: Script (recommended)

**Windows** (computer club):
```powershell
irm https://raw.githubusercontent.com/erel3/cs2-config/main/setup.ps1 | iex
```

**macOS** (CrossOver):
```bash
curl -sL https://raw.githubusercontent.com/erel3/cs2-config/main/setup-mac.sh | bash
```

### Option B: Manual

1. Find your Steam ID folder: `C:\Program Files (x86)\Steam\userdata\<YOUR_STEAM_ID>\730\local\cfg\`
2. Copy `autoexec.cfg` and `cs2_video.txt` into that folder
3. Launch CS2 — video settings apply automatically
4. If `autoexec.cfg` didn't run, type `exec autoexec` in console

### Option C: Console paste

1. Open any `.cfg` file raw on GitHub
2. Copy all text
3. Paste into CS2 console

## Practice Mode

### Creating a practice match

1. Play → Practice → Casual
2. Pick a map, click Go
3. Invite friends via Steam overlay (Shift+Tab) or lobby
4. Open console (`~`)

### Loading practice config

```
exec practice
```

### What it gives you

- Infinite grenades + trajectory preview
- Bullet impact markers (10 sec)
- Auto-respawn on death
- Noclip on `L`, god mode
- X-ray player outlines
- Buy anywhere, unlimited money
- Rethrow last grenade on `K`
- Restart round on `J`

## Launch Options

Stored in Steam account (synced automatically). Set in Steam → CS2 → Properties → Launch Options:

```
-novid -tickrate 128 -high
```

## Notes

- **Steam Cloud** may overwrite `cs2_video.txt` on sync. Disable it for CS2: Steam → CS2 → Properties → General → uncheck Steam Cloud.
- **autoexec.cfg** runs automatically on game start. If it doesn't, add `+exec autoexec` to CS2 launch options.
- Video settings (`cs2_video.txt`) are read at startup — changes require game restart.
- Console commands in `.cfg` files apply instantly, no restart needed.
