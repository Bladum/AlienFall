@echo off
REM ─────────────────────────────────────────────────────────────────────────
REM RUN REGRESSION TESTS
REM ─────────────────────────────────────────────────────────────────────────
REM Purpose: Bug prevention tests - catch regressions
REM Expected: 38 tests, <2 seconds execution

setlocal enabledelayedexpansion

REM Check if Love2D is installed
if not exist "C:\Program Files\LOVE\lovec.exe" (
    echo Error: Love2D not found at C:\Program Files\LOVE\lovec.exe
    echo Please install Love2D 12.0 or later
    pause
    exit /b 1
)

echo.
echo ═════════════════════════════════════════════════════════════════════════
echo Running REGRESSION TESTS (Bug Prevention)
echo ═════════════════════════════════════════════════════════════════════════
echo.

REM Run regression tests
"C:\Program Files\LOVE\lovec.exe" "tests2" "run_regression"

if %errorlevel% neq 0 (
    echo.
    echo ═════════════════════════════════════════════════════════════════════════
    echo ERROR: Regression tests failed
    echo ═════════════════════════════════════════════════════════════════════════
    exit /b 1
)

echo.
echo ═════════════════════════════════════════════════════════════════════════
echo Regression tests completed successfully
echo ═════════════════════════════════════════════════════════════════════════

endlocal
