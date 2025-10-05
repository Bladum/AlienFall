@echo off
REM Phase 10B Validation Runner
REM Runs the validation script to test the battle smoke test harness

echo === Phase 10B Validation Runner ===
echo.

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found. Please install Python 3.7+ and add to PATH.
    pause
    exit /b 1
)

REM Run the validation script
python validate_phase_10b.py

REM Keep window open if there was an error
if errorlevel 1 (
    echo.
    echo Validation failed. Press any key to exit.
    pause >nul
)

echo.
echo Validation complete. Press any key to exit.
pause >nul
