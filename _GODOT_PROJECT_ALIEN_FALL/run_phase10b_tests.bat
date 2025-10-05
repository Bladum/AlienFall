@echo off
REM Phase 10B Test Runner (Standalone)
REM Runs only Phase 10B tests without other dependencies

echo === Phase 10B Standalone Test Runner ===
echo.

REM Check if Godot executable exists (in parent Godot directory)
if not exist "..\Godot\Godot_v4.4.1-stable_win64.exe" (
    echo ERROR: Godot executable not found at ..\Godot\Godot_v4.4.1-stable_win64.exe
    echo Please ensure Godot is installed in the parent Godot directory.
    pause
    exit /b 1
)

echo Running Phase 10B tests...
echo.

REM Run the Phase 10B test scene
"..\Godot\Godot_v4.4.1-stable_win64.exe" --headless --path . phase10b_test.tscn

echo.
echo Phase 10B test run complete.
pause
