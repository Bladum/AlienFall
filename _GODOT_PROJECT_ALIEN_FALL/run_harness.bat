@echo off
REM Geoscape Headless Harness Runner
REM Usage: run_harness.bat [days] [seed] [export_path]

set DAYS=%1
set SEED=%2
set EXPORT=%3

if "%DAYS%"=="" set DAYS=30
if "%SEED%"=="" set SEED=12345
if "%EXPORT%"=="" set EXPORT=user://geoscape_test_results/

echo Running Geoscape Headless Harness...
echo Days: %DAYS%
echo Seed: %SEED%
echo Export: %EXPORT%
echo.

"c:\Users\tombl\Documents\AlienFall\Godot\Godot_v4.4.1-stable_win64_console.exe" --path . --scene scenes/harness_main.tscn -- --days %DAYS% --seed %SEED% --export %EXPORT%

echo.
echo Harness execution complete.
pause
