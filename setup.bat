@echo off
chcp 65001 >nul 2>&1
title CS2 Config Installer

:: jsDelivr CDN mirror of GitHub — different infra, bypasses regional blocks
:: on raw.githubusercontent.com (e.g. some KZ PC club networks).
set "REPO=https://cdn.jsdelivr.net/gh/erel3/cs2-config@main"

:: Find Steam path via registry
set "STEAM="
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Valve\Steam" /v InstallPath 2^>nul') do set "STEAM=%%b"

:: Fallback to common paths
if defined STEAM goto :found
for %%p in (
    "%ProgramFiles%\Steam"
    "%ProgramFiles(x86)%\Steam"
    "C:\Steam" "D:\Steam" "E:\Steam"
    "C:\Games\Steam" "D:\Games\Steam"
    "C:\SteamLibrary" "D:\SteamLibrary" "E:\SteamLibrary"
) do (
    if exist "%%~p\steamapps" (
        set "STEAM=%%~p"
        goto :found
    )
)

echo Steam not found. Enter Steam path:
set /p "STEAM="

:found
setlocal EnableDelayedExpansion
set "CFG="
:: First check main Steam install
if exist "%STEAM%\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg" (
    set "CFG=%STEAM%\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg"
)
:: Parse libraryfolders.vdf — tokens=4 splits on quotes: ""path"<tabs>"PATH_HERE"" → token 4 = PATH_HERE
if not defined CFG if exist "%STEAM%\steamapps\libraryfolders.vdf" (
    for /f "usebackq tokens=4 delims=^"" %%L in (`findstr /c:"\"path\"" "%STEAM%\steamapps\libraryfolders.vdf"`) do (
        set "LIB=%%L"
        set "LIB=!LIB:\\=\!"
        if exist "!LIB!\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg" (
            if not defined CFG set "CFG=!LIB!\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg"
        )
    )
)

if not defined CFG (
    echo.
    echo ERROR: CS2 not found in any Steam library.
    echo Steam path: %STEAM%
    echo Check Steam ^> Settings ^> Storage to see where CS2 is installed.
    pause
    exit /b 1
)
echo Found CS2: %CFG%

echo.
echo Downloading configs to %CFG%

:: Download all files using curl (built into Windows 10+).
:: -f fails hard on HTTP errors, --retry handles flaky DNS / transient drops.
set "DL_FAIL=0"
for %%f in (base.cfg binds.cfg crosshair.cfg viewmodel.cfg mouse.cfg practice.cfg practice_off.cfg) do (
    echo   %%f...
    curl -fL --retry 2 "%REPO%/cfg/%%f" -o "%CFG%\%%f" || set "DL_FAIL=1"
)
if "%DL_FAIL%"=="1" (
    echo.
    echo One or more downloads failed. If this is a PC club / region-blocked network,
    echo try a mobile hotspot and re-run, or use Method 4 ^(zip + install.bat^) from the README.
    pause
    exit /b 1
)

:: Ask which modules to include
echo.
set "B=1" & set "C=1" & set "V=1" & set "M=1"

set /p "YN=Install keybinds? (Y/n) "
if /i "%YN%"=="n" set "B=0"

set /p "YN=Install crosshair settings? (Y/n) "
if /i "%YN%"=="n" set "C=0"

set /p "YN=Install viewmodel settings? (Y/n) "
if /i "%YN%"=="n" set "V=0"

set /p "YN=Install mouse sensitivity? (Y/n) "
if /i "%YN%"=="n" set "M=0"

:: Build autoexec.cfg
(
    echo // === CS2 CONFIG by erel3 ===
    echo exec base
    if "%B%"=="1" echo exec binds
    if "%C%"=="1" echo exec crosshair
    if "%V%"=="1" echo exec viewmodel
    if "%M%"=="1" echo exec mouse
) > "%CFG%\autoexec.cfg"

echo.
echo Done! Launch CS2 — settings apply automatically.
echo If autoexec doesn't run, add '+exec autoexec' to CS2 launch options.
echo For practice mode, type 'exec practice' in console.
pause
