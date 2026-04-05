# CS2 Config Installer
# Run: irm https://raw.githubusercontent.com/erel3/cs2-config/main/setup.ps1 | iex

$repo = "https://raw.githubusercontent.com/erel3/cs2-config/main"
$files = @("autoexec.cfg", "practice.cfg", "cs2_video.txt")

# Find Steam userdata path
$steamPaths = @(
    "$env:ProgramFiles\Steam",
    "${env:ProgramFiles(x86)}\Steam",
    "D:\Steam",
    "E:\Steam",
    "D:\SteamLibrary",
    "E:\SteamLibrary"
)

$steamPath = $null
foreach ($p in $steamPaths) {
    if (Test-Path "$p\userdata") {
        $steamPath = $p
        break
    }
}

if (-not $steamPath) {
    Write-Host "Steam not found. Enter Steam path manually:" -ForegroundColor Yellow
    $steamPath = Read-Host
    if (-not (Test-Path "$steamPath\userdata")) {
        Write-Host "Invalid path. Exiting." -ForegroundColor Red
        exit 1
    }
}

# Find Steam ID folders
$userDirs = Get-ChildItem "$steamPath\userdata" -Directory | Where-Object { $_.Name -match '^\d+$' }

if ($userDirs.Count -eq 0) {
    Write-Host "No Steam accounts found." -ForegroundColor Red
    exit 1
}

if ($userDirs.Count -eq 1) {
    $userId = $userDirs[0].Name
} else {
    Write-Host "Multiple Steam accounts found:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $userDirs.Count; $i++) {
        Write-Host "  [$i] $($userDirs[$i].Name)"
    }
    $choice = Read-Host "Select account number"
    $userId = $userDirs[$choice].Name
}

$cfgDir = "$steamPath\userdata\$userId\730\local\cfg"

if (-not (Test-Path $cfgDir)) {
    New-Item -ItemType Directory -Path $cfgDir -Force | Out-Null
}

Write-Host "`nInstalling to: $cfgDir" -ForegroundColor Cyan

foreach ($file in $files) {
    Write-Host "  Downloading $file..." -NoNewline
    try {
        Invoke-WebRequest "$repo/$file" -OutFile "$cfgDir\$file" -UseBasicParsing
        Write-Host " OK" -ForegroundColor Green
    } catch {
        Write-Host " FAILED" -ForegroundColor Red
    }
}

Write-Host "`nDone! Launch CS2 and your settings will apply automatically." -ForegroundColor Green
Write-Host "If autoexec doesn't run, add '+exec autoexec' to CS2 launch options." -ForegroundColor Yellow
Write-Host "For practice mode, type 'exec practice' in console." -ForegroundColor Yellow
