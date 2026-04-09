@echo off
chcp 65001 >nul 2>&1
title CS2 Config Installer

set "REPO=https://raw.githubusercontent.com/erel3/cs2-config/main"

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
set "CFG=%STEAM%\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg"
if not exist "%CFG%" (
    echo.
    echo ERROR: Game cfg folder not found: %CFG%
    echo Is CS2 installed?
    pause
    exit /b 1
)

echo.
echo Downloading configs to %CFG%

:: Download all files using curl (built into Windows 10+)
for %%f in (base.cfg binds.cfg crosshair.cfg viewmodel.cfg mouse.cfg) do (
    echo   %%f...
    curl -sL "%REPO%/cfg/%%f" -o "%CFG%\%%f"
)
for %%f in (practice.cfg practice_off.cfg) do (
    echo   %%f...
    curl -sL "%REPO%/%%f" -o "%CFG%\%%f"
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
