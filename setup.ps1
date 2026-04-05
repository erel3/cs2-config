# CS2 Config Installer
# Run: irm https://raw.githubusercontent.com/erel3/cs2-config/main/setup.ps1 | iex

$repo = "https://raw.githubusercontent.com/erel3/cs2-config/main"

# Find Steam path
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

$userCfgDir = "$steamPath\userdata\$userId\730\local\cfg"
$gameCfgDir = "$steamPath\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg"

# cs2_video.txt -> userdata (read at startup)
if (-not (Test-Path $userCfgDir)) {
    New-Item -ItemType Directory -Path $userCfgDir -Force | Out-Null
}

Write-Host "`nVideo settings -> $userCfgDir" -ForegroundColor Cyan
Write-Host "  Downloading cs2_video.txt..." -NoNewline
try {
    Invoke-WebRequest "$repo/cs2_video.txt" -OutFile "$userCfgDir\cs2_video.txt" -UseBasicParsing
    Write-Host " OK" -ForegroundColor Green
} catch {
    Write-Host " FAILED" -ForegroundColor Red
}

# cfg files -> game folder (for exec command)
if (-not (Test-Path $gameCfgDir)) {
    Write-Host "`nGame cfg folder not found: $gameCfgDir" -ForegroundColor Red
    Write-Host "Is CS2 installed?" -ForegroundColor Yellow
    exit 1
}

Write-Host "`nConfig files -> $gameCfgDir" -ForegroundColor Cyan
foreach ($file in @("autoexec.cfg", "practice.cfg")) {
    Write-Host "  Downloading $file..." -NoNewline
    try {
        Invoke-WebRequest "$repo/$file" -OutFile "$gameCfgDir\$file" -UseBasicParsing
        Write-Host " OK" -ForegroundColor Green
    } catch {
        Write-Host " FAILED" -ForegroundColor Red
    }
}

Write-Host "`nDone! Launch CS2 and your settings will apply automatically." -ForegroundColor Green
Write-Host "If autoexec doesn't run, add '+exec autoexec' to CS2 launch options." -ForegroundColor Yellow
Write-Host "For practice mode, type 'exec practice' in console." -ForegroundColor Yellow
