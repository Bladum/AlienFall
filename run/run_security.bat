@echo off
REM ─────────────────────────────────────────────────────────────────────────
REM  SECURITY TEST RUNNER (Batch File)
REM ─────────────────────────────────────────────────────────────────────────
REM  Runs Phase 5: Security Tests (44 tests)
REM  Purpose: Verify data protection, access control, and attack prevention
REM  Usage: run_security.bat
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
echo AlienFall - Phase 5: SECURITY TESTS
echo ════════════════════════════════════════════════════════════════════════
echo.
echo Running security test suite...
echo Expected: 44 tests in ~5 seconds
echo.

REM Run the security test runner
lovec "tests2" "run_security"

echo.
echo ════════════════════════════════════════════════════════════════════════
echo Security Test Run Complete
echo ════════════════════════════════════════════════════════════════════════
echo.

pause
