@echo off
chcp 65001 >nul 2>&1
title CS2 Config Installer

:: Multiple public GitHub mirrors — tried in order per file, first-reachable wins.
:: All are free auto-proxies of the public repo; no deploy step on our side.
:: File list AND autoexec composition driven by cfg/manifest.txt.
:: Adding a new cfg = 1 line in manifest, no script edits anywhere.
set "HOST1=https://cdn.jsdelivr.net/gh/erel3/cs2-config@main"
set "HOST2=https://cdn.statically.io/gh/erel3/cs2-config@main"
set "HOST3=https://raw.githubusercontent.com/erel3/cs2-config/main"
set "HOST4=https://rawcdn.githack.com/erel3/cs2-config/main"

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

:: Download manifest first — drives file list and autoexec
echo.
echo Fetching manifest...
set "MANIFEST_OK="
for %%h in ("!HOST1!" "!HOST2!" "!HOST3!" "!HOST4!") do (
    if not defined MANIFEST_OK (
        curl -fL --retry 2 "%%~h/cfg/manifest.txt" -o "%CFG%\manifest.txt" >nul 2>&1 && set "MANIFEST_OK=%%~h"
    )
)
if not defined MANIFEST_OK (
    echo ERROR: cfg/manifest.txt unreachable on every mirror.
    pause
    exit /b 1
)

echo.
echo Downloading configs to %CFG%

:: Pass 1: download every listed file (eol=# skips comments, blanks auto-skip)
set "DL_FAIL=0"
for /f "usebackq eol=# tokens=1,2,3 delims=|" %%a in ("%CFG%\manifest.txt") do (
    set "OK="
    for %%h in ("!HOST1!" "!HOST2!" "!HOST3!" "!HOST4!") do (
        if not defined OK (
            curl -fL --retry 2 "%%~h/cfg/%%a" -o "%CFG%\%%a" >nul 2>&1 && set "OK=%%~h"
        )
    )
    if defined OK (
        echo   %%a OK ^(!OK!^)
    ) else (
        echo   %%a FAILED on all mirrors
        set "DL_FAIL=1"
    )
)
if "%DL_FAIL%"=="1" (
    echo.
    echo One or more downloads failed on ALL mirrors — every GitHub proxy blocked.
    echo Try a mobile hotspot and re-run, or use Method 4 ^(zip + install.bat^) from the README.
    pause
    exit /b 1
)

:: Pass 2: build autoexec from manifest (always = unconditional, prompt = ask user, extra = skip)
echo.
echo // === CS2 CONFIG by erel3 ===> "%CFG%\autoexec.cfg"
for /f "usebackq eol=# tokens=1,2,3 delims=|" %%a in ("%CFG%\manifest.txt") do (
    set "fname=%%a"
    set "kind=%%b"
    set "ptext=%%c"
    set "base=!fname:.cfg=!"
    if "!kind!"=="always" (
        echo exec !base!>> "%CFG%\autoexec.cfg"
    ) else if "!kind!"=="prompt" (
        set "YN="
        set /p "YN=!ptext! (Y/n) "
        if /i not "!YN!"=="n" echo exec !base!>> "%CFG%\autoexec.cfg"
    )
)

echo.
echo Done! Launch CS2 — settings apply automatically.
echo If autoexec doesn't run, add '+exec autoexec' to CS2 launch options.
echo For practice mode, type 'exec practice' in console.
pause
