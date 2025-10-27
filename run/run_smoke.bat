@echo off
REM ─────────────────────────────────────────────────────────────────────────
REM RUN SMOKE TESTS
REM ─────────────────────────────────────────────────────────────────────────
REM Purpose: Quick validation tests for core systems
REM Expected: 22 tests, <500ms execution

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
echo Running SMOKE TESTS (Quick Validation)
echo ═════════════════════════════════════════════════════════════════════════
echo.

REM Run smoke tests from tests2/ directory (so requires work correctly)
"C:\Program Files\LOVE\lovec.exe" "tests2" "run_smoke"

if %errorlevel% neq 0 (
    echo.
    echo ═════════════════════════════════════════════════════════════════════════
    echo ERROR: Smoke tests failed
    echo ═════════════════════════════════════════════════════════════════════════
    exit /b 1
)

echo.
echo ═════════════════════════════════════════════════════════════════════════
echo Smoke tests completed successfully
echo ═════════════════════════════════════════════════════════════════════════

endlocal
