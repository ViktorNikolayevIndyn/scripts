@echo off
chcp 65001 >nul
cls

REM ============================================================
REM Company Structure Generator - Launcher
REM InsideDynamic GmbH
REM ============================================================

echo.
echo ============================================================
echo   Company Structure Generator - Launcher
echo   InsideDynamic GmbH
echo ============================================================
echo.
echo Wählen Sie eine Option:
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
echo ❌ Ungültige Eingabe! Bitte wählen Sie 1, 2 oder 3.
timeout /t 3 >nul
goto start

:gui
echo.
echo 🚀 Starte GUI-Version...
echo.
powershell.exe -ExecutionPolicy Bypass -File "%~dp0create_structure_GUI.ps1"
goto end

:console
echo.
echo 🚀 Starte Konsolen-Version...
echo.
powershell.exe -ExecutionPolicy Bypass -File "%~dp0create_structure.ps1"
goto end

:end
echo.
pause
