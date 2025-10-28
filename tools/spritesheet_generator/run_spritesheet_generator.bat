@echo off
REM Spritesheet Generator - Object-Oriented Version
REM Generates spritesheets for multiple armies (red, yellow, blue)

echo.
echo ========== SPRITESHEET GENERATOR - OOP ==========
echo.
echo Generating A4 spritesheets for all armies...
echo - Red army
echo - Yellow army
echo - Blue army
echo.
echo Each army generates 10 unit types x 15 repetitions
echo.

cd /d "%~dp0"

"C:\Program Files\LOVE\lovec.exe" "."

echo.
echo ========== COMPLETE ==========
echo Output files are in: output\
echo.
