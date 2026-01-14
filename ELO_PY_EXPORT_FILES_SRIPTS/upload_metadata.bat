@echo off
chcp 65001 > nul
REM ELO Metadata Upload Script
REM Lädt Metadaten aus download_db.json zurück in ELO

echo ===================================
echo     ELO Metadata Upload
echo ===================================
echo.

python main.py --upload-metadata

echo.
echo ===================================
echo Metadata-Upload abgeschlossen!
echo ===================================
pause
