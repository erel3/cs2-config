@echo off
chcp 65001 >nul 2>&1
title CS2 Config Installer (offline)

:: This script installs configs from the same folder it's in.
:: Download the ZIP, extract, double-click install.bat.
:: File list AND autoexec composition driven by cfg\manifest.txt.
:: Adding a new cfg = 1 line in manifest, no script edits anywhere.

set "HERE=%~dp0"

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
if exist "%STEAM%\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg" (
    set "CFG=%STEAM%\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg"
)
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

if not exist "%HERE%cfg\manifest.txt" (
    echo.
    echo ERROR: %HERE%cfg\manifest.txt missing. Re-extract the zip.
    pause
    exit /b 1
)

echo.
echo Copying configs to %CFG%

:: Copy manifest itself + all listed cfgs (eol=# skips comments)
copy /y "%HERE%cfg\manifest.txt" "%CFG%\manifest.txt" >nul
for /f "usebackq eol=# tokens=1,2,3 delims=|" %%a in ("%HERE%cfg\manifest.txt") do (
    if exist "%HERE%cfg\%%a" (
        copy /y "%HERE%cfg\%%a" "%CFG%\%%a" >nul
        echo   %%a OK
    ) else (
        echo   %%a MISSING in %HERE%cfg\
    )
)

:: Build autoexec from manifest (always = unconditional, prompt = ask, extra = skip)
echo.
echo // === CS2 CONFIG by erel3 ===> "%CFG%\autoexec.cfg"
for /f "usebackq eol=# tokens=1,2,3 delims=|" %%a in ("%HERE%cfg\manifest.txt") do (
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
