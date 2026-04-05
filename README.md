# CS2 Config

Portable CS2 configuration for quick setup at computer clubs.

## Quick Setup

### Script (recommended)

**Windows** (computer club):
```powershell
irm https://raw.githubusercontent.com/erel3/cs2-config/main/setup.ps1 -OutFile $env:TEMP\cs2.ps1; & $env:TEMP\cs2.ps1
```

**macOS** (CrossOver):
```bash
bash <(curl -sL https://raw.githubusercontent.com/erel3/cs2-config/main/setup-mac.sh)
```

The script downloads all config files, then asks which modules to include:
- Keybinds (Y/n)
- Crosshair (Y/n)
- Viewmodel (Y/n)
- Mouse sensitivity (Y/n)

Base settings are always installed.

### Manual

1. Copy all files from `cfg/` and `practice.cfg` into `...\Counter-Strike Global Offensive\game\csgo\cfg\`
2. Create `autoexec.cfg` with `exec base`, `exec binds`, etc.
3. If autoexec doesn't run, add `+exec autoexec` to CS2 launch options

## What's Changed

### Base (always installed)

**Audio** — Crisp EQ, all music disabled (except 10-sec bomb warning at 30%), lower audio latency, MVP music muted when players alive.

**Radar** — zoomed out (0.33), no rotation, not centered. `N` toggles between overview and zoomed+rotating mode. Square radar on scoreboard.

**Visibility** — player contrast boost, no first-person bullet tracers, teammate loadouts visible through walls, no ragdolls.

**Performance** — FPS cap 400 (200 in menus), low latency mode, no V-Sync, network rate maxed.

**HUD/Game** — teammate colors, no tutorial hints, no silencer detach, instant grenade lineup reticle, no damage prediction effects, telemetry (FPS always, ping/network if poor).

### Keybinds (optional)

| Key | Action |
|-----|--------|
| `Z/X/C/V` | Flash / Smoke / HE / Molotov |
| `Q` | Quick switch (AWP no-rescope) |
| `Mwheeldown` | Jump (bhop) |
| `/` | Toggle mute all except friends/party |
| `,` `.` | Bot hold position / follow |

### Crosshair (optional)

Static, small (size 1), center dot, teal color (27/195/144), no outline, no recoil follow, 250 alpha.

### Viewmodel (optional)

m0NESY preset — FOV 68, offset 2.5/0/-1.5. Max FOV, weapon pushed right and slightly down.

### Mouse (optional)

Sensitivity 1.16 @ 1600 DPI (eDPI 1856), zoom sensitivity 1.0.

## Practice Mode

1. Play → Practice → Casual → pick map → Go
2. Open console (`~`), type `exec practice`

Gives you: infinite grenades, trajectory preview, bullet impacts, auto-respawn, god mode, x-ray, buy anywhere, unlimited money, random spawns, frozen bots.

| Key | Action |
|-----|--------|
| `'` | Restart round (random spawn) |
| `J` | Clear all grenades/fire |
| `K` | Rethrow last grenade |
| `L` | Noclip (fly through walls) |
| `I/O` | Add T / CT bot at crosshair |
| `P` | Kick all bots |
| `[` `]` | Toggle bots freeze/move, crouch/stand |

## Video Settings (set manually in-game)

Not scripted — set once in Settings → Video, syncs via Steam Cloud.

| Setting | Value | Why |
|---------|-------|-----|
| V-Sync | Off | Less input lag |
| MSAA | 8x (4x on Mac) | Spot enemies easier |
| Shadow Quality | Very High | See enemy shadows around corners |
| Dynamic Shadows | All | Player shadows visible |
| Texture Detail | Medium | No gameplay impact |
| Texture Filtering | Anisotropic 16x | Free FPS, cleaner textures |
| Shader Detail | Low | Big FPS gain |
| Particle Detail | Medium | Higher = thicker smokes (worse) |
| Ambient Occlusion | Disabled | Costs FPS |
| HDR | Performance | Less bloom |

## Launch Options (manual)

Not part of the config — set these yourself once in Steam → right-click CS2 → Properties → Launch Options:

```
-novid -tickrate 128 -high
```

`-novid` skips intro video, `-tickrate 128` forces 128 tick on local servers, `-high` sets process priority. Syncs via Steam account.

## Notes

- **autoexec.cfg** runs automatically on game start. If it doesn't, add `+exec autoexec` to CS2 launch options.
- Re-run the setup script anytime to update — it overwrites previous files.
- Video settings sync via Steam Cloud across PCs.
