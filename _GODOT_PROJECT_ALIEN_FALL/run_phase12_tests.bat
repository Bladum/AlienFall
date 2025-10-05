@echo off
REM Phase 12 Test Runner
REM Runs the telemetry and provenance logging tests

echo === Phase 12: Telemetry and Provenance Logging Tests ===

REM Find Godot executable
if exist "C:\Users\%USERNAME%\Documents\AlienFall\Godot\Godot_v4.4.1-stable_win64.exe" (
    set GODOT_EXE="C:\Users\%USERNAME%\Documents\AlienFall\Godot\Godot_v4.4.1-stable_win64.exe"
) else if exist "C:\Program Files\Godot\Godot_v4.4.1-stable_win64.exe" (
    set GODOT_EXE="C:\Program Files\Godot\Godot_v4.4.1-stable_win64.exe"
) else (
    echo ERROR: Godot executable not found. Please ensure Godot 4.4.1 is installed.
    pause
    exit /b 1
)

echo Running Phase 12 tests...
%GODOT_EXE% --headless --script res://scripts/tests/test_phase12.gd

echo.
echo Phase 12 tests completed.
pause
