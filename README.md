# CS2 Config

Portable CS2 configuration for quick setup at computer clubs.

## Quick Setup (Windows — pick whichever works)

Try methods top to bottom. If one fails, move to the next.

### Method 1: PowerShell (fastest)

Paste into PowerShell:
```powershell
irm https://cdn.jsdelivr.net/gh/erel3/cs2-config@main/setup.ps1 | iex
```
Pipes script into memory — no `.ps1` file on disk, so ExecutionPolicy doesn't apply. Uses jsDelivr CDN mirror of GitHub — routes around regional blocks on `raw.githubusercontent.com` (e.g. some KZ PC club networks).

### Method 2: cmd.exe + batch file

If PowerShell is blocked entirely, paste into **cmd.exe**:
```cmd
curl -fL --retry 2 https://cdn.statically.io/gh/erel3/cs2-config@main/setup.bat -o %TEMP%\cs2.bat && %TEMP%\cs2.bat
```
Uses only `curl.exe` (built into Windows 10+) + batch. No PowerShell needed. Served via statically.io because jsDelivr refuses `.bat` (it strips Windows executable extensions as a safety measure); the downloaded `.bat` itself then fetches all configs via jsDelivr. The script pauses on error so you can read the message if something fails.

### Method 3: cmd.exe one-liner (no prompts, installs everything)

Absolute fallback — downloads all files and creates autoexec with all modules:
```cmd
for %f in (base.cfg binds.cfg crosshair.cfg viewmodel.cfg mouse.cfg practice.cfg practice_off.cfg) do curl -fL --retry 2 https://cdn.jsdelivr.net/gh/erel3/cs2-config@main/cfg/%f -o "%ProgramFiles(x86)%\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg\%f"
(echo // === CS2 CONFIG by erel3 === & echo exec base & echo exec binds & echo exec crosshair & echo exec viewmodel & echo exec mouse) > "%ProgramFiles(x86)%\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg\autoexec.cfg"
```
> **Note:** If Steam is not in `Program Files (x86)`, replace the path. Check Steam → Settings → Storage for the actual path.

### Method 4: Download ZIP + auto-install

1. Download [github.com/erel3/cs2-config](https://github.com/erel3/cs2-config) → Code → Download ZIP
2. Extract anywhere
3. Double-click `install.bat` — finds Steam automatically, copies files, asks which modules to install

No internet needed after download. No PowerShell, no curl.

### Method 5: Fully manual

1. Download ZIP (same as above)
2. Copy **everything inside `cfg/`** into `...\Counter-Strike Global Offensive\game\csgo\cfg\` — one folder, all files (`autoexec.cfg` is included, no need to create it by hand)
3. If autoexec doesn't run, add `+exec autoexec` to CS2 launch options

### macOS (CrossOver)

```bash
bash <(curl -fsL --retry 2 https://cdn.jsdelivr.net/gh/erel3/cs2-config@main/setup-mac.sh)
```

All methods ask which optional modules to include (keybinds, crosshair, viewmodel, mouse). Base settings are always installed. Methods 3-4 install everything.

## What's Changed

### Base (always installed)

**Keybinds reset** — `base.cfg` starts with `unbindall` and then restores all **pure CS2 defaults** (from `user_keys_default.vcfg`). This wipes any leftover binds from previous users/sessions. Customizations live only in `binds.cfg`.

**Audio** — Crisp EQ, all music disabled (except 10-sec bomb warning at ~35% — cvar is `0.1225` because the in-game slider uses a square-root scale), lower audio latency, MVP music muted when players alive.

**Team info** — teammate data always visible through walls (`cl_teamid_overhead_mode 3`): pips + names + health + equipment.

**Radar** — zoomed out (0.25), no rotation, not centered. `N` toggles between overview and zoomed+rotating mode.

**Visibility** — no first-person bullet tracers, teammate loadouts visible through walls, right-hand viewmodel.

**Performance** — FPS cap 400 (200 in menus), low latency mode, instant alt-tab return, no glass/vent debris, facial animations off.

**HUD/Game** — teammate colors, no tutorial hints, no silencer detach, instant grenade lineup reticle, no damage prediction effects, **FPS-only telemetry** (ping/network indicators disabled), hide enemy name under crosshair.

### Keybinds (optional — `binds.cfg`)

Overrides applied on top of the restored defaults.

| Key | Action |
|-----|--------|
| `Z / X / C / V` | Flash / Smoke / HE / Molotov |
| `4` | Decoy |
| `Q` | Quick switch (AWP no-rescope) |
| `Mwheeldown` | Jump (bhop) |
| `CapsLock` | Drop bomb (switch to C4, drop, switch back) |
| `/` | Toggle mute all incoming voice (audio feedback) |
| `Backspace` | Clutch mode (mutes voice + distracting sounds until round end / death) |
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
| `I` / `O` | Add T / CT bot at crosshair (use this to "respawn" a bot where one died — aim at the spot, press the key) |
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
-tickrate 128 -high -nojoy -language english
```

`-tickrate 128` forces 128 tick on local practice servers (MM/Faceit set server-side — this flag only affects offline bots). `-high` sets process priority. `-nojoy` skips controller init (faster startup). `-language english` forces English UI (useful in PC clubs with foreign Steam accounts). Syncs via Steam account.

## Notes

- **autoexec.cfg** runs automatically on game start. If it doesn't, add `+exec autoexec` to CS2 launch options.
- Re-run the setup script anytime to update — it overwrites previous files.
- Video settings sync via Steam Cloud across PCs.
- Voice push-to-talk: default is `MOUSE4`. If you prefer `MOUSE5` or another key, set it via in-game Settings → Keyboard/Mouse (Steam Cloud syncs it). `unbindall` in base.cfg would wipe any menu-level override, so re-apply after running the setup.
