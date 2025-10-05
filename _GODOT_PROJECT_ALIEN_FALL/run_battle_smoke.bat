@echo off
REM Battle Smoke Test Harness Runner
REM Usage: run_battle_smoke.bat --seed 12345 --terrain urban --export out/

echo === AlienFall Battle Smoke Test Harness ===
echo.

if "%~1"=="" (
    echo Usage: run_battle_smoke.bat --seed ^<int^> --terrain ^<id^> --export ^<path^>
    echo.
    echo Example: run_battle_smoke.bat --seed 12345 --terrain urban --export out/
    echo.
    echo Parameters:
    echo   --seed ^<int^>        RNG seed for deterministic generation (default: 12345)
    echo   --terrain ^<id^>      Terrain template ID (urban, forest, desert, industrial)
    echo   --export ^<path^>     Export directory path (default: out/)
    echo   --width ^<int^>       Map width (default: 20)
    echo   --height ^<int^>      Map height (default: 20)
    echo   --levels ^<int^>      Map levels (default: 1)
    echo.
    echo Available terrains: urban, forest, desert, industrial
    exit /b 1
)

echo Running battle smoke test with parameters: %*
echo.

cd /d "%~dp0"
if not exist Godot_v4.4.1-stable_win64_console.exe (
    echo ERROR: Godot console executable not found in current directory
    echo Please ensure Godot_v4.4.1-stable_win64_console.exe is in the same directory as this script
    pause
    exit /b 1
)

Godot_v4.4.1-stable_win64_console.exe --headless --script battle_smoke_test.gd %*

echo.
echo Battle smoke test completed.
pause
