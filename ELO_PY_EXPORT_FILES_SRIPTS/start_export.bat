@echo off
chcp 65001 > nul
REM ELO Export Script - Starter
REM Dieses Script startet den Export mit den Standardeinstellungen aus config.py

echo ===================================
echo     ELO Export Tool
echo ===================================
echo.

python main.py --export

echo.
echo ===================================
echo Export abgeschlossen!
echo ===================================
pause
