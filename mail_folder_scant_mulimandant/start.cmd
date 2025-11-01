@echo off
setlocal EnableExtensions

REM где лежит проект
set "SCRIPT_DIR=%~dp0"
pushd "%SCRIPT_DIR%" >nul

REM ищем pwsh, если нет — падаем на Windows PowerShell
set "PWSH="
for %%P in (
  "%ProgramFiles%\PowerShell\7\pwsh.exe"
  "%ProgramFiles%\PowerShell\7-preview\pwsh.exe"
  "%ProgramFiles(x86)\PowerShell\7\pwsh.exe"
) do if exist "%%~fP" set "PWSH=%%~fP"
if not defined PWSH for /f "delims=" %%X in ('where pwsh 2^>nul') do if not defined PWSH set "PWSH=%%~fX"
if not defined PWSH set "PWSH=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"

REM просто запускаем main.ps1, Root не передаём
"%PWSH%" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%main.ps1" %*
set "RC=%ERRORLEVEL%"

popd >nul
exit /b %RC%
