# CS2 Config

Portable CS2 configuration for quick setup at computer clubs.

## What's Inside

| File | What it does | Where to put it |
|------|-------------|-----------------|
| `autoexec.cfg` | Sensitivity, crosshair, keybinds, audio, HUD, radar | `game/csgo/cfg/` |
| `practice.cfg` | Grenade training mode (infinite ammo, trajectories, etc.) | `game/csgo/cfg/` |
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

1. Find the game cfg folder: `...\Counter-Strike Global Offensive\game\csgo\cfg\`
2. Copy `autoexec.cfg` and `practice.cfg` into that folder
3. Launch CS2
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

Infinite grenades, trajectory preview, bullet impacts (10 sec), auto-respawn, god mode, x-ray outlines, buy anywhere, unlimited money, random spawns, frozen bots.

## Keybinds

### Gameplay (autoexec.cfg)

| Key | Action |
|-----|--------|
| `Z` | Flashbang |
| `X` | Smoke |
| `C` | HE grenade |
| `V` | Molotov/Incendiary |
| `Q` | Quick switch (AWP no-rescope) |
| `Mwheeldown` | Jump (bhop) |
| `N` | Toggle radar (overview / zoomed+rotating) |
| `/` | Toggle mute all except friends/party |
| `,` | Bot: hold position |
| `.` | Bot: follow me |

### Practice mode (practice.cfg)

| Key | Action |
|-----|--------|
| `'` | Restart round (random spawn) |
| `J` | Clear all grenades/fire |
| `K` | Rethrow last grenade |
| `L` | Noclip (fly through walls) |
| `I` | Add T bot at crosshair |
| `O` | Add CT bot at crosshair |
| `P` | Kick all bots |
| `[` | Toggle bots freeze/move |
| `]` | Toggle bots crouch/stand |

## Video Settings (set manually in-game)

Not scripted — set once in Settings → Video, syncs via Steam Cloud.

| Setting | Value | Why |
|---------|-------|-----|
| V-Sync | Off | Less input lag |
| MSAA | 8x (4x on Mac) | Smoother edges, spot enemies easier |
| Shadow Quality | Very High | See enemy shadows around corners |
| Dynamic Shadows | All | Same — player shadows visible |
| Texture Detail | Medium | No gameplay impact, saves VRAM |
| Texture Filtering | Anisotropic 16x | Near-zero FPS cost, cleaner textures |
| Shader Detail | Low | Barely visible, big FPS gain |
| Particle Detail | Medium | Higher = thicker smokes (worse) |
| Ambient Occlusion | Disabled | Just eye candy, costs FPS |
| HDR | Performance | Less bloom, cleaner visibility |

## Launch Options

Stored in Steam account (synced automatically). Set in Steam → CS2 → Properties → Launch Options:

```
-novid -tickrate 128 -high
```

## Notes

- **autoexec.cfg** runs automatically on game start. If it doesn't, add `+exec autoexec` to CS2 launch options.
- Console commands in `.cfg` files apply instantly, no restart needed.
- Video settings are set in-game and sync via Steam Cloud across PCs.
