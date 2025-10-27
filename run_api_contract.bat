@echo off
REM ─────────────────────────────────────────────────────────────────────────
REM RUN API CONTRACT TESTS
REM ─────────────────────────────────────────────────────────────────────────
REM Purpose: Interface verification tests
REM Expected: 45 tests, <3 seconds execution

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
echo Running API CONTRACT TESTS (Interface Verification)
echo ═════════════════════════════════════════════════════════════════════════
echo.

REM Run API contract tests
"C:\Program Files\LOVE\lovec.exe" "tests2" "run_api_contract"

if %errorlevel% neq 0 (
    echo.
    echo ═════════════════════════════════════════════════════════════════════════
    echo ERROR: API contract tests failed
    echo ═════════════════════════════════════════════════════════════════════════
    exit /b 1
)

echo.
echo ═════════════════════════════════════════════════════════════════════════
echo API contract tests completed successfully
echo ═════════════════════════════════════════════════════════════════════════

endlocal
