# CS2 Config Installer
# Run: irm https://cdn.jsdelivr.net/gh/erel3/cs2-config@main/setup.ps1 | iex
#
# Tries multiple public GitHub mirrors in order — the first one the network
# allows wins. All are free auto-proxies of the same public repo; no deploy
# step on our side. jsDelivr can cache ~10 min after each push.
# File list AND autoexec composition driven by cfg/manifest.txt.
# Adding a new cfg = 1 line in manifest, no script edits anywhere.

$hosts = @(
    "https://cdn.jsdelivr.net/gh/erel3/cs2-config@main",
    "https://cdn.statically.io/gh/erel3/cs2-config@main",
    "https://raw.githubusercontent.com/erel3/cs2-config/main",
    "https://rawcdn.githack.com/erel3/cs2-config/main"
)

function Fetch-File($path, $dest) {
    foreach ($h in $hosts) {
        try {
            Invoke-WebRequest "$h/$path" -OutFile $dest -UseBasicParsing -ErrorAction Stop
            return $h
        } catch { continue }
    }
    return $null
}

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

# Download manifest first — drives file list and autoexec
Write-Host "`nFetching manifest..." -ForegroundColor Cyan
$manifestPath = "$gameCfgDir\manifest.txt"
$mh = Fetch-File "cfg/manifest.txt" $manifestPath
if (-not $mh) {
    Write-Host "ERROR: cfg/manifest.txt unreachable on every mirror." -ForegroundColor Red
    Read-Host "Press Enter to close"
    return
}

# Parse manifest into entry objects (skip blanks and #-comments)
$entries = Get-Content $manifestPath | ForEach-Object {
    $line = $_.Trim()
    if (-not $line -or $line.StartsWith("#")) { return $null }
    $parts = $line -split '\|', 3
    [PSCustomObject]@{
        File   = $parts[0].Trim()
        Kind   = if ($parts.Count -ge 2 -and $parts[1].Trim()) { $parts[1].Trim() } else { "always" }
        Prompt = if ($parts.Count -ge 3) { $parts[2].Trim() } else { "" }
    }
} | Where-Object { $_ }

Write-Host "`nDownloading $($entries.Count) configs to $gameCfgDir" -ForegroundColor Cyan
$failed = 0
$usedHost = $null
foreach ($e in $entries) {
    Write-Host "  $($e.File)..." -NoNewline
    $h = Fetch-File "cfg/$($e.File)" "$gameCfgDir\$($e.File)"
    if ($h) {
        Write-Host " OK" -ForegroundColor Green
        if (-not $usedHost) { $usedHost = $h }
    } else {
        Write-Host " FAILED on all mirrors" -ForegroundColor Red
        $failed++
    }
}
if ($usedHost) {
    Write-Host "`nFirst-reachable mirror: $usedHost" -ForegroundColor Cyan
}
if ($failed -gt 0) {
    Write-Host "`n$failed file(s) failed on ALL mirrors — every GitHub proxy was blocked." -ForegroundColor Yellow
    Write-Host "Try a mobile hotspot and re-run, or use Method 4 (zip + install.bat) from the README." -ForegroundColor Yellow
}

# Build autoexec.cfg from manifest (always = unconditional, prompt = ask, extra = skip)
Write-Host ""
$lines = @("// === CS2 CONFIG by erel3 ===")
foreach ($e in $entries) {
    $base = [System.IO.Path]::GetFileNameWithoutExtension($e.File)
    switch ($e.Kind) {
        "always" { $lines += "exec $base" }
        "prompt" {
            $yn = Read-Host "$($e.Prompt) (Y/n)"
            if ($yn -ne "n") { $lines += "exec $base" }
        }
        "extra"  { }
        default  { $lines += "exec $base" }
    }
}
Set-Content -Path "$gameCfgDir\autoexec.cfg" -Value (($lines -join "`n") + "`n") -NoNewline

Write-Host "`nGenerated autoexec.cfg" -ForegroundColor Green
Write-Host "`nDone! Launch CS2 — settings apply automatically." -ForegroundColor Green
Write-Host "If autoexec doesn't run, add '+exec autoexec' to CS2 launch options." -ForegroundColor Yellow
Write-Host "For practice mode, type 'exec practice' in console." -ForegroundColor Yellow
Write-Host "For video settings, set them manually in-game (see README)." -ForegroundColor Yellow
