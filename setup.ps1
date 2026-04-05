# CS2 Config Installer
# Run: irm https://raw.githubusercontent.com/erel3/cs2-config/main/setup.ps1 | iex

$repo = "https://raw.githubusercontent.com/erel3/cs2-config/main"

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
    Write-Host "Steam not found. Enter Steam path manually:" -ForegroundColor Yellow
    $steamPath = Read-Host
    if (-not (Test-Path "$steamPath\steamapps")) {
        Write-Host "Invalid path. Exiting." -ForegroundColor Red
        exit 1
    }
}

$gameCfgDir = "$steamPath\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg"

if (-not (Test-Path $gameCfgDir)) {
    Write-Host "`nGame cfg folder not found: $gameCfgDir" -ForegroundColor Red
    Write-Host "Is CS2 installed?" -ForegroundColor Yellow
    exit 1
}

# Download all cfg modules
$allFiles = @("cfg/base.cfg", "cfg/binds.cfg", "cfg/crosshair.cfg", "cfg/viewmodel.cfg", "cfg/mouse.cfg", "practice.cfg")
Write-Host "`nDownloading configs to $gameCfgDir" -ForegroundColor Cyan
foreach ($file in $allFiles) {
    $outName = $file -replace "cfg/", ""
    Write-Host "  $outName..." -NoNewline
    try {
        Invoke-WebRequest "$repo/$file" -OutFile "$gameCfgDir\$outName" -UseBasicParsing
        Write-Host " OK" -ForegroundColor Green
    } catch {
        Write-Host " FAILED" -ForegroundColor Red
    }
}

# Ask which optional modules to include
Write-Host ""
$modules = @("base", "binds")

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
