@echo off
setlocal enabledelayedexpansion
taskkill /f /im lovec.exe >nul 2>&1
timeout /t 1 /nobreak >nul
cd /d "%~dp0engine" || exit /b 1
echo Starting game with debug console...
"C:\Program Files\LOVE\lovec.exe" .
if errorlevel 1 (
    echo Error running game
    exit /b 1
)
