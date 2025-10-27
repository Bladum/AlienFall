@echo off
setlocal enabledelayedexpansion
taskkill /f /im love.exe >nul 2>&1
timeout /t 1 /nobreak >nul
cd /d "%~dp0engine" || exit /b 1
echo Starting game release version...
"C:\Program Files\LOVE\love.exe" .
if errorlevel 1 (
    echo Error running game
    exit /b 1
)
