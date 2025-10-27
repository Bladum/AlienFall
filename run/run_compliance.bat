@echo off
REM ─────────────────────────────────────────────────────────────────────────
REM  COMPLIANCE TEST RUNNER (Batch File)
REM ─────────────────────────────────────────────────────────────────────────
REM  Runs Phase 4: Compliance Tests (44 tests)
REM  Purpose: Verify game rules, constraints, and business logic compliance
REM  Usage: run_compliance.bat
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
echo AlienFall - Phase 4: COMPLIANCE TESTS
echo ════════════════════════════════════════════════════════════════════════
echo.
echo Running compliance test suite...
echo Expected: 44 tests in ~5 seconds
echo.

REM Run the compliance test runner
lovec "tests2" "run_compliance"

echo.
echo ════════════════════════════════════════════════════════════════════════
echo Compliance Test Run Complete
echo ════════════════════════════════════════════════════════════════════════
echo.

pause
