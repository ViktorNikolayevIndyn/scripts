@echo off
chcp 65001 >nul
cls

REM ============================================================
REM Company Structure Generator - Launcher
REM InsideDynamic GmbH
REM ============================================================

:start
echo.
echo ============================================================
echo   Company Structure Generator - Launcher
echo   InsideDynamic GmbH
echo ============================================================
echo.
echo Waehlen Sie eine Option:
echo.
echo   [1] GUI-Version starten (empfohlen)
echo   [2] Konsolen-Version starten
echo   [3] Beenden
echo.
echo ============================================================
echo.

set /p choice="Ihre Wahl (1-3): "

if "%choice%"=="1" goto gui
if "%choice%"=="2" goto console
if "%choice%"=="3" goto end

echo.
echo [x] Ungueltige Eingabe! Bitte waehlen Sie 1, 2 oder 3.
timeout /t 3 >nul
cls
goto start

:gui
cls
echo.
echo [*] Starte GUI-Version...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0create_structure_GUI.ps1"
if errorlevel 1 (
    echo.
    echo [!] Fehler beim Starten der GUI-Version.
    pause
)
goto end

:console
cls
echo.
echo [*] Starte Konsolen-Version...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0create_structure.ps1"
if errorlevel 1 (
    echo.
    echo [!] Fehler beim Starten der Konsolen-Version.
    pause
)
goto end

:end
exit /b 0
echo.
pause
