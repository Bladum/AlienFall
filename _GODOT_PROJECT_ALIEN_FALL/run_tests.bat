@echo off
REM Phase 10B Test Runner
REM Runs the Godot test suite including Phase 10B tests

echo === Phase 10B Test Runner ===
echo.

REM Check if Godot executable exists (in parent Godot directory)
if not exist "..\Godot\Godot_v4.4.1-stable_win64.exe" (
    echo ERROR: Godot executable not found at ..\Godot\Godot_v4.4.1-stable_win64.exe
    echo Please ensure Godot is installed in the parent Godot directory.
    pause
    exit /b 1
)

echo Running test suite...
echo.

REM Run the test runner scene
"..\Godot\Godot_v4.4.1-stable_win64.exe" --headless --path . test_runner.tscn

echo.
echo Test run complete.
pause
