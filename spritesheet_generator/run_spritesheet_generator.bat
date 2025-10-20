@echo off
REM Graphics Spritesheet Generator
REM Uruchamia Love2D do wygenerowania arkuszy A4 z grafikami

echo.
echo ========== GRAPHICS SPRITESHEET GENERATOR ==========
echo.
echo Generowanie arkuszy A4 do drukowania...
echo Każda grafika będzie wklejona 150 razy (10x15).
echo.
echo Patrz konsolę Love2D dla szczegółów...
echo.

cd /d "%~dp0"

"C:\Program Files\LOVE\lovec.exe" "spritesheet_generator"

echo.
echo ========== GOTOWE ==========
echo Arkusze znajdują się w: spritesheet_generator\output_spritesheets\
echo.
pause
