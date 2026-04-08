# CS2 Config

Portable CS2 configuration for quick setup at computer clubs.

## Quick Setup

### Script (recommended)

**Windows** (computer club) — paste into PowerShell:
```powershell
irm https://raw.githubusercontent.com/erel3/cs2-config/main/setup.ps1 | iex
```

This pipes the script into memory without writing a `.ps1` file, so PowerShell execution policy doesn't apply.

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

1. Copy all files from `cfg/`, `practice.cfg`, and `practice_off.cfg` into `...\Counter-Strike Global Offensive\game\csgo\cfg\`
2. Create `autoexec.cfg` with `exec base`, `exec binds`, `exec crosshair`, `exec viewmodel`, `exec mouse`
3. If autoexec doesn't run, add `+exec autoexec` to CS2 launch options

## What's Changed

### Base (always installed)

**Keybinds reset** — `base.cfg` starts with `unbindall` and then restores all **pure CS2 defaults** (from `user_keys_default.vcfg`). This wipes any leftover binds from previous users/sessions. Customizations live only in `binds.cfg`.

**Audio** — Crisp EQ, all music disabled (except 10-sec bomb warning at ~35% — cvar is `0.1225` because the in-game slider uses a square-root scale), lower audio latency, MVP music muted when players alive.

**Team info** — teammate data always visible through walls (`cl_teamid_overhead_mode 3`, `cl_teamid_overhead_always 1`): pips + names + health + equipment.

**Radar** — zoomed out (0.33), no rotation, not centered. `N` toggles between overview and zoomed+rotating mode. Square radar on scoreboard.

**Visibility** — no first-person bullet tracers, teammate loadouts visible through walls, right-hand viewmodel.

**Performance** — FPS cap 400 (200 in menus), low latency mode, instant alt-tab return, no glass/vent debris, facial animations off.

**HUD/Game** — teammate colors, no tutorial hints, no silencer detach, instant grenade lineup reticle, no damage prediction effects, **FPS-only telemetry** (ping/network indicators disabled), hide enemy name under crosshair, round-end damage printout on screen.

### Keybinds (optional — `binds.cfg`)

Overrides applied on top of the restored defaults.

| Key | Action |
|-----|--------|
| `Z / X / C / V` | Flash / Smoke / HE / Molotov |
| `4` | Decoy |
| `Q` | Quick switch (AWP no-rescope) |
| `Mwheeldown` | Jump (bhop) |
| `Left Alt` | Drop bomb (switch to C4, drop, switch back) |
| `/` | Toggle mute all except friends/party |
| `,` `.` | Bot hold position / follow |
| `N` | Radar zoom toggle (defined in base.cfg) |

**Unbound** (freed for other uses): `i`, `h`, `MWHEELUP`, `6`, `7`, `8`, `9`.

### Crosshair (optional)

Static, small (size 1), center dot, teal color (27/195/144), no outline, no recoil follow, 250 alpha.

### Viewmodel (optional)

m0NESY preset — FOV 68, offset 2.5/0/-1.5. Max FOV, weapon pushed right and slightly down.

### Mouse (optional)

Sensitivity **1.00** @ 1600 DPI (eDPI 1600), zoom sensitivity 1.0.

## Practice Mode

1. Play → Practice → Casual → pick map → Go
2. Open console (`~`), type `exec practice`
3. When done, type `exec practice_off` — resets bot state, cheats, timescale, xray, and unbinds practice keys (otherwise `bot_stop 1` will freeze bots on other maps like aimrush)

Gives you: infinite grenades + full kit on spawn, trajectory preview, auto-respawn, god mode, x-ray, buy anywhere, unlimited money, random spawns, frozen bots.

| Key | Action |
|-----|--------|
| `'` | Restart round (random spawn) |
| `J` | Clear all grenades/fire |
| `K` | Rethrow last grenade |
| `L` | Noclip (fly through walls) |
| `I` / `O` | Add T / CT bot at crosshair |
| `P` | Kick all bots |
| `[` `]` | Toggle bots freeze/move, crouch/stand |
| `=` | Toggle debug info (pos, impacts, penetration) |
| `H` | Slow-mo toggle (1x ↔ 0.25x) |
| `-` | No-spread toggle |

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
- Voice push-to-talk: default is `MOUSE4`. If you prefer `MOUSE5` or another key, set it via in-game Settings → Keyboard/Mouse (Steam Cloud syncs it). `unbindall` in base.cfg would wipe any menu-level override, so re-apply after running the setup.
