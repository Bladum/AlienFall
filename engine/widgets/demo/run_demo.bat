@echo off
echo Starting Widget Demo...
echo.
echo Controls:
echo   F9  - Toggle grid overlay
echo   F12 - Toggle fullscreen
echo   ESC - Quit
echo.

cd /d "%~dp0"
cd ..\..
lovec "widgets/demo"

pause
