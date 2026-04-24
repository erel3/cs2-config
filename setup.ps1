# CS2 Config Installer
# Run: irm https://cdn.jsdelivr.net/gh/erel3/cs2-config@main/setup.ps1 | iex
#
# Uses jsDelivr CDN mirror of GitHub — different infra, routes around regional
# blocks on raw.githubusercontent.com. Caches ~10 min after each push.

$repo = "https://cdn.jsdelivr.net/gh/erel3/cs2-config@main"

# Find Steam path via registry first, then fallback to common paths
$steamPath = $null
$regPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Valve\Steam" -Name "InstallPath" -ErrorAction SilentlyContinue).InstallPath
if ($regPath -and (Test-Path "$regPath\steamapps")) {
    $steamPath = $regPath
}

if (-not $steamPath) {
    foreach ($p in @(
        "$env:ProgramFiles\Steam",
        "${env:ProgramFiles(x86)}\Steam",
        "C:\Steam", "D:\Steam", "E:\Steam",
        "C:\Games\Steam", "D:\Games\Steam",
        "C:\SteamLibrary", "D:\SteamLibrary", "E:\SteamLibrary"
    )) {
        if (Test-Path "$p\steamapps") {
            $steamPath = $p
            break
        }
    }
}

if (-not $steamPath) {
    Write-Host "Steam not found. Enter Steam path manually (e.g. D:\Steam):" -ForegroundColor Yellow
    $steamPath = Read-Host
    if (-not (Test-Path "$steamPath\steamapps")) {
        Write-Host "Invalid path: $steamPath" -ForegroundColor Red
        Read-Host "Press Enter to close"
        return
    }
}
Write-Host "Found Steam: $steamPath" -ForegroundColor Green

# Find CS2 install by scanning all Steam library folders (libraryfolders.vdf)
$gameCfgDir = $null
$libFile = "$steamPath\steamapps\libraryfolders.vdf"
$libraries = @($steamPath)
if (Test-Path $libFile) {
    $libraries += (Select-String -Path $libFile -Pattern '"path"\s+"([^"]+)"' -AllMatches).Matches | ForEach-Object { $_.Groups[1].Value -replace '\\\\', '\' }
}
foreach ($lib in $libraries | Select-Object -Unique) {
    $candidate = "$lib\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg"
    if (Test-Path $candidate) { $gameCfgDir = $candidate; break }
}

if (-not $gameCfgDir) {
    Write-Host "`nCS2 not found in any Steam library. Checked:" -ForegroundColor Red
    $libraries | ForEach-Object { Write-Host "  $_" }
    Read-Host "Press Enter to close"
    return
}
Write-Host "Found CS2: $gameCfgDir" -ForegroundColor Green

# Download all cfg modules (all live under cfg/ in the repo)
$allFiles = @("base.cfg", "binds.cfg", "crosshair.cfg", "viewmodel.cfg", "mouse.cfg", "practice.cfg", "practice_off.cfg")
Write-Host "`nDownloading configs to $gameCfgDir" -ForegroundColor Cyan
$failed = 0
foreach ($file in $allFiles) {
    Write-Host "  $file..." -NoNewline
    try {
        Invoke-WebRequest "$repo/cfg/$file" -OutFile "$gameCfgDir\$file" -UseBasicParsing -ErrorAction Stop
        Write-Host " OK" -ForegroundColor Green
    } catch {
        Write-Host " FAILED ($($_.Exception.Message))" -ForegroundColor Red
        $failed++
    }
}
if ($failed -gt 0) {
    Write-Host "`n$failed download(s) failed. If this is a PC club / region-blocked network," -ForegroundColor Yellow
    Write-Host "try a mobile hotspot and re-run, or use Method 4 (zip + install.bat) from the README." -ForegroundColor Yellow
}

# Ask which optional modules to include
Write-Host ""
$modules = @("base")

$yn = Read-Host "Install keybinds? (Y/n)"
if ($yn -ne "n") { $modules += "binds" }

$yn = Read-Host "Install crosshair settings? (Y/n)"
if ($yn -ne "n") { $modules += "crosshair" }

$yn = Read-Host "Install viewmodel settings? (Y/n)"
if ($yn -ne "n") { $modules += "viewmodel" }

$yn = Read-Host "Install mouse sensitivity? (Y/n)"
if ($yn -ne "n") { $modules += "mouse" }

# Build autoexec.cfg
$autoexec = "// === CS2 CONFIG by erel3 ===`n"
foreach ($m in $modules) {
    $autoexec += "exec $m`n"
}
Set-Content -Path "$gameCfgDir\autoexec.cfg" -Value $autoexec -NoNewline

Write-Host "`nGenerated autoexec.cfg with: $($modules -join ', ')" -ForegroundColor Green
Write-Host "`nDone! Launch CS2 — settings apply automatically." -ForegroundColor Green
Write-Host "If autoexec doesn't run, add '+exec autoexec' to CS2 launch options." -ForegroundColor Yellow
Write-Host "For practice mode, type 'exec practice' in console." -ForegroundColor Yellow
Write-Host "For video settings, set them manually in-game (see README)." -ForegroundColor Yellow
