@echo off
REM ─────────────────────────────────────────────────────────────────────────
REM  PROPERTY-BASED TEST RUNNER (Batch File)
REM ─────────────────────────────────────────────────────────────────────────
REM  Runs Phase 6: Property-Based Tests (55 tests)
REM  Purpose: Verify edge cases, boundaries, and stress conditions
REM  Usage: run_property.bat
REM ─────────────────────────────────────────────────────────────────────────

setlocal enabledelayedexpansion

REM Check if lovec is available
where lovec >nul 2>nul
if errorlevel 1 (
    echo.
    echo ERROR: lovec not found in PATH
    echo Please install Love2D 12.0 or add it to your PATH
    echo.
    pause
    exit /b 1
)

echo.
echo ════════════════════════════════════════════════════════════════════════
echo AlienFall - Phase 6: PROPERTY-BASED TESTS
echo ════════════════════════════════════════════════════════════════════════
echo.
echo Running property-based test suite...
echo Expected: 55 tests in ~8 seconds
echo.

REM Run the property test runner
lovec "tests2" "run_property"

echo.
echo ════════════════════════════════════════════════════════════════════════
echo Property-Based Test Run Complete
echo ════════════════════════════════════════════════════════════════════════
echo.

pause
